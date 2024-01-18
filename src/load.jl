function bidsLayout(bidsPath::AbstractString;
    derivative::Bool=true,
    specificFolder::Union{Nothing,AbstractString}=nothing,
    excludeFolder::Union{Nothing,AbstractString}=nothing,
    ses::Union{Nothing,AbstractString}=nothing,
    task::Union{Nothing,AbstractString}=nothing,
    run::Union{Nothing,AbstractString}=nothing)

    # Any files with these endings will be returned
    file_pattern = ["eeg", "set", "fif", "vhdr", "edf"]
    nPattern = 2

    # Extend file pattern
    if ses === nothing
        @warn "No session provided, will load all sessions!!"
    else
        file_pattern = push!(file_pattern, "ses-" * ses)
        nPattern += 1
    end

    if task === nothing
        @warn "No task provided, will load all tasks!!"
    else
        file_pattern = push!(file_pattern, "task-" * task)
        nPattern += 1
    end

    if run === nothing
        @warn "No run provided, will load all runs!!"
    else
        file_pattern = push!(file_pattern, "run-" * run)
        nPattern += 1
    end

    # Choose a specific folder in either ./ or ./derivatives
    if derivative && specificFolder !== nothing
        sPath = joinpath(bidsPath, "derivatives", specificFolder)
        #@show sPath
    elseif specificFolder !== nothing
        sPath = joinpath(bidsPath, specificFolder)
        #@show sPath
    end

    # Exclude these folders when using raw data
    if derivative && excludeFolder !== nothing
        exclude = excludeFolder
    elseif !derivative && excludeFolder !== nothing
        exclude = ["derivatives", excludeFolder]
    elseif !derivative
        exclude = "derivatives"
    else
        exclude = ""
    end


    files_df = DataFrame(subject=[], file=[], path=[])  # Initialize an empty DataFrame to hold results

    # Search for files matching file pattern
    if specificFolder !== nothing
        for (root, dirs, files) in walkdir(sPath)
            for file in files
                if sum(occursin.(file_pattern, file)) >= nPattern

                    sub_string = match(r"sub-\d{3}", file)
                    sub = last(sub_string.match, 3)
                    push!(files_df, (sub, file, root))
                end
            end
        end

        # When no specific folder is given look up whole Path    
    else
        for (root, dirs, files) in walkdir(bidsPath)
            for file in files
                if sum(occursin.(file_pattern, file)) >= nPattern &&
                   (derivative && (exclude == "" || !any(occursin.(exclude, root))) ||
                    (!derivative && !any(occursin.(exclude, root))))
                    sub_string = match(r"^sub-\d{1,}", file)
                    sub = split(sub_string.match, "sub-")[2] # always #2 because the regexp has a lookup from front ^

                    push!(files_df, (sub, file, root))
                end
            end
        end
    end

    # add events File names
    # TODO: Check if adding events paths to the dataframe actually works; R.S. 01/24
    try
        addEventFiles!(files_df)
    catch
        @warn "Something went wrong with tsv file detection. Needs manual intervention."
    end

    return files_df
end

#-----------------------------------------------------------------------------------------------
# Function loading BIDS data given bidsLayout DataFrame
function load_bids_eeg_data(layout_df; verbose::Bool=true)

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

        #############
        # TODO: Append specific subject data to dataframe
        #############
        # Add the EEG data to the main dataframe, along with subject and task information
        #subject_id, task_id = match(r"sub-(.+)_task-(.*)_eeg", basename(file_path)).captures
        #eeg_data.subject_id .= subject_id
        #eeg_data.task_id .= task_id
        tmp_df = DataFrame(subject=row.subject, data=eeg_data)

        # TODO: Add events DataFrames as additional collumn per subject

        append!(eeg_df, tmp_df)
    end

    # Return the combined EEG data dataframe
    return eeg_df
end
#-----------------------------------------------------------------------------------------------

# Function loading BIDS data directly by calling bidsLayout
#=
function load_bids_eeg_data(bidsPath::AbstractString;
							derivative::Bool=true,
							specificFolder::Union{Nothing,AbstractString}=nothing,
							excludeFolder::Union{Nothing,AbstractString}=nothing,
							task::Union{Nothing,AbstractString}=nothing,
							run::Union{Nothing,AbstractString}=nothing)

	    # Find all EEG data files in the BIDS directory
		layout_df = bidsLayout(bidsPath=bidsPath;
								derivative=derivative,
								specificFolder=specificFolder,
								excludeFolder=excludeFolder,
								task=task,
								run=run)

	    # Initialize an empty dataframe
	    eeg_df = DataFrame()

	    # Loop through each EEG data file
	    for row in eachrow(layout_df)
			file_path = joinpath(row.path,row.file)
			@printf("Loading subject %s at:\n %s \n",row.subject, file_path)

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

			#############
			# TODO: Append specific subject data to dataframe
			#############
			# Add the EEG data to the main dataframe, along with subject and task information
	        #subject_id, task_id = match(r"sub-(.+)_task-(.*)_eeg", basename(file_path)).captures
	        #eeg_data.subject_id .= subject_id
	        #eeg_data.task_id .= task_id
	        tmp_df = DataFrame(subject = row.subject, data = eeg_data)

			append!(eeg_df, tmp_df)
	    end

	    # Return the combined EEG data dataframe
	    return eeg_df
	end
=#


#-----------------------------------------------------------------------------------------------

# Function to load events of all subjects from CSV file into DataFrame
# The function is deprecated but kept for convenience

function collectEvents(subjects::Vector{Any}, CSVPath::String; delimiter=nothing)
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

# Function to find and load all events file-paths into LayoutDataFrame

function addEventFiles!(layoutDF)

    allFiles = []
    # Do some stuff @byrow, i.e. find the tsv files
    for s in eachrow(layoutDF)
        eegFile = s.file
        subStr = findlast("eeg", eegFile)[1]
        tmpFile = eegFile[begin:subStr-1] * "events.tsv"

        # Check if file exists
        files = readdir(s.path) # Gives all files as Vector of strings

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
		events = CSV.read(joinpath(s.path,s.events),DataFrame; kwargs...)
		events.subject .= s.subject
		append!(all_events, events)
	end
	
	return all_events
end