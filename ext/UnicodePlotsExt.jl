module UnicodePlotsExt
using UnfoldBIDS
using DataFrames, DataFramesMeta
using Statistics
using UnicodePlots, Term
using Printf


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

function inspect_events(
    data_df::DataFrame,
    event_name::Symbol;
    subject::Union{String,Int} = "all",
)

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

end # module UnicodePlotsExt