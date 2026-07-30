using UnfoldBIDS 
using UnicodePlots, Term # Both UnocodePlots and Term are needed to inspect events in the events DataFrame
using LazyArtifacts



# # Load the sample data
sample_data_path = UnfoldBIDS.erp_core_example()
layout_df = bids_layout(sample_data_path, derivatives = false)
data_df = load_bids_eeg_data(layout_df)

# ## Change events
# Our events don't have a duration column, so we will add one.

for row in eachrow(data_df)
    i = 1
    while i < size(row.events, 1)
        if row.events[i, :trial_type] == "stimulus" && row.events[i+1, :trial_type] == "response"
            row.events[i:i+1, :duration] .= row.events[i+1, :onset] - row.events[i, :onset]
        end
        i += 1
    end
end

# # Inspect events

# !!! note
#       At this point in time, `inspect_events()` only allows to inspect numeric events such as duration or reaction time. Categorical events such as trial_type will be implemented in the future.

# Now we can inspect the events of either all subjects

inspect_events(data_df, :duration)

# Or we can inspect the events of a single subject
inspect_events(data_df, :duration; subject = "001")