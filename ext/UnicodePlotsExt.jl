module UnicodePlotsExt
using UnfoldBIDS
using DataFrames, DataFramesMeta
using Statistics
using UnicodePlots, Term
using Printf


"""
    inspect_events(data_df::DataFrame, event_collumn::Symbol; event_name::Union= nothing, subject::Union{String, Int}= "all")
    Inspect an event in the events DataFrame by plotting a unicode histogram and providing summary statistics.\\
    NOTE: At this point in time, `inspect_events()` only allows to inspect numeric events such as duration or reaction time. Categorical events such as trial_type will be implemented in the future.
    
    ## Arguments
    - `data_df::DataFrame`\\
       DataFrame  containing all subjects and their events. Output of [`load_bids_eeg_data`](@ref)\\
    - `event_collumn::Symbol`\\
       The name of the event collumn to inspect (as found in the :events DataFrame of data_df).\\

    ## Keywords
    - `event_name = nothing`\\
       NOTE: This is a future feature. \\
       Specify an event name to inspect only that event. Default is `nothing` to inspect all events in the specified collumn.\\
    - `subject::Union{String, Int} = "all"`\\
       Specify a subject to inspect only its events. Default is "all" to inspect all subjects.
    
"""

function inspect_events(
    data_df::DataFrame,
    event_collumn::Symbol;
    event_name = nothing,
    subject::Union{String,Int} = "all",
)

    # Extract event of interest`
    if subject != "all"
        @assert subject ∈ data_df.subject "Subject $(subject) not found in DataFrame."
        events_df = UnfoldBIDS.@rsubset(data_df, :subject .== subject)[!, :events][1]
    else
        events_df = UnfoldBIDS.unpack_events(data_df)
    end

    @assert names(events_df) ∋ String(event_collumn) "Event $(event_collumn) not found in events DataFrame."

    # Extract event of interest
    if true #isnothing(event_name); TODO future implementation
        d = events_df[:, event_collumn]
    else
        @assert event_name ∈ events_df[:, event_collumn] "Event $(event_name) not found in event collumn $(event_collumn)."
        d = @rsubset(events_df, event_collumn .== event_name)[:, event_collumn]
    end
    name = String(event_collumn)


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

end # module UnicodePlotsExt