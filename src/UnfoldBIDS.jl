module UnfoldBIDS

# basics
using StatsModels, MixedModels, DataFrames, Statistics
# file loading
using PyMNE, CSVFiles, DelimitedFiles
# unfold
using Unfold
# plotting
using AlgebraOfGraphics, GLMakie

# Loading
include("load.jl")
# Various utils
include("utils.jl")

end
