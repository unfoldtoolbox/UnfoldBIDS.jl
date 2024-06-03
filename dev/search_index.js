var documenterSearchIndex = {"docs":
[{"location":"api/","page":"DocStrings","title":"DocStrings","text":"Modules = [UnfoldBIDS]","category":"page"},{"location":"api/#UnfoldBIDS._load_results","page":"DocStrings","title":"UnfoldBIDS._load_results","text":"_load_results(files_df; generate_Xs::Bool = true)\n\nInternal function to load Unfold models into memory. Can also be used to load data after file information was loaded lazily (lazy=true) using load_results()\n\n\n\n\n\n","category":"function"},{"location":"api/#UnfoldBIDS.list_all_paths-Tuple{Any, Any, Any}","page":"DocStrings","title":"UnfoldBIDS.list_all_paths","text":"list_all_paths(path)\n\nInternal function to find pathfiles\n\n\n\n\n\n","category":"method"},{"location":"api/#UnfoldBIDS.load_results-Tuple{String}","page":"DocStrings","title":"UnfoldBIDS.load_results","text":"function load_results(bids_root::String;\n    derivatives_subfolder::String=\"Unfold\",\n    lazy::Bool=false,\n    generate_Xs::Bool = true,\n    ses::Union{Nothing,AbstractString}=nothing,\n    task::Union{Nothing,AbstractString}=nothing,\n    run::Union{Nothing,AbstractString}=nothing)\n\nLoad Unfold models existing in a derivatives_subfolder in your BIDS root folder. \n\nKeywords\n\nderivativessubfolder (String::\"Unfold\"): Defines in which subfolder of bidsroot/derivatives to look for Unfold models. lazy (Bool::false): Do not actually load the dataset into memore if true, only return a dataframe with paths generate_Xs (Bool::true): Do not recreate the designmatrix; improves loading time. ses (Union{Nothing,AbstractString}::nothing): Which session to load; loads all if nothing task (Union{Nothing,AbstractString}::nothing): Which task to load; loads all if nothing run (Union{Nothing,AbstractString}::nothing): Which run to load; loads all if nothing\n\n\n\n\n\n","category":"method"},{"location":"api/#UnfoldBIDS.save_results-Tuple{DataFrames.DataFrame, String}","page":"DocStrings","title":"UnfoldBIDS.save_results","text":"save_results(results::DataFrame, bids_root::String; \n    derivatives_subfolder::String=\"Unfold\",\n    overwrite::Bool=false)\n\nFunction to save unfold models in your BIDS root folder. Automatically creates a derivativessubfolder (default = \"Unfold\") in the derivatives and subsequentely safes each model in results according to BIDS. Example of path so saved file: bidsroot/derivatives/Unfold/sub-XXX/eeg/sub-XXXses-XXtask-XXXrun-XXunfold.jld2\n\nKeywords\n\nderivatives_subfolder (String::\"Unfold\"): Creates the named subfolder and saves Unfold models according to BIDS. overwrite (Bool::false): Does not overwrite existing datasets; can be set to true.\n\n\n\n\n\n","category":"method"},{"location":"api/#UnfoldBIDS.unpack_results-Tuple{Any}","page":"DocStrings","title":"UnfoldBIDS.unpack_results","text":"unpack_results(results_df)\n\nUnpack all results into one tidy dataframe/ coeftable.\n\n\n\n\n\n","category":"method"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"EditURL = \"../../../literate/reference/BIDS.jl\"","category":"page"},{"location":"generated/reference/BIDS/#Brain-Imaging-Data-Structure","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"","category":"section"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"If you are using UnfoldBIDS we assume you are already familiar with the BIDS format. However, since the package only works if your dataset is BIDS formatted, here is a quick reminder. If you want a more in-depth explanation, please refer to the official BIDS documentation","category":"page"},{"location":"generated/reference/BIDS/#Folder-Structure","page":"Brain Imaging Data Structure","title":"Folder Structure","text":"","category":"section"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"Folders have to follow the following structure:","category":"page"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"  |-BIDS-Root/\n      |--- [required meta files]\n      |--- sub-<label>/\n          |--- eeg/\n              |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.<extension>\n              |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.json\n              |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.json\n              |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.tsv\n      |--- derivatives/ <- for (pre-processed data)\n         |--- [required meta files]\n         |--- sub-<label>/\n              |--- eeg/\n                  |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.<extension>\n                  |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.json\n                  |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.json\n                  |--- sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.tsv","category":"page"},{"location":"generated/reference/BIDS/#File-formats","page":"Brain Imaging Data Structure","title":"File formats","text":"","category":"section"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"By BIDS standard your files have to be in one of the following formats: EEG","category":"page"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"edf (European Data Fromat; single file)\nvhdr (BrainVision format; file triplet of .vhdr, .vmrk and .eeg)\nset (EEGLAB saved file; .fdt file optional)\nfif (MNE save file; not BIDS conform, but implemented for convenience)","category":"page"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"Events UnfoldBIDS.jl will automatically try to load accompanying events.tsv files. Loading events from the EEG data files is currently not supported, and not BIDS conform.","category":"page"},{"location":"generated/reference/BIDS/#BIDS-Transformation","page":"Brain Imaging Data Structure","title":"BIDS Transformation","text":"","category":"section"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"If your dataset is not yet BIDS conform you can use MNE-BIDS to transform your data.","category":"page"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"","category":"page"},{"location":"generated/reference/BIDS/","page":"Brain Imaging Data Structure","title":"Brain Imaging Data Structure","text":"This page was generated using Literate.jl.","category":"page"},{"location":"generated/reference/overview/","page":"Overview: Toolbox Functions","title":"Overview: Toolbox Functions","text":"EditURL = \"../../../literate/reference/overview.jl\"","category":"page"},{"location":"generated/reference/overview/#Toolbox-overview","page":"Overview: Toolbox Functions","title":"Toolbox overview","text":"","category":"section"},{"location":"generated/reference/overview/","page":"Overview: Toolbox Functions","title":"Overview: Toolbox Functions","text":"","category":"page"},{"location":"generated/reference/overview/","page":"Overview: Toolbox Functions","title":"Overview: Toolbox Functions","text":"This page was generated using Literate.jl.","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"EditURL = \"../../../literate/tutorials/quickstart.jl\"","category":"page"},{"location":"generated/tutorials/quickstart/#1.-Quickstart","page":"Quickstart","title":"1. Quickstart","text":"","category":"section"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"using UnfoldBIDS","category":"page"},{"location":"generated/tutorials/quickstart/#Loading-data","page":"Quickstart","title":"Loading data","text":"","category":"section"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"To load use UnfoldBIDS to find the paths to all subject specific data you can uye the bidsLayout function:","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"\n````@example quickstart\nsample_data = artifact\"sample_BIDS\"\nbids_path = sample_data * \"/Users/ReneS/Desktop/sample_ds/\" # This is currently a bit awkward due to a zip issue; will change in the future\n````\n\nlayout_df = bids_layout(bids_path, derivative=false)","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"This will give you a DataFrame containing the paths too the eeg files of all subjects plus their accompanying event files","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"note: Note\nSince we set the derivative keyword to false here UnfoldBIDS will only look for the raw EEG files. However, by default UnfoldBIDS assumes you have preprocessed data in a derivatives folder and try to look for those.","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"Subsequently, you can load the data of all subjects into memory","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"eeg_df = load_bids_eeg_data(layout_df)","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"note: Note\nThe data is not actually loaded into memory, but uses MNE's lazy loading functionality.","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"UnfoldBIDS trys to load events directly into the DataFrame, however if you are missing the event tsv files you will get a warning and no events are loaded. If that happens you have to manually load these events. The following function might help you with this.","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"events_df = load_events(layout_df)","category":"page"},{"location":"generated/tutorials/quickstart/#Run-unfold-type-models","page":"Quickstart","title":"Run unfold type models","text":"","category":"section"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"resultsAll = run_unfold(eeg_df, events_df, bfDict; channels=nothing, eventcolumn=\"trial_type\")","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"","category":"page"},{"location":"generated/tutorials/quickstart/","page":"Quickstart","title":"Quickstart","text":"This page was generated using Literate.jl.","category":"page"},{"location":"generated/HowTo/ApplyPreprocessing/","page":"Apply preprocessing functions","title":"Apply preprocessing functions","text":"EditURL = \"../../../literate/HowTo/ApplyPreprocessing.jl\"","category":"page"},{"location":"generated/HowTo/ApplyPreprocessing/#Apply-MNE-preprocessing","page":"Apply preprocessing functions","title":"Apply MNE preprocessing","text":"","category":"section"},{"location":"generated/HowTo/ApplyPreprocessing/","page":"Apply preprocessing functions","title":"Apply preprocessing functions","text":"","category":"page"},{"location":"generated/HowTo/ApplyPreprocessing/","page":"Apply preprocessing functions","title":"Apply preprocessing functions","text":"This page was generated using Literate.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = UnfoldBIDS","category":"page"},{"location":"#UnfoldBIDS","page":"Home","title":"UnfoldBIDS","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for UnfoldBIDS.","category":"page"}]
}