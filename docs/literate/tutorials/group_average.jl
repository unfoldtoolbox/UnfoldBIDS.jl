# # Calculate group averages

using UnfoldBIDS
using Unfold
using DataFrames
using LazyArtifacts
using Main: @artifact_str # this is a workaround for Artifacts used in docs; locally you would `using LazyArtifacts`

# Load data
sample_data_path = artifact"sample_BIDS"
layout_df = bids_layout(sample_data_path, derivatives=false)
data_df = load_bids_eeg_data(layout_df)

# Calculate results
basisfunction = firbasis(τ=(-0.2,.8),sfreq=1024)
f  = @formula 0~1
bfDict = ["stimulus"=>(f,basisfunction)]
UnfoldBIDS.rename_to_latency(data_df, :sample) # Unfold expects a :latency collumn in your events; if your event latency is named differently you can use this function as remedy

resultsAll = run_unfold(data_df, bfDict; eventcolumn="trial_type");

# Transform data into tidier format
ct = bids_coeftable(resultsAll)
tidy = unpack_results(ct)
@show tidy

# Calculate average over subjects
stim_mean_df = combine(groupby(tidy, [:time, :trial_type]), :yhat => mean)

# Importantly, the above can be extended to `groupby`an arbitrary number of covariates!
