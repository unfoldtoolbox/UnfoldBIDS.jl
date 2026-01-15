module MNEext
using UnfoldBIDS
using PyMNE
using DataFrames, DataFramesMeta
using ProgressBars

"""
    _load_bids_eeg_data(file_path::String)

Internal function to load BIDS EEG data given a bidsLayout DataFrame.
"""
function _load_with_mne(file_path::String)

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

    return eeg_raw
end


"""
	raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=[])


Function to get data from MNE raw object. Can choose specific channels; default loads all channels.
"""
function raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}} = ["all"])
    return pyconvert(Array, raw.get_data(picks = pylist(channels), units = "uV"))
end

end # module MNEext