```@meta
CurrentModule = UnfoldBIDS
```

# UnfoldBIDS.jl Documentation 

Welcome to the documentation for [UnfoldBIDS](https://github.com/unfoldtoolbox/UnfoldBIDS.jl), a helpful wrapper for [Unfold](https://github.com/unfoldtoolbox/Unfold.jl) style analysis applied to BIDS structured datasets.

If you need more information on BIDS, a quick overview and further reading can be found at [Reference/Brain Imaging Data Structure](./generated/reference/BIDS.md)


```@raw html
<div style="width:60%; margin: auto;">
</div>
```

## Key features & usage
![Flowchart showing UnfoldBIDS' place in the Unfold environment](assets/2025UnfoldBIDSFlowChart.png)

## Installation
```julia-repl
julia> using Pkg; Pkg.add("UnfoldBIDS")
```
For more detailed instructions please refer to [Installing Julia & Unfold Packages](https://unfoldtoolbox.github.io/UnfoldDocs/main/installation/).


## Where to start: Learning roadmap
### 1. First steps
🔗 [Quickstart](@ref)

### 2. Intermediate topics
📌 Goal: Use DataFrames to calculate group averages \
🔗 [Calculate group average](@ref)

### 3. Advanced topics
📌 Goal: Data preprocessing using MNE \
🔗 [Apply preprocessing functions](@ref)


## Statement of need
UnfoldBIDS.jl integrates the loading of BIDS-compliant datasets with the Unfold.jl package into a single, cohesive tool, enabling streamlined rERP analysis of BIDS-compliant data. This simplifies the otherwise cumbersome and error-prone task of writing scripts to load subject data iteratively, reducing it to just a few lines of code.

For researchers not relying on a subject list to look up subject-specific data, the default approach recursively walks through the entire directory, adding file paths that match a specific pattern. However, this method can be slow, particularly in directories with numerous subfolders, as required by BIDS. UnfoldBIDS.jl addresses this issue by using the Continuables.jl package to quickly search for suitable file paths, speeding up file searches even in large datasets with hundreds of subjects.

Additionally, many researchers write their loading scripts using loops that load data directly and recursively into memory, which can slow down the process, especially with large datasets. UnfoldBIDS.jl overcomes this in two ways. First by forcing the user to initially load and inspect all paths, including subject specific data, to make sure only datasets are loaded that are actually needed. And second, by utilizing MNE's lazy loading function by default, ensuring that data is only loaded when necessary. In summary, UnfoldBIDS.jl provides a convenient interface for processing BIDS-compliant EEG data in the Julia programming language.


```@raw html
<!---
Note: The statement of need is also used in the `README.md`. Make sure that they are synchronized.
-->
```