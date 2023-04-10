function BidsLayout(BIDSPath::AbstractString;
    derivative::Bool=true,
    dFolder::String="",
    exFolder::String="raw",
    task::Union{Nothing,AbstractString}=nothing,
    run::Union{Nothing,AbstractString}=nothing)

    # Any files with these endings will be returned
    file_pattern = ["eeg", "set", "fif", "vhdr", "edf"]

    if task === nothing
        @warn "No task provided, will load all tasks!!"
    else
        file_pattern = push!(file_pattern, "task-" * task)
    end

    if run === nothing
        @warn "No run provided, will load all runs!!"
    else
        file_pattern = push!(file_pattern, "run-" * run)
    end

    # Exclude these folders when using raw data
    exclude = ["derivatives", exFolder]

    # Should a subfolder of derivatives be used?
    derivativeFolder = "derivatives/" * dFolder

    files_df = DataFrame(subject=[], file=[], path=[])  # Initialize an empty DataFrame to hold results

    for (root, dirs, files) in walkdir(BIDSPath)
        for file in files
            if sum(occursin.(file_pattern, file)) >= 2 &&
               ((derivative && occursin(derivativeFolder, root)) ||
                (!derivative && !any(occursin.(exclude, root))))

                sub_string = match(r"sub-\d{3}", file)
                sub = last(sub_string.match, 3)
                push!(files_df, (sub, file, root))
            end
        end
    end
    return files_df
end