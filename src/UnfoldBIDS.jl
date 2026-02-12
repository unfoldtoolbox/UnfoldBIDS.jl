module UnfoldBIDS

# basics
using StatsModels, DataFrames, DataFramesMeta, Statistics, Printf
using ProgressBars, Continuables
using LazyArtifacts
# file loading
using CSV
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
export unpack_events, unpack_results, inspect_events
export save_results, load_results
#export epochedFit

import StatsModels.FormulaTerm # for exporting
export FormulaTerm

checkFun(sym) = Base.get_extension(@__MODULE__(), sym)
function inspect_events(args...; kwargs...)
    ext = checkFun(:UnfoldUnicodePlotsExt)
    msg = "UnicodePlots and/or Term not loaded. Please use ]add UnicodePlots, Term, using UnicodePlots, Term to install them prior to using"
    isnothing(ext) ? throw(msg) : ext.inspect_events(args...; kwargs...)
end

export inspect_events

end
