"""
	run_unfold(dataDF, bfDict; 
		eventcolumn="event",
		removeTimeexpandedXs=true, 
		extract_data = raw_to_data, 
		verbose::Bool=true, 
		kwargs...)

Run Unfold analysis on all data in dataDF.

# Keywords
eventcolumn (String::"event"): Which collumn Unfold should use during the analysis.
removeTimeexpandedXs (Bool::true): Removes the timeexpanded designmatrix which significantly reduces the memory-consumption. This Xs is rarely needed, but can be recovered (look into the Unfold.load function)
extractData (functionraw_to_data): Specify the function that translate the MNE Raw object to an data array. Default is `rawToData` which uses get_data and allows to pick `channels` - see @Ref(`raw_to_data`). The optional kw- arguments (e.g. channels) need to be specified directly in the `run_unfold` function as kw-args
verbose (Bool::true): Show ProgressBar or not.
"""

function run_unfold(dataDF, bfDict; eventcolumn="event",removeTimeexpandedXs=true, extract_data = raw_to_data, verbose::Bool=true, kwargs...)

    resultsDF = DataFrame()

	pbar = ProgressBar(total=size(dataDF, 1))

    for row in eachrow(dataDF)

		if verbose
            update(pbar)
            #@printf("Loading subject %s at:\n %s \n",row.subject, file_path)
        end

        tmpEvents = row.events

        tmpData = extract_data(row.data; kwargs...)


        # Fit Model
        m = fit(UnfoldModel, bfDict, tmpEvents, tmpData; eventcolumn=eventcolumn)

        if removeTimeexpandedXs && (m isa UnfoldLinearModelContinuousTime || m isa UnfoldLinearModelContinuousTime)
            m = typeof(m)(m.design, Unfold.DesignMatrix(designmatrix(m).formulas, missing, designmatrix(m).events), m.modelfit)
        end
        results = DataFrame(subject = row.subject, ses=row.ses, task=row.task, run=row.run,  model = m)

        append!(resultsDF, results)


    end
    return resultsDF
end

"""
	raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=[])


Function to get data from MNE raw object. Can choose specific channels; default loads all channels.
"""

# Function to run Preprocessing functions on data
function raw_to_data(raw; channels::AbstractVector{<:Union{String,Integer}}=[])
    return pyconvert(Array, raw.get_data(picks=pylist(channels), units="uV"))
end

"""
	unpack_events(df::DataFrame)

Unpack events into tidy data frame; useful with AlgebraOfGraphics.jl

df is expected to be a UnfoldBIDS DataFrame where events are loaded already.
"""

function unpack_events(df::DataFrame)

	all_events = DataFrame()
	for row in eachrow(df)
		tmp_df = row.events
		tmp_df.subject .= row.subject
		tmp_df.ses .= row.ses
		tmp_df.task .= row.task
		tmp_df.run .= row.run
		append!(all_events, tmp_df)
	end
	# Change collumn order to look nicer
	select!(all_results, :subject, :ses, :task, :run, Not([:subject, :ses, :task, :run]))
	return all_events
end

"""
	bids_coeftable(model_df)

Turns all models found in model_df into tydy DataFrames and aggregates them in a new DataFrame.
"""

function bids_coeftable(model_df)

	all_results = DataFrame()
	for row in eachrow(model_df)
		tmp_table = coeftable(row.model)
		tmp_df = DataFrame(subject = row.subject, ses=row.ses, task=row.task, run=row.run,  results = tmp_table)
		append!(all_results, tmp_df)
	end

	return all_results
end

"""
	unpack_results(results_df)

Unpack all results into one tidy dataframe/ coeftable.
"""
function unpack_results(results_df)

	all_results = DataFrame()
	for row in eachrow(results_df)
		tmp_df = row.results
		tmp_df.subject .= row.subject
		tmp_df.ses .= row.ses
		tmp_df.task .= row.task
		tmp_df.run .= row.run
		append!(all_results, tmp_df)
	end
	# Change collumn order to look nicer
	select!(all_results, :subject, :ses, :task, :run, Not([:subject, :ses, :task, :run]))

	return all_results
end

"""
	add_latency_from_df(data_df)

This is a convenience function to add a :latency collumn (needed by Unfold) based on another variable in the events_df (e.g. sample)
"""

function add_latency_from_df(data_df, symbol::Symbol)
	for row in eachrow(data_df); row.events.latency = row.events[!,symbol]; end
end

"""
	list_all_paths(path)

Internal function to find pathfiles
"""
list_all_paths(path, file_ending, file_pattern; exclude=nothing) = @cont begin
	if isfile(path)
		(any(endswith.(path, file_ending)) & all(occursin.(file_pattern, path))) && cont(path)
	elseif isdir(path)
		startswith(basename(path), ".") && return # skip all hidden files/ paths
		if exclude !== nothing
			basename(path) in (exclude...,) && return
		end
		for file in readdir(path)
			foreach(cont, list_all_paths(joinpath(path, file), file_ending, file_pattern, exclude=exclude))
		end
	end
end