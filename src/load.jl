function bids_layout(bidsPath::AbstractString;
    derivatives::Bool=true,
    specificFolder::Union{Nothing,AbstractString}=nothing,
    excludeFolder::Union{Nothing,AbstractString}=nothing,
    ses::Union{Nothing,AbstractString}=nothing,
    task::Union{Nothing,AbstractString}=nothing,
    run::Union{Nothing,AbstractString}=nothing)

    # Any files with these endings will be returned
    file_ending = [".eeg", ".set", ".fif", ".vhdr", ".edf"]

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

    # Choose what to ignore and check if derivatives should be used
    exclude = [] 
    if derivatives
        # TODO: Bug in loading only derivatives
        bidsPath = joinpath(bidsPath, "derivatives")
    else
        push!(exclude, "derivatives")
    end

    if excludeFolder !== nothing
        exclude = push!(exclude, excludeFolder)
    end

    # Choose a specific folder in either ./ or ./derivatives
    if specificFolder !== nothing
        bidsPath = joinpath(bidsPath, specificFolder)
    end



    files_df = DataFrame(subject=[], ses=[], task=[], run=[], file=[])  # Initialize an empty DataFrame to hold results

    list_all_eegpaths(path) = @cont begin
        if isfile(path)
            (any(endswith.(path, file_ending)) & all(occursin.(file_pattern, path))) && cont(path)
        elseif isdir(path)
            startswith(basename(path), ".") && return # skip all hidden files/ paths
            if exclude !== nothing
                basename(path) in (exclude...,) && return
            end
            for file in readdir(path)
                foreach(cont, list_all_eegpaths(joinpath(path, file)))
            end
        end
    end

    all_paths = collect(list_all_eegpaths(abspath(bidsPath)))

    # Add additional information
    for path in all_paths
        get_info!(files_df, path)
    end

    # Check for multiple session/tasks/runs
    check_df(files_df, ses, task, run)

    # add events File names
    try
        add_event_files!(files_df)
    catch
        @warn "Something went wrong with tsv file detection. Needs manual intervention."
    end

    return files_df
end

#
# get subject and file information
function get_info!(files_df, file)

    # Make regex for parts
    regex_sub = r"sub-(\d+)"
    regex_ses = r"ses-(.+?)_"
    regex_task = r"task-(.+?)_"
    regex_run = r"run-(\d+)"

    # Match and add to DataFrame
    sub = match(regex_sub, file)
    ses = match(regex_ses, file)
    task = match(regex_task, file)
    run = match(regex_run, file)
    push!(files_df, (
        !isnothing(sub) ? sub.captures[1] : missing,
        !isnothing(ses) ? ses.captures[1] : missing,
        !isnothing(task) ? task.captures[1] : missing,
        !isnothing(run) ? run.captures[1] : missing,
        file))
    return files_df
end

"""
check_df(files_df, ses, task, run)

Internal; Checks if the multiple sessions/task/runs are found if none of these are provided
"""

function check_df(files_df, ses, task, run)
    if ses === nothing && files_df.ses !== missing && length(unique(files_df.ses)) > 1
        @warn "You provided no session, however I found multiple sessions so I loaded all of them! Please check if that was intended."
    end

    if task === nothing && files_df.task !== missing && length(unique(files_df.task)) > 1
        @warn "You provided no task, however I found multiple tasks so I loaded all of them! Please check if that was intended."
    end

    if run === nothing && files_df.run !== missing && length(unique(files_df.run)) > 1
        @warn "You provided no run, however I found multiple runs so I loaded all of them! Please check if that was intended."
    end
end
#-----------------------------------------------------------------------------------------------
# Function loading BIDS data given bidsLayout DataFrame
function load_bids_eeg_data(layout_df; verbose::Bool=true, kwargs...)

    # Initialize an empty dataframe
    eeg_df = DataFrame()

    pbar = ProgressBar(total=size(layout_df, 1))

    # Loop through each EEG data file
    for row in eachrow(layout_df)
        file_path = joinpath(row.path, row.file)
        if verbose
            update(pbar)
            #@printf("Loading subject %s at:\n %s \n",row.subject, file_path)
        end

        # Read in the EEG data as a dataframe using the appropriate reader
        if endswith(file_path, ".edf")
            eeg_data = PyMNE.io.read_raw_edf(file_path, verbose="ERROR")
        elseif endswith(file_path, ".vhdr")
            eeg_data = PyMNE.io.read_raw_brainvision(file_path, verbose="ERROR")
        elseif endswith(file_path, ".fif")
            eeg_data = PyMNE.io.read_raw_fif(file_path, verbose="ERROR")
        elseif endswith(file_path, ".set")
            eeg_data = PyMNE.io.read_raw_eeglab(file_path, verbose="ERROR")
        end

        tmp_df = DataFrame(subject=row.subject, task=row.task, run=row.run, data=eeg_data)

        # TODO: Add events DataFrames as additional collumn per subject

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

#-----------------------------------------------------------------------------------------------

# Function to load events of all subjects from CSV file into DataFrame
# The function is deprecated but kept for convenience
# NOTE: This is old and should be renamed; kept for now

function collect_events(subjects::Vector{Any}, CSVPath::String; delimiter=nothing)
    AllEvents = DataFrame()
    for sub in subjects
        pathFormated = Printf.Format(CSVPath)

        @assert(length(unique(pathFormated.formats)) == 1)

        events = CSV.read(Printf.format(pathFormated, repeat([sub], length(pathFormated.formats))...), DataFrame, delim=delimiter)
        events.subject .= sub
        append!(AllEvents, events)
    end
    return AllEvents
end

#-----------------------------------------------------------------------------------------------
"""
    add_event_files!(layoutDF)

Function to find and load all events file-paths into Layout-DataFrame.
"""

function add_event_files!(layoutDF)

    allFiles = []
    # Do some stuff @byrow, i.e. find the tsv files
    for s in eachrow(layoutDF)
        eegFile = basename(s.file)
        subStr = findlast("eeg", eegFile)[1]
        tmpFile = eegFile[begin:subStr-1] * "events.tsv"

        # Check if file exists
        files = readdir(replace(s.file, basename(eegFile) => "")) # Gives all files as Vector of strings

        tmpIdx = occursin.(tmpFile, files)

        if sum(tmpIdx) == 0
            @show tmpFile
            @error "No events tsv file found! Please make sure to provide tsv files for all subjects"
        elseif sum(tmpIdx) > 1
            @error "Multiple matching .tsv files found" # Add which file was looking for
        end

        evtsFile = files[tmpIdx][1]

        push!(allFiles, evtsFile)

    end

    layoutDF.events = allFiles

    return layoutDF
end

#-----------------------------------------------------------------------------------------------

# Function to find and load all events files into a DataFrame

function load_events(layoutDF::DataFrame; kwargs...)

    all_events = DataFrame()

    for s in eachrow(layoutDF)
        events = CSV.read(joinpath(s.path, s.events), DataFrame; kwargs...)
        #events.subject .= s.subject
        append!(all_events, DataFrame(subject=s.subject, task=s.task, run=s.run, events=events))
    end

    return all_events
end