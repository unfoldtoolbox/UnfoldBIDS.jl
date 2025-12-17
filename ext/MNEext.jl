module MNEext
using UnfoldBIDS
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
function _load_bids_eeg_data(layout_df; verbose::Bool = true, kwargs...)

    # Initialize an empty dataframe
    eeg_df = DataFrame()

    pbar = ProgressBar(total = size(layout_df, 1))

    # Loop through each EEG data file
    for row in eachrow(layout_df)
        file_path = row.file
        if verbose
            update(pbar)
            #@printf("Loading subject %s at:\n %s \n",row.subject, file_path)
        end

        # Read in the EEG data as a dataframe using the appropriate reader
        if endswith(file_path, ".edf")
            eeg_raw = PyMNE.io.read_raw_edf(file_path, verbose = "ERROR")
        elseif endswith(file_path, ".vhdr")
            eeg_raw = PyMNE.io.read_raw_brainvision(file_path, verbose = "ERROR")
        elseif endswith(file_path, ".fif")
            eeg_raw = PyMNE.io.read_raw_fif(file_path, verbose = "ERROR")
        elseif endswith(file_path, ".set")
            eeg_raw = PyMNE.io.read_raw_eeglab(file_path, verbose = "ERROR")
        end

        tmp_df = DataFrame(
            subject = row.subject,
            ses = row.ses,
            task = row.task,
            run = row.run,
            raw = eeg_raw,
        )

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
	raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=[])


Function to get data from MNE raw object. Can choose specific channels; default loads all channels.
"""
function raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}} = ["all"])
    return pyconvert(Array, raw.get_data(picks = pylist(channels), units = "uV"))
end

end # module MNEext