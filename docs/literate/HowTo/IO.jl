# # Save/ load Unfold.jl results
#
# With UnfoldBIDS you can easily save your unfold results in a BIDS conform way, and later load those results. Under the hood, this is a more fancy application of the way you can [save results with Unfold.jl](https://unfoldtoolbox.github.io/UnfoldDocs/Unfold.jl/stable/generated/HowTo/unfold_io/)
#
#
# ## Save
#
# To save results you only need your results DataFrame, which was returned by `run_unfold()`, and the path to your BIDS root folder
#
# ```julia
# save_results(results, bids_root)
# ```
# UnfoldBIDS will then automatically create a dedicated "Unfold" folder in your derivatives and save each subject's UnfoldModel in a BIDS conform way in JLD2 format.
# The data will then be saved as `path/to/your/bids_root/derivatives/Unfold/sub-XXX/eeg/sub-XXX_ses-XX_task-XXX_run-XX_unfold.jld2`
#
# !!! note
#       `save_results` has two more keywords: `derivatives_subfolder` let's you specifiy a different foldername than "Unfold"; and `overwrite::Bool` indicates if the function should check for existing files with the same name.
#
# ## Load
#
# To load results that have been saved with `save_results()`, simply provide your bids_root folder again + any further information necessary (for example which run to load, or if you have saved the results in folder different than the "Unfold" default)
# ```julia
# load_results(bids_root)
# ```
#
# You can additionally specifiy to load results, lazily (using the keyword `lazy=true`) to only load the paths/filenames; or choose to not reconstruct the designmatrix (using the keyword `generate_Xs=false`)
