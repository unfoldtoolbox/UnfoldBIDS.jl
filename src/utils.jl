"""
	run_unfold(data_df, bf_vec; 
		eventcolumn="event",
		remove_time_expanded_Xs=true, 
		extract_data = raw_to_data, 
		verbose::Bool=true, 
		kwargs...)

Run Unfold analysis on all data in data_df.

## Keywords

- `remove_time_expanded_Xs::Bool = true`\\
   Removes the timeexpanded designmatrix which significantly reduces the memory-consumption. This Xs is rarely needed, but can be recovered (look into the Unfold.load function)
- `extract_data::function = raw_to_data`\\
   Specify the function that translate the MNE Raw object to an data array. Default is `raw_to_data` which uses `get_data` and allows to pick `channels` - see @Ref(`raw_to_data`). The optional kw- arguments (e.g. channels) need to be specified directly in the `run_unfold` function as kw-args
- `verbose::Bool = true)`\\
   Show ProgressBar or not.
- `kwargs...`\\
   Will be passed to *both* the `fit()` and  `extract_data()` calls as function inputs.\\
   For possible kwargs to `fit()` please have a look at the Unfold.jl API: https://unfoldtoolbox.github.io/UnfoldDocs/Unfold.jl/stable/references/functions/
"""
function run_unfold(data_df::DataFrame, bf_vec; overlap_corrected::Bool = true, remove_time_expanded_Xs=true, extract_data::Function = raw_to_data, verbose::Bool=true, kwargs...)
	# Init results dataframe
    resultsDF = DataFrame()

	# Check kwargs
	fit_keys = (:fit, :contrasts, :eventcollumn, :solver. :show_progress, :eventfields, :show_warnings)
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
		@assert String(eventfields[1]) ∈ names(tmp_events) "Eventfield $(eventfields[1]) not found in events DataFrame. This field is required to define event onsets. Please set the eventfields argument to the collumn that defines your event onsets (in samples)."

        tmp_data = extract_data(row.raw; extract_data_kwargs...)


        # Fit Model
		if overlap_corrected
        	m = fit(UnfoldModel, bf_vec, tmp_events, tmp_data; fit_kwargs...)
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

        append!(resultsDF, results)


    end
    return resultsDF
end

"""
	raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=[])


Function to get data from MNE raw object. Can choose specific channels; default loads all channels.
"""
function raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=["all"])
    return pyconvert(Array, raw.get_data(picks=pylist(channels), units="uV"))
end

"""
	unpack_events(df::DataFrame)

Unpack events into tidy data frame; useful with AlgebraOfGraphics.jl

df is expected to be a UnfoldBIDS DataFrame where events are loaded already.
"""
function unpack_events(df::DataFrame)

	all_events = DataFrame()
	for row in eachrow(df)
		tmp_df = row.events
		tmp_df.subject .= row.subject
		tmp_df.ses .= row.ses
		tmp_df.task .= row.task
		tmp_df.run .= row.run
		append!(all_events, tmp_df)
	end
	# Change collumn order to look nicer
	select!(all_events, :subject, :ses, :task, :run, Not([:subject, :ses, :task, :run]))
	return all_events
end

"""
	bids_coeftable(model_df)

Turns all models found in model_df into tydy DataFrames and aggregates them in a new DataFrame.
"""
function bids_coeftable(model_df)

	all_results = DataFrame()
	for row in eachrow(model_df)
		tmp_table = coeftable(row.model)
		tmp_df = DataFrame(subject = row.subject, ses=row.ses, task=row.task, run=row.run,  results = tmp_table)
		append!(all_results, tmp_df)
	end

	return all_results
end

"""
	unpack_results(results_df)

Unpack all results into one tidy dataframe/ coeftable.
"""
function unpack_results(results_df)

	all_results = DataFrame()
	for row in eachrow(results_df)
		tmp_df = row.results
		tmp_df.subject .= row.subject
		tmp_df.ses .= row.ses
		tmp_df.task .= row.task
		tmp_df.run .= row.run
		append!(all_results, tmp_df)
	end
	# Change collumn order to look nicer
	select!(all_results, :subject, :ses, :task, :run, Not([:subject, :ses, :task, :run]))

	return all_results
end

"""
	bids_effects(model_df::DataFrame, effects_dict::Dict)

Calculate [mariginalized effect](https://unfoldtoolbox.github.io/UnfoldDocs/Unfold.jl/stable/generated/HowTo/effects/) on all subjects found in the model dataframe using `effects_dict`.
"""
function bids_effects(model_df::DataFrame, effects_dict::Dict)

	all_results = DataFrame()
	for row in eachrow(model_df)
		tmp_df = effects(effects_dict, row.model);

		tmp_df.subject .= row.subject
		tmp_df.ses .= row.ses
		tmp_df.task .= row.task
		tmp_df.run .= row.run
		append!(all_results, tmp_df)
	end
	
	# Change collumn order to look nicer
	select!(all_results, :subject, :ses, :task, :run, Not([:subject, :ses, :task, :run]))

	return all_results
end

"""
	rename_to_latency(data_df)

This is a convenience function to add a :latency collumn (needed by Unfold) based on another variable in the events_df (e.g. sample)
"""
function rename_to_latency(data_df, symbol::Symbol)
	for row in eachrow(data_df); row.events.latency = row.events[!,symbol]; end
end

"""
	list_all_paths(path)

Internal function to find pathfiles
"""
list_all_paths(path, file_ending, file_pattern; exclude=nothing) = @cont begin
	if isfile(path)
		startswith(basename(path), ".") && return # skip all hidden files
		(any(endswith.(path, file_ending)) & all(occursin.(file_pattern, path))) && cont(path)
	elseif isdir(path)
		startswith(basename(path), ".") && return # skip all hidden paths
		if exclude !== nothing
			basename(path) in (exclude...,) && return
		end
		for file in readdir(path)
			foreach(cont, list_all_paths(joinpath(path, file), file_ending, file_pattern, exclude=exclude))
		end
	end
end

"""
path = erp_core_example()

	Convenience function to load a BIDS conform folder containing three subjects of the P300 task of ERP-Core dataset.
	Returns path to BIDS root folder
"""

function erp_core_example()
	path = artifact"sample_BIDS"
	return path
end