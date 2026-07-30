# Input/ Output of Unfold results
"""
    save_results(results::DataFrame, bids_root::String; 
        derivatives_subfolder::String="Unfold",
        overwrite::Bool=false)

Function to save unfold models in your BIDS root folder. Automatically creates a `derivatives_subfolder` (default = "Unfold") in the derivatives and subsequentely safes each model in results according to BIDS.
Example of path to saved file: `bids_root/derivatives/Unfold/sub-XXX/eeg/sub-XXX_ses-XX_task-XXX_run-XX_unfold.jld2`

# Keywords

- `derivatives_subfolder::String = "Unfold"`\\
   Creates the named subfolder and saves Unfold models according to BIDS.
- `overwrite::Union{Bool,String} = false`\\
   Does not overwrite existing datasets, i.e. skips already existing datasets (according to subject specific datapath/filename) and give a warning; can be set to true in which case already existing data will be silently overwritten. If set to a string, the string will be prepended to the filename of a saved subject model if it already exists.
"""
function save_results(results::DataFrame, bids_root::String;
    derivatives_subfolder::String="Unfold",
    overwrite::Union{Bool,String}=false)

    # Make folder to save in
    save_in = joinpath(bids_root, "derivatives", derivatives_subfolder)
    if !isdir(save_in) && isdir(bids_root)
        mkdir(save_in)
    elseif !isdir(bids_root)
        throw("$bids_root does not exists.")
    end

    for row in eachrow(results)

        # Make folder for subject
        tmp_folder = joinpath(save_in, "sub-" * row.subject, "eeg")
        mkpath(tmp_folder)

        # Make a filename based on available data
        file_name = "sub-" * row.subject
        if !ismissing(row.ses)
            file_name = file_name * "_ses-" * row.ses
        end
        if !ismissing(row.task)
            file_name = file_name * "_task-" * row.task
        end
        if !ismissing(row.run)
            file_name = file_name * "_run-" * row.run
        end
        file_name = file_name * "_unfold.jld2"

        fullfile_path = joinpath(tmp_folder, file_name)
        if !overwrite && !isfile(fullfile_path)
            save(fullfile_path, row.model; compress=true)
        elseif !overwrite && isfile(fullfile_path)
            @warn("overwrite is set to false and I found a subject with already saved results in the folder $save_in
            If you're sure you want to overwrite this data, please set overwrite=true, skipping subject for now.
            Subject file: $file_name")
            continue
        elseif typeof(overwrite) == String && isfile(fullfile_path)
            file_name = overwrite * file_name
            fullfile_path = joinpath(tmp_folder, file_name)
            save(fullfile_path, row.model; compress=true)
        else
            save(fullfile_path, row.model; compress=true)
        end
    end

end

"""
    load_results(bids_root::String;
        derivatives_subfolder::String="Unfold",
        lazy::Bool=false,
        generate_Xs::Bool = true,
        ses::Union{Nothing,AbstractString}=nothing,
        task::Union{Nothing,AbstractString}=nothing,
        run::Union{Nothing,AbstractString}=nothing)

Load Unfold models existing in a `derivatives_subfolder` in your BIDS root folder. 

# Keywords

- `derivatives_subfolder::String = "Unfold"`\\
   Defines in which subfolder of bids_root/derivatives to look for Unfold models.
- `lazy::Bool = false`\\
   Do not actually load the dataset into memore if true, only return a dataframe with paths
- `generate_Xs::Bool = true`\\
   By default recreate the designmatrix; Can be set to false, to improve loading time.
- `ses::Union{Nothing,AbstractString} = nothing`\\
   Which session to load; loads all if nothing
- `task::Union{Nothing,AbstractString} = nothing`\\
   Which task to load; loads all if nothing
- `run::Union{Nothing,AbstractString} = nothing`\\
   Which run to load; loads all if nothing
"""
function load_results(bids_root::String;
    derivatives_subfolder::String="Unfold",
    lazy::Bool=false,
    generate_Xs::Bool = true,
    ses::Union{Nothing,AbstractString}=nothing,
    task::Union{Nothing,AbstractString}=nothing,
    run::Union{Nothing,AbstractString}=nothing)

    # Correct path
    path = joinpath(bids_root, "derivatives", derivatives_subfolder)

    # Any files with these endings will be returned
    file_ending = [".jld2"]

    file_pattern = [""]
    # Extend file pattern
    if ses !== nothing
        file_pattern = push!(file_pattern, "ses-" * ses)
    end

    if task !== nothing
        file_pattern = push!(file_pattern, "task-" * task)
    end

    if run !== nothing
        file_pattern = push!(file_pattern, "run-" * run)
    end

    all_paths = collect(list_all_paths(abspath(path), file_ending, file_pattern, exclude=nothing))

    if isempty(all_paths)
        throw("No results files found at $path; make sure you have the right path and that your directory is BIDS compatible.")
    end

    files_df = DataFrame(subject=[], ses=[], task=[], run=[], file=[])  # Initialize an empty DataFrame to hold results

    # Add additional information
    for path in all_paths
        extract_subject_id!(files_df, path)
    end

    # Check for multiple session/tasks/runs
    check_df(files_df, ses, task, run)

    # Actually load data
    if !lazy
        return _load_results(files_df, generate_Xs)
    else
        return files_df
    end

end

"""
    _load_results(files_df; generate_Xs::Bool = true)

Internal function to load Unfold models into memory. Can also be used to load data after file information was loaded lazily (lazy=true) using [`load_results()`](@ref)
"""
function _load_results(files_df, generate_Xs::Bool = true)

    results_df = DataFrame()
    for row in eachrow(files_df)
        tmp_data = load(row.file, UnfoldModel, generate_Xs = generate_Xs);
        tmp_df = DataFrame(subject=row.subject, ses=row.ses, task=row.task, run=row.run, model=tmp_data)

        append!(results_df, tmp_df)
    end
    return results_df
end
