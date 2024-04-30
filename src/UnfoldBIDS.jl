module UnfoldBIDS

# basics
using StatsModels, DataFrames, DataFramesMeta, Statistics, Printf
using Dates # For default save folder
using ProgressBars, Continuables
# file loading
using PyMNE, CSV
# unfold
using Unfold


# Loading
include("load.jl")
# Various utils
include("utils.jl")

# Export list
export bids_layout
export load_bids_eeg_data
export collect_events
export run_unfold
export bids_coeftable
export unpack_events, unpack_results
#export epochedFit

import StatsModels.FormulaTerm # for exporting
export FormulaTerm

end
