# ![UnfoldBIDS](https://github.com/unfoldtoolbox/UnfoldBIDS.jl/assets/57703446/60678439-dae5-475a-9764-d021a445950d)

[![Dev][dev-img]][dev-url] [![Build Status][build-img]][build-url]
[![Coverage](https://codecov.io/gh/unfoldtoolbox/UnfoldBIDS.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/unfoldtoolbox/UnfoldBIDS.jl)

[Doc-img]: https://img.shields.io/badge/docs-stable-blue.svg
[Doc-url]: https://unfoldtoolbox.github.io/UnfoldBIDS.jl/stable
[dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[dev-url]: https://unfoldtoolbox.github.io/UnfoldDocs/UnfoldBIDS.jl/dev/
[semver-img]: https://img.shields.io/badge/semantic-versioning-green
[build-img]: https://github.com/unfoldtoolbox/UnfoldBIDS.jl/actions/workflows/CI.yml/badge.svg?branch=main
[build-url]: https://github.com/unfoldtoolbox/UnfoldBIDS.jl/actions/workflows/CI.yml?query=branch%3Amain

|rERP|EEG visualisation|EEG Simulations|BIDS pipeline|Decode EEG data|Statistical testing|
|---|---|---|---|---|---|
| <a href="https://github.com/unfoldtoolbox/Unfold.jl/tree/main"><img src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277623787-757575d0-aeb9-4d94-a5f8-832f13dcd2dd.png"></a> | <a href="https://github.com/unfoldtoolbox/UnfoldMakie.jl"><img  src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277623793-37af35a0-c99c-4374-827b-40fc37de7c2b.png"></a>|<a href="https://github.com/unfoldtoolbox/UnfoldSim.jl"><img src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277623795-328a4ccd-8860-4b13-9fb6-64d3df9e2091.png"></a>|<a href="https://github.com/unfoldtoolbox/UnfoldBIDS.jl"><img src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277622460-2956ca20-9c48-4066-9e50-c5d25c50f0d1.png"></a>|<a href="https://github.com/unfoldtoolbox/UnfoldDecode.jl"><img src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277622487-802002c0-a1f2-4236-9123-562684d39dcf.png"></a>|<a href="https://github.com/unfoldtoolbox/UnfoldStats.jl"><img  src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277623799-4c8f2b5a-ea84-4ee3-82f9-01ef05b4f4c6.png"></a>|

Sub/Wrapper-Package of Unfold.jl to automatically load a Dataset in BIDS format and apply unfold-style processing to all participants in one go. Additionally gives the means to apply MNE preprocessing.

## Install

### Installing Julia

<details>
<summary>Click to expand</summary>

The recommended way to install julia is [juliaup](https://github.com/JuliaLang/juliaup).
It allows you to, e.g., easily update Julia at a later point, but also test out alpha/beta versions etc.

TL:DR; If you dont want to read the explicit instructions, just copy the following command

#### Windows

AppStore -> JuliaUp,  or `winget install julia -s msstore` in CMD

#### Mac & Linux

`curl -fsSL https://install.julialang.org | sh` in any shell
</details>

### Installing Unfold

```julia
using Pkg
Pkg.add("UnfoldBIDS")
```

## Quickstart

```julia
using UnfoldBIDS


# To look up the paths of all subjects and store in a Dataframe:
layout_df = bids_layout(bidsPath::AbstractString; kwargs)
"""
# Input
bidsPath::AbstractString; # Path to BIDS root folder

# Kwargs
- derivatives::Bool=true: Do you want to us the derivative/ processed data? Default = true
- specific_folder::Union{Nothing,AbstractString}=nothing: If you want a specific folder in derivatives or root specify here
- exclude_folder::Union{Nothing,AbstractString}=nothing: You can exclude specific folders when not looking for a specific sub-folder 
- ses::Union{Nothing,AbstractString}=nothing: Specify session; will load all sessions if not specified
- task::Union{Nothing,AbstractString}=nothing: Specify task; will load all tasks if not specified
- run::Union{Nothing,AbstractString}=nothing): Specify run; will load all runs if not specified

"""

# To load all data into memory/ one dataframe:           
eeg_df = load_bids_eeg_data(layout_df; verbose::Bool=true, kwargs...)

# To run Unfold model (bf_dict = basis functions dictionary; see Unfold.jl):
models_df = run_unfold(eeg_df, bf_dict; eventcolumn="event", removeTimeexpandedXs=true, extract_data = raw_to_data, verbose::Bool=true, kwargs...)

# For dataframe containing tidy results
results_df = bids_coeftable(models_df)

# To unpack results into one big tidy DataFrame, with subject information
results = unpack_results(results_df)

```


> **Note:** The ```specific_folder``` option will look for the folder either in the root (i.e. provided bidsPath -> bidsPath/specific_folder) or in the derivative (i.e. bidsPath/derivatives -> bidsPath/derivatives/specific_folder) based on the derivative flag!  

### Supported EEG file types
- edf
- vhdr
- fif
- set

## Contributions

Contributions are very welcome. These could be typos, bugreports, feature-requests, speed-optimization, new solvers, better code, better documentation.

### How-to Contribute

You are very welcome to raise issues and start pull requests!

### Adding Documentation

1. We recommend to write a Literate.jl document and place it in `docs/literate/FOLDER/FILENAME.jl` with `FOLDER` being `HowTo`, `Explanation`, `Tutorial` or `Reference` ([recommended reading on the 4 categories](https://documentation.divio.com/)).
2. Literate.jl converts the `.jl` file to a `.md` automatically and places it in `docs/src/generated/FOLDER/FILENAME.md`.
3. Edit [make.jl](https://github.com/unfoldtoolbox/Unfold.jl/blob/main/docs/make.jl) with a reference to `docs/src/generated/FOLDER/FILENAME.md`.

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="http://www.benediktehinger.de"><img src="https://avatars.githubusercontent.com/u/10183650?v=4?s=100" width="100px;" alt="Benedikt Ehinger"/><br /><sub><b>Benedikt Ehinger</b></sub></a><br /><a href="#bug-behinger" title="Bug reports">🐛</a> <a href="#code-behinger" title="Code">💻</a> <a href="#projectManagement-behinger" title="Project Management">📆</a> <a href="#ideas-behinger" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://reneskukies.de/"><img src="https://avatars.githubusercontent.com/u/57703446?v=4?s=100" width="100px;" alt="René Skukies"/><br /><sub><b>René Skukies</b></sub></a><br /><a href="#review-ReneSkukies" title="Reviewed Pull Requests">👀</a> <a href="#ideas-ReneSkukies" title="Ideas, Planning, & Feedback">🤔</a> <a href="#code-ReneSkukies" title="Code">💻</a> <a href="#bug-ReneSkukies" title="Bug reports">🐛</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->


This project follows the [all-contributors](https://allcontributors.org/docs/en/specification) specification. 

Contributions of any kind welcome!
You can find the emoji key for the contributors [here](https://github.com/unfoldtoolbox/Unfold.jl/blob/main/docs/contrib-emoji.md)


## Citation

## Acknowledgements

Funded by Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under Germany´s Excellence Strategy – EXC 2075 – 390740016
