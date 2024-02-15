# # 1. Quickstart

using UnfoldBIDS

# ## Loading data

# To load use UnfoldBIDS to find the paths to all subject specific data you can uye the bidsLayout function:

path_to_bids_root = "/store/data/2023EEGManyLabs"
layout_df = bidsLayout(path_to_bids_root, derivative=false)

# This will give you a DataFrame containing the paths too the eeg files of all subjects plus their accompanying event files

# !!! note
#       Since we set the derivative keyword to false here UnfoldBIDS will only look for the raw EEG files. However, by default UnfoldBIDS assumes you have preprocessed data in a derivatives folder and try to look for those.

# Subsequently, you can load the data of all subjects into memory

eeg_df = load_bids_eeg_data(layout_df)

# !!! note
#       The data is not actually loaded into memory, but uses MNE's lazy loading functionality.

# Lastly, current functionality only supports explicit loading of the events. In the future this will be done automatically with the previous step.

load_events(layoutDF)