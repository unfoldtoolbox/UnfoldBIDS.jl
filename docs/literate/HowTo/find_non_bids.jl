# # How to find non-BIDS data

# In some cases you might want to use a dataset that is not (entirely) BIDS compatible. While UnfoldBIDS.jl is expecting you to comply with the BIDS structure, you can also make use of the underlying functions to (at least) find your data.

# The key element here is that a lot of what `bids_layout()` is doing, is to find _the right_ data based on your input. However, you can also do that manually, by using `UnfoldBIDS.list_all_paths()`
# The function takes in a few keywords:
# ```julia
# UnfoldBIDS.list_all_paths(path, file_ending, file_pattern; exclude=nothing)
# ```
# Where
# - `path::String = path_to_data_folder`; should be input with `abspath()` \
#
# - `file_ending::String = data_file_ending`; UnfoldBIDS is looking for `file_ending = [".set", ".fif", ".vhdr", ".edf"]`, but maybe you are looking for a `".mat"`? \
#
# - `file_pattern::String = ses_task_run`; this control for which session/task/run you are looking for (e.g. `"ses-001"`); can be empty String to look for everything: `file_pattern = [""]` \
#
# - `exclude = folder_to_exclude`; If there is a folder in your path_to_data_folder you want to exclude you can input this here; defaults to `nothing`\

# In an applied case you would then:
# ```julia
# # Init a files DataFrame
# files_df = DataFrame(subject=[], ses=[], task=[], run=[], file=[])  # Initialize an empty DataFrame to hold results
# 
# # path settings
# bidsPath = "path/to/folder"
# file_ending = [".mat"]
# file_pattern = [""]
# exclude = nothing
# 
# # Find paths
# all_paths = collect(list_all_paths(abspath(bidsPath), file_ending, file_pattern, exclude=exclude))
# ```

# !!! note
#       It is _not_ tested whether you can find data that is stored in a different way than BIDS structured (e.g. all files in one folder instead of one sub-XXX folder per subject); but technically this should be possible.

# Additionally you want to put your found paths in a nicer DataFrame containing subject specific information
# ```julia
# # Init a files DataFrame
# files_df = DataFrame(subject=[], ses=[], task=[], run=[], file=[])  # Initialize an empty DataFrame to hold results
# 
# # Add subject information
# for path in all_paths
#     UnfoldBIDS.extract_subject_id!(files_df, path)
# end
#
# # Check for multiple session/tasks/runs
# ses = nothing; task = nothing; run = nothing;
# UnfoldBIDS.check_df(files_df, ses, task, run)
# ```

# !!! note
#       This does not look for your events; and if you used a different file ending than UnfoldBIDS' default you won't be able to use `load_bids_eeg_data` with your DataFrame!
