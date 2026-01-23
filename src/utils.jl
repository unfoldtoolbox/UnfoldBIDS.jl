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
- `extract_data::function = nothing`\\
   Specify the function to extract the data to a data array. Falls back to `raw_to_data` which uses `get_data` and allows to pick `channels` if no function is povided AND PyMNE is loaded - see @Ref(`raw_to_data`).
- `verbose::Bool = true)`\\
   Show ProgressBar or not.
- `kwargs...`\\
   Will be passed to *both* the `fit()` and  `extract_data()` calls as function inputs.\\
   For possible kwargs to `fit()` please have a look at the Unfold.jl API: https://unfoldtoolbox.github.io/UnfoldDocs/Unfold.jl/stable/references/functions/
"""
function run_unfold(
    data_df::DataFrame,
    bf_vec;
    remove_time_expanded_Xs = true,
    extract_data::Union{Function,Nothing} = nothing,
    verbose::Bool = true,
    sfreq = nothing,
    kwargs...,
)

    # Init results dataframe
    results_df = DataFrame()

    # Check kwargs
    fit_keys = (
        :fit,
        :contrasts,
        :eventcolumn,
        :solver,
        :show_progress,
        :eventfields,
        :show_warnings,
    )
    fit_kwargs = (; (k => v for (k, v) in pairs(kwargs) if k ∈ fit_keys)...)
    extract_data_kwargs = (; (k => v for (k, v) in pairs(kwargs) if k ∉ fit_keys)...)

    # Init progress bar
    pbar = ProgressBar(total = size(data_df, 1))

    for row in eachrow(data_df)

        if verbose
            update(pbar)
            #@printf("Loading subject %s \n",row.subject)
        end

        tmp_events = row.events

        # Assert if first eventfield in events
        # @assert String(eventfields[1]) ∈ names(tmp_events) "Eventfield $(eventfields[1]) not found in events DataFrame. This field is required to define event onsets. Please set the eventfields argument to the collumn that defines your event onsets (in samples)."


        ext_mne = Base.get_extension(@__MODULE__, :MNEext)

        if !isnothing(ext_mne) && extract_data == nothing # Fallback to MNE data extraction if MNE is loaded and no extract_data function is provided
            tmp_data = ext_mne.raw_to_data(row.raw; extract_data_kwargs...)

        elseif extract_data !== nothing # Use user provided data extraction function
            tmp_data = extract_data(row.raw; extract_data_kwargs...)
        else
            error(
                "It seems you have neither loaded PyMNE, nor provided your own data extraction function. If you want to fall back to extract data via raw.get_data simply use ]add PyMNE.jl and using PyMNE to install/ load.",
            )
        end


        # Check for type of model to fit
        tmp = last(bf_vec[1])

        # Fit Overlap Corrected Model if BasisFunction is used
        if supertype(typeof(tmp[2])) == Unfold.BasisFunction
            m = fit(UnfoldModel, bf_vec, tmp_events, tmp_data; fit_kwargs...)

            # Fit Mass-Univariate Model if time window tuple is used
        elseif typeof(tmp[2]) == Tuple{Real,Real}
            @assert size(bf_vec, 1) == 1 && bf_vec[1][1] != Any "Currently only one event type is supported for Mass-Univariate models with UnfoldBIDS. Please change your bf_vec accordingly."

            # Get sfreq from raw
            @assert sfreq !== nothing "It seems you want to run a Mass Univariate model, but zou have not privided the Sampling frequency (sfreq). Please provide sfreq as a keyword argument to run_unfold."

            # Epoch data
            evts = @rsubset(tmp_events, :event .== bf_vec[1][1])
            data_epochs, times =
                Unfold.epoch(data = tmp_data, tbl = evts, τ = tmp[2], sfreq = sfreq)

            # Fit Mass-Univariate Model
            m = fit(UnfoldModel, tmp[1], data_epochs, times; fit_kwargs...)

        end

        if remove_time_expanded_Xs &&
           (m isa UnfoldLinearModel || m isa UnfoldLinearModelContinuousTime)
            #m = typeof(m)(m.design, Unfold.DesignMatrix(designmatrix(m).formulas, missing, designmatrix(m).events), m.modelfit)
            m.designmatrix = [
                typeof(m.designmatrix[k])(
                    Unfold.formulas(m)[k],
                    Unfold.empty_modelmatrix(designmatrix(m)[k]),
                    Unfold.events(m)[k],
                ) for k = 1:length(m.designmatrix)
            ]
        end

        results = DataFrame(
            subject = row.subject,
            ses = row.ses,
            task = row.task,
            run = row.run,
            model = m,
        )

        append!(results_df, results)


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
        tmp_df = DataFrame(
            subject = row.subject,
            ses = row.ses,
            task = row.task,
            run = row.run,
            results = tmp_table,
        )
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
        tmp_df = effects(effects_dict, row.model)

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
    for row in eachrow(data_df)
        row.events.latency = row.events[!, symbol]
    end
end

"""
	list_all_paths(path)

Internal function to find pathfiles
"""
list_all_paths(path, file_ending, file_pattern; exclude = nothing) = @cont begin
    if isfile(path)
        startswith(basename(path), ".") && return # skip all hidden files
        (any(endswith.(path, file_ending)) & all(occursin.(file_pattern, path))) &&
            cont(path)
    elseif isdir(path)
        startswith(basename(path), ".") && return # skip all hidden paths
        if exclude !== nothing
            basename(path) in (exclude...,) && return
        end
        for file in readdir(path)
            foreach(
                cont,
                list_all_paths(
                    joinpath(path, file),
                    file_ending,
                    file_pattern,
                    exclude = exclude,
                ),
            )
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

"""
    inspect_event(data_df::DataFrame, event_name::Symbol; subject::Union{String, Int}= "all")
    Inspect an event in the events DataFrame by plotting a unicode histogram and providing summary statistics.
    
    ## Arguments
    - `data_df::DataFrame`\\
       DataFrame  containing all subjects and their events. Output of [`load_bids_eeg_data`](@ref)\\
    - `event_name::Symbol`\\
       The name of the event to inspect (as found in the :event collumn of events_df).\\

    ## Keywords
    - `subject::Union{String, Int} = "all"`\\
       Specify a subject to inspect only its events. Default is "all" to inspect all subjects.
    
"""

function inspect_events(data_df::DataFrame, event_name::Symbol; subject::Union{String, Int}= "all")

    # Extract event of interest`
    if subject != "all"
        @assert subject ∈ data_df.subject "Subject $(subject) not found in DataFrame."
        events_df = @rsubset(data_df, :subject .== string(subject)).events
    else
        events_df = UnfoldBIDS.unpack_events(data_df)
    end
    
    @assert names(events_df) ∋ event_name "Event $(event_name) not found in events DataFrame."

    # Extract event of interest
    d = events_df[:, event_name]
    name = String(event_name)


    # Function to plot unicode histogram
    h(name, d) =
        TextBox(
            @sprintf(
                "{bold}%s{/bold} \nμ=%.2f,σ=%.2f\nmin=%.2f\nmax=%.2f",
                name,
                mean(d),
                std(d),
                minimum(d),
                maximum(d)
            ),
            fit = true,
        ) * (
            histogram(
                d,
                vertical = true,
                height = 1,
                grid = false,
                stats = false,
                labels = false,
                border = :none,
                padding = 1,
                margin = 0,
            ) |> UnicodePlots.panel
        )

    h(name, d) |> print

end