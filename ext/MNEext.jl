module MNEext
using UnfoldBIDS
using Unfold
using PyMNE
using DataFrames, DataFramesMeta
using ProgressBars

"""
    _load_bids_eeg_data(layout_df; verbose::Bool=true, kwargs...)

Internal function to load BIDS EEG data given a bidsLayout DataFrame.

- `verbose::Bool = true`\\
   Show ProgressBar
- `kwargs...`\\
   kwargs for CSV.read to load events from .tsv file; e.g. to specify delimeter
"""
function _load_bids_eeg_data(layout_df; verbose::Bool=true, kwargs...)

    # Initialize an empty dataframe
    eeg_df = DataFrame()

    pbar = ProgressBar(total=size(layout_df, 1))

    # Loop through each EEG data file
    for row in eachrow(layout_df)
        file_path = row.file
        if verbose
            update(pbar)
            #@printf("Loading subject %s at:\n %s \n",row.subject, file_path)
        end

        # Read in the EEG data as a dataframe using the appropriate reader
        if endswith(file_path, ".edf")
            eeg_raw = PyMNE.io.read_raw_edf(file_path, verbose="ERROR")
        elseif endswith(file_path, ".vhdr")
            eeg_raw = PyMNE.io.read_raw_brainvision(file_path, verbose="ERROR")
        elseif endswith(file_path, ".fif")
            eeg_raw = PyMNE.io.read_raw_fif(file_path, verbose="ERROR")
        elseif endswith(file_path, ".set")
            eeg_raw = PyMNE.io.read_raw_eeglab(file_path, verbose="ERROR")
        end

        tmp_df = DataFrame(subject=row.subject, ses=row.ses, task=row.task, run=row.run, raw=eeg_raw)

        append!(eeg_df, tmp_df)
    end

    # try to add events
    try
        events = UnfoldBIDS.load_events(layout_df; kwargs...)
        eeg_df[!, :events] = events.events
    catch
        @warn "Something went wrong while adding events to DataFrame. Needs manual intervention."
    end

    # Return the combined EEG data dataframe
    return eeg_df
end


"""
_run_unfold(data_df, bf_vec; 
            remove_time_expanded_Xs=true, 
            extract_data = raw_to_data, 
            verbose::Bool=true, 
            kwargs...)

Internal function to run Unfold models on DataFrame with MNE Raw objects. Requires PyMNE.jl to be loaded.
"""

function _run_unfold(data_df::DataFrame, bf_vec; remove_time_expanded_Xs=true, extract_data::Function = raw_to_data, verbose::Bool=true, kwargs...)
		
	# Init results dataframe
    results_df = DataFrame()

	# Check kwargs
	fit_keys = (:fit, :contrasts, :eventcolumn, :solver, :show_progress, :eventfields, :show_warnings)
	fit_kwargs = (; (k => v for (k, v) in pairs(kwargs) if k ∈ fit_keys)...)
	extract_data_kwargs = (; (k => v for (k, v) in pairs(kwargs) if k ∉ fit_keys)...)

	# Init progress bar
	pbar = ProgressBar(total=size(data_df, 1))

    for row in eachrow(data_df)

		if verbose
            update(pbar)
            #@printf("Loading subject %s \n",row.subject)
        end

        tmp_events = row.events

		# Assert if first eventfield in events
		# @assert String(eventfields[1]) ∈ names(tmp_events) "Eventfield $(eventfields[1]) not found in events DataFrame. This field is required to define event onsets. Please set the eventfields argument to the collumn that defines your event onsets (in samples)."

        tmp_data = extract_data(row.raw; extract_data_kwargs...)

		# Check for type of model to fit
		tmp = last(bf_vec[1])

        # Fit Overlap Corrected Model if BasisFunction is used
		if supertype(typeof(tmp[2])) == Unfold.BasisFunction
        	m = fit(UnfoldModel, bf_vec, tmp_events, tmp_data; fit_kwargs...)
		
		# Fit Mass-Univariate Model if time window tuple is used
		elseif typeof(tmp[2]) == Tuple{Real, Real}
			@assert size(bf_vec, 1) == 1 && bf_vec[1][1] != Any "Currently only one event type is supported for Mass-Univariate models with UnfoldBIDS. Please change your bf_vec accordingly."

			# Get sfreq from raw
			sfreq = pyconvert(Real, row.raw.info["sfreq"])

			# Epoch data
			evts = @rsubset(tmp_events, :event .== bf_vec[1][1])
			data_epochs, times = Unfold.epoch(data = tmp_data, tbl = evts, τ = tmp[2], sfreq = sfreq);

			# Fit Mass-Univariate Model
			m = fit(UnfoldModel, tmp[1], data_epochs, times; fit_kwargs...)

		end
		
        if remove_time_expanded_Xs && (m isa UnfoldLinearModel || m isa UnfoldLinearModelContinuousTime)
            #m = typeof(m)(m.design, Unfold.DesignMatrix(designmatrix(m).formulas, missing, designmatrix(m).events), m.modelfit)
            m.designmatrix = [
                    typeof(m.designmatrix[k])(
                        Unfold.formulas(m)[k],
                        Unfold.empty_modelmatrix(designmatrix(m)[k]),
                        Unfold.events(m)[k],
                    ) for k = 1:length(m.designmatrix)
                ]
        end

        results = DataFrame(subject = row.subject, ses=row.ses, task=row.task, run=row.run,  model = m)

        append!(results_df, results)


    end
    return results_df
end

"""
	raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=[])


Function to get data from MNE raw object. Can choose specific channels; default loads all channels.
"""
function raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=["all"])
    return pyconvert(Array, raw.get_data(picks=pylist(channels), units="uV"))
end

end # module MNEext