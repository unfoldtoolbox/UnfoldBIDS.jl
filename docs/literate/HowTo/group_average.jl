# # Calculate group averages

using UnfoldBIDS
using Unfold
using DataFrames
using Statistics
using CairoMakie, AlgebraOfGraphics
using LazyArtifacts
using Main: @artifact_str # this is a workaround for Artifacts used in docs; locally you would `using LazyArtifacts`

# ## Analysis
# First let's redo the steps from the quickstart tutorial
sample_data_path = artifact"sample_BIDS"
layout_df = bids_layout(sample_data_path, derivatives=false);
data_df = load_bids_eeg_data(layout_df);

# Calculate results
basisfunction = firbasis(τ=(-0.2,.8),sfreq=1024)
f  = @formula 0~1
bfDict = ["stimulus"=>(f,basisfunction)]
UnfoldBIDS.rename_to_latency(data_df, :sample); # Unfold expects a :latency collumn in your events; if your event latency is named differently you can use this function as remedy

resultsAll = run_unfold(data_df, bfDict; eventcolumn="trial_type");

# Now, let's transform the data into a tidier format (Note: We use raw data without a high-pass filter here so estimates will be quite off)
tidy_df = unpack_results(bids_coeftable(resultsAll))
first(tidy_df, 5)

# ## Calculate average over subjects
mean_df = combine(groupby(tidy_df, [:time, :coefname]), :estimate => mean)
first(mean_df, 5)

# Importantly, the above can be extended to `groupby`an arbitrary number of covariates!

# ## Plot results using AOG
plt = data(mean_df) * mapping(:time, :estimate_mean, color = :coefname, group=:coefname => nonnumeric) * visual(Lines)
draw(plt, axis=(yticklabelsvisible=false,))
