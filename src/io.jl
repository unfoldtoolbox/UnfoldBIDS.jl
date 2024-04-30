# Input/ Output of Unfold results


function save_results(results::DataFrame, bids_root::String; 
    save_folder::String="Unfold",
    overwrite::Bool=false)

    # Make folder to save in
    save_in = joinpath(bids_root, "derivatives", save_folder)
    if !isdir(save_in)
        mkdir(save_in)
    end

    for row in eachrow(results)
        
        # Make folder for subject
        tmp_folder = joinpath(save_in, row.subject, "eeg")
        mkdir(tmp_folder)

        # Make a filename based on available data
        file_name = "sub-" * row.subject
        if !ismissing(row.ses); file_name = file_name * "ses-" * row.ses; end
        if !ismissing(row.task); file_name = file_name * "task-" * row.task; end
        if !ismissing(row.run); file_name = file_name * "run-" * row.run; end
        file_name = file_name * ".jld2"
        
        save(joinpath(tmp_folder, file_name), row.model; compress = true);

    end

end