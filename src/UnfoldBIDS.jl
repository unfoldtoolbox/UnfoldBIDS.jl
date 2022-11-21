module UnfoldBIDS

# basics
using StatsModels, MixedModels, DataFrames, Statistics
# file loading
using PyMNE, CSVFiles, DelimitedFiles, Glob
# unfold
using Unfold


# Loading
include("load.jl")
# Various utils
include("utils.jl")

# Export list
export BIDSpath, loadRaw
export populateRaw
export addDefaultEventformulas!
export epochedFit

import StatsModels.FormulaTerm # for exporting
export FormulaTerm

end
