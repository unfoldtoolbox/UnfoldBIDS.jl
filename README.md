# UnfoldBIDS [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://reneskukies.github.io/UnfoldBIDS.jl/stable) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://reneskukies.github.io/UnfoldBIDS.jl/dev) [![Build Status](https://github.com/reneskukies/UnfoldBIDS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/reneskukies/UnfoldBIDS.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/reneskukies/UnfoldBIDS.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/reneskukies/UnfoldBIDS.jl)

Sub/Wrapper-Package of Unfold.jl. Ultimately it should provide the means to automatically load a Dataset in BIDS format and apply unfold-style processing to it. 

## Current Functionality

```julia
using UnfoldBIDS

# To look up the paths of all subjects and store in a Dataframe:
layout_df = BidsLayout(BIDSPath::AbstractString; # Path to BIDS root folder
                     derivative::Bool=true, # Do you want to us the derivative/ processed data? Default = true
                     specificFolder::Union{Nothing,AbstractString}=nothing, # If you want a specific folder in derivatives or root specify here
                     excludeFolder::Union{Nothing,AbstractString}=nothing, # You can exclude specific folders when not looking for a specific sub-folder 
                     task::Union{Nothing,AbstractString}=nothing, # Specify task; will load all tasks if not specified
                     run::Union{Nothing,AbstractString}=nothing) # Specify run; will load all runs if not specified
           
# To load all data into memory/ one dataframe:           
eeg_df = load_bids_eeg_data(layout_df::DataFrame)

3×2 DataFrame
 Row │ Subject    Data                              
     │ SubStrin…  Py                                
─────┼──────────────────────────────────────────────
   1 │ 005        <RawEEGLAB | sub-005_ses-001_tas…
   2 │ 006        <RawEEGLAB | sub-006_ses-001_tas…
   3 │ 007        <RawEEGLAB | sub-007_ses-001_tas…


# Currently loading events is only suppoted from CSV files:

# First define the path where **all** CSV files are stored, e.g.:
SubPath = "/store/data/path/to/events/%s_finalEvents.csv"

# Then call
events = CollectEvents(layout_df.Subject, SubPath, delimeter=",");

# To run Unfold model:
resultsALl = RunUnfold(DataDF, EventsDF, bfDict; channels::Union{Nothing, String, Integer}=nothing, eventcolumn="event")

```


> **Note:** The ```specificFolder``` option will look for the folder either in the root (i.e. provided BIDSPath -> BIDSPath/specificFolder) or in the derivative (i.e. BIDSPath/derivatives -> BIDSPath/derivatives/specificFolder) based on the derivative flag!  



## UnfoldBIDS Quickstart

```julia
using UnfoldBIDS

bids = BIDSDir::bids_read_dir(xxx) (wrapper BIDS.jl?)
(optional) allEvts = collect_events(bids)
(optional) summarise_events(allEvts)

df = rununfold(bids,formula=xy,channels=xy,[basisfunction=FIR | taus = [-0.3,1.] ,...)

20×2 DataFrame
 Row │ subject  unfoldModel                       
     │ String   UnfoldLine…                       
─────┼────────────────────────────────────────────
   1 │ S01      Unfold-Type: UnfoldLinearModel \…
   2 │ S02      Unfold-Type: UnfoldLinearModel \…
   3 │ S03      Unfold-Type: UnfoldLinearModel \…
   4 │ S04      Unfold-Type: UnfoldLinearModel \…
  ⋮  │    ⋮                     ⋮
  18 │ S18      Unfold-Type: UnfoldLinearModel \…
  19 │ S19      Unfold-Type: UnfoldLinearModel \…
  20 │ S20      Unfold-Type: UnfoldLinearModel 
https://www.s-ccs.de/ClusterDepth.jl/dev/tutorials/eeg/

```
