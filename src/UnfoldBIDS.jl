module UnfoldBIDS

# basics
using StatsModels, DataFrames, DataFramesMeta, Statistics, Printf
using ProgressBars
# file loading
#using PyMNE, CSVFiles, DelimitedFiles, Glob
using PyMNE, CSV
# unfold
using Unfold


# Loading
include("load.jl")
# Various utils
include("utils.jl")

# Export list
export bidsLayout
export load_bids_eeg_data
export collectEvents
export runUnfold
#export epochedFit

import StatsModels.FormulaTerm # for exporting
export FormulaTerm

end
