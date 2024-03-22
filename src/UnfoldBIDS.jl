module UnfoldBIDS

# basics
using StatsModels, DataFrames, DataFramesMeta, Statistics, Printf
using ProgressBars
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
#export epochedFit

import StatsModels.FormulaTerm # for exporting
export FormulaTerm

end
