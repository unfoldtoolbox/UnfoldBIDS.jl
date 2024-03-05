# # Brain Imaging Data Structure
# If you are using UnfoldBIDS we assume you are already familiar with the BIDS format.
# However, since the package only works if your dataset is BIDS formatted, here is a quick reminder.
# If you want a more in-depth explanation, please refer to the official [BIDS documentation](https://bids-specification.readthedocs.io/en/stable/)

# ## Folder Structure
# Folders have to follow the following structure:

#       |-BIDS-Root/
#           |--- [required meta files]
#           |--- sub-<label>/
#               |--- eeg/
#                   |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.<extension>
#                   |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.json
#                   |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.json
#                   |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.tsv
#           |--- derivatives/ <- for (pre-processed data)
#              |--- [required meta files]
#              |--- sub-<label>/
#                   |--- eeg/
#                       |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.<extension>
#                       |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.json
#                       |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.json
#                       |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.tsv

# ## File formats
# By BIDS standard your files have to be in one of the following formats:
# *EEG*
# - edf (European Data Fromat; single file)
# - vhdr (BrainVision format; file triplet of .vhdr, .vmrk and .eeg)
# - set (EEGLAB saved file; .fdt file optional)
# - fif (MNE save file; not BIDS conform, but implemented for convenience)
#
# *Events*
# UnfoldBIDS.jl will automatically try to load accompanying events.tsv files. Loading events from the EEG data files is currently not supported, and not BIDS conform.

# ## BIDS Transformation
# If your dataset is not yet BIDS conform you can use [MNE-BIDS](https://mne.tools/mne-bids/v0.5/index.html) to transform your data.