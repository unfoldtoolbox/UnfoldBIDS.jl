# UnfoldBIDS [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://reneskukies.github.io/UnfoldBIDS.jl/stable) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://reneskukies.github.io/UnfoldBIDS.jl/dev) [![Build Status](https://github.com/reneskukies/UnfoldBIDS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/reneskukies/UnfoldBIDS.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/reneskukies/UnfoldBIDS.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/reneskukies/UnfoldBIDS.jl)

Sub/Wrapper-Package of Unfold.jl. Ultimately it should provide the means to automatically load a Dataset in BIDS format and apply unfold-style processing to it. 

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


```
