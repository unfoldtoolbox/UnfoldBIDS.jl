# # Quickstart

using UnfoldBIDS
using Unfold
using Main: @artifact_str # this is a workaround for Artifacts used in docs; locally you would `using LazyArtifacts`

# ## Loading data

# To load use UnfoldBIDS to find the paths to all subject specific data you can uye the bidsLayout function:
# 

sample_data_path = artifact"sample_BIDS"
layout_df = bids_layout(sample_data_path, derivatives=false)

# This will give you a DataFrame containing the paths too the eeg files of all subjects plus their accompanying event files

# !!! note
#       Since we set the derivative keyword to false here UnfoldBIDS will only look for the raw EEG files. However, by default UnfoldBIDS assumes you have preprocessed data in a derivatives folder and try to look for those.

# Subsequently, you can load the data of all subjects into memory

data_df = load_bids_eeg_data(layout_df)

#
# !!! note
#       At this point in time, the data is not yet actually loaded into memory, but uses MNE's lazy loading functionality.

# As you can see, UnfoldBIDS trys to load events directly into the DataFrame, however if you are missing the event tsv files you will get a warning and no events are loaded. If that happens you have to manually load these events. The following function might help you with this. (The resulting dataframe still needs to be added to data_df!)

# ```julia
# events_df = load_events(layout_df)
# ```

# ## Run unfold type models


basisfunction = firbasis(τ=(-0.2,.8),sfreq=1024)
f  = @formula 0~1
bfDict = ["stimulus"=>(f,basisfunction)]
UnfoldBIDS.add_latency_from_df(data_df, :sample) # Unfold expects a :latency collumn in your events; if your event latency is named differently you can use this function as remedy

resultsAll = run_unfold(data_df, bfDict; eventcolumn="trial_type");