using UnfoldBIDS
using Documenter

using DataDeps
include("dataDeps.jl")

DocMeta.setdocmeta!(UnfoldBIDS, :DocTestSetup, :(using UnfoldBIDS); recursive=true)

makedocs(;
    modules=[UnfoldBIDS],
    authors="Rene Skukies, Benedikt Ehinger, Jan Haas",
    repo="https://github.com/reneskukies/UnfoldBIDS.jl/blob/{commit}{path}#{line}",
    sitename="UnfoldBIDS.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://reneskukies.github.io/UnfoldBIDS.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/reneskukies/UnfoldBIDS.jl",
    devbranch="main",
)
