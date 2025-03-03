module UnfoldBIDS

# basics
using StatsModels, DataFrames, DataFramesMeta, Statistics, Printf
using ProgressBars, Continuables
using LazyArtifacts
# file loading
using PyMNE, CSV
# unfold
using Unfold


# Loading
include("load.jl")
# Save/load
include("io.jl")
# Various utils
include("utils.jl")

# Export list
export bids_layout
export load_bids_eeg_data
export collect_events
export run_unfold
export bids_coeftable, bids_effects
export unpack_events, unpack_results
export save_results, load_results
#export epochedFit

import StatsModels.FormulaTerm # for exporting
export FormulaTerm

end
