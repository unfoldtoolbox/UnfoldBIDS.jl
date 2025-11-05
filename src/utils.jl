"""
	run_unfold(data_df, bf_vec; 
		remove_time_expanded_Xs=true, 
		extract_data = raw_to_data, 
		verbose::Bool=true, 
		kwargs...)

Run Unfold analysis on all data in data_df. Needs to have PyMNE.jl loaded!

## Arguments
- `data_df::DataFrame`\\
   DataFrame containing BIDS data as returned by `load_bids_data()`. Must contain collumns: :subject, :ses, :task, :run, :raw, :events
- `bf_vec`\\
   Basis function vector as expected by Unfold.jl's `fit()` function.\\
	Can be one of: \\
	- `["eventname" => (formula, basisfunction)]` for overlap corrected models
	- `["eventname" => (formula, timewindow)]` for mass-univariate models, where indicates (start, stop) in seconds with `typeof(timewindow) = Tuple{Real, Real}`

## Keywords

- `remove_time_expanded_Xs::Bool = true`\\
   Removes the timeexpanded designmatrix which significantly reduces the memory-consumption. This Xs is rarely needed, but can be recovered (look into the Unfold.load function)
- `extract_data::function = raw_to_data`\\
   Specify the function that translate the MNE Raw object to an data array. Default is `raw_to_data` which uses `get_data` and allows to pick `channels` - see @Ref(`raw_to_data`). The optional kw- arguments (e.g. channels) need to be specified directly in the `run_unfold` function as kw-args
- `verbose::Bool = true)`\\
   Show ProgressBar or not.
- `kwargs...`\\
   Will be passed to *both* the `fit()` and  `extract_data()` calls as function inputs.\\
   For possible kwargs to `fit()` please have a look at the Unfold.jl API: https://unfoldtoolbox.github.io/UnfoldDocs/Unfold.jl/stable/references/functions/
"""
function run_unfold(args...; kwargs...)
	ext_mne = Base.get_extension(@__MODULE__, :MNEext)
   if !isnothing(ext_mne)
      results_df = ext_mne._run_unfold(args...; kwargs...)
   else
      error("PyMNE is needed to handle MNE Raw objects. Please make sure to load PyMNE.jl explicitly. Use ]add PyMNE.jl and using PyMNE to install/ load it.")
   end
    return results_df
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
	select!(all_events, :subject, :ses, :task, :run, Not([:subject, :ses, :task, :run]))
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
	bids_effects(model_df::DataFrame, effects_dict::Dict)

Calculate [mariginalized effect](https://unfoldtoolbox.github.io/UnfoldDocs/Unfold.jl/stable/generated/HowTo/effects/) on all subjects found in the model dataframe using `effects_dict`.
"""
function bids_effects(model_df::DataFrame, effects_dict::Dict)

	all_results = DataFrame()
	for row in eachrow(model_df)
		tmp_df = effects(effects_dict, row.model);

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
	rename_to_latency(data_df)

This is a convenience function to add a :latency collumn (needed by Unfold) based on another variable in the events_df (e.g. sample)
"""
function rename_to_latency(data_df, symbol::Symbol)
	for row in eachrow(data_df); row.events.latency = row.events[!,symbol]; end
end

"""
	list_all_paths(path)

Internal function to find pathfiles
"""
list_all_paths(path, file_ending, file_pattern; exclude=nothing) = @cont begin
	if isfile(path)
		startswith(basename(path), ".") && return # skip all hidden files
		(any(endswith.(path, file_ending)) & all(occursin.(file_pattern, path))) && cont(path)
	elseif isdir(path)
		startswith(basename(path), ".") && return # skip all hidden paths
		if exclude !== nothing
			basename(path) in (exclude...,) && return
		end
		for file in readdir(path)
			foreach(cont, list_all_paths(joinpath(path, file), file_ending, file_pattern, exclude=exclude))
		end
	end
end

"""
path = erp_core_example()

	Convenience function to load a BIDS conform folder containing three subjects of the P300 task of ERP-Core dataset.
	Returns path to BIDS root folder
"""

function erp_core_example()
	path = artifact"sample_BIDS"
	return path
end