module UnfoldBIDS

# Export list
export loadRaw
export populateRaw
export addDefaultEventformulas!
export epochedFit


# basics
using StatsModels, MixedModels, DataFrames, Statistics
# file loading
using PyMNE, CSVFiles, DelimitedFiles
# unfold
using Unfold
# plotting
using AlgebraOfGraphics, CairoMakie

# Loading
include("load.jl")
# Various utils
include("utils.jl")

end
