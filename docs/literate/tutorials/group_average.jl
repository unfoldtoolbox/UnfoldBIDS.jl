# # Calculate group averages

using UnfoldBIDS
using Unfold
using DataFrames
using Statistics
using CairoMakie, AlgebraOfGraphics
using LazyArtifacts
using Main: @artifact_str # this is a workaround for Artifacts used in docs; locally you would `using LazyArtifacts`

# First let's redo the steps from the quickstart
sample_data_path = artifact"sample_BIDS"
layout_df = bids_layout(sample_data_path, derivatives=false)
data_df = load_bids_eeg_data(layout_df)

# Calculate results
basisfunction = firbasis(τ=(-0.2,.8),sfreq=1024)
f  = @formula 0~1
bfDict = ["stimulus"=>(f,basisfunction)]
UnfoldBIDS.rename_to_latency(data_df, :sample) # Unfold expects a :latency collumn in your events; if your event latency is named differently you can use this function as remedy

resultsAll = run_unfold(data_df, bfDict; eventcolumn="trial_type");

# Now let's, transform the data into a tidier format
ct = bids_coeftable(resultsAll)
tidy = unpack_results(ct)
@show tidy

# Calculate average over subjects
mean_df = combine(groupby(tidy, [:time, :coefname]), :estimate => mean)

# Importantly, the above can be extended to `groupby`an arbitrary number of covariates!

# Plot results using AOG
data(mean_df) * mapping(:time, :estimate_mean, color = :coefname, group=:coefname => nonnumeric) * visual(Lines) |> draw
