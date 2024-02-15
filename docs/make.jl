using UnfoldBIDS
using Documenter
using Glob
using Literate


GENERATED = joinpath(@__DIR__, "src", "generated")
SOURCE = joinpath(@__DIR__, "literate")

for subfolder ∈ ["explanations", "HowTo", "tutorials", "reference"]
    local SOURCE_FILES = Glob.glob(subfolder * "/*.jl", SOURCE)
    #config=Dict(:repo_root_path=>"https://github.com/unfoldtoolbox/UnfoldBIDS")
    foreach(fn -> Literate.markdown(fn, GENERATED * "/" * subfolder), SOURCE_FILES)

end


DocMeta.setdocmeta!(UnfoldBIDS, :DocTestSetup, :(using UnfoldBIDS); recursive = true)

makedocs(;
    modules = [UnfoldBIDS],
    authors = "René Skukies, Benedikt Ehinger",
    #repo="https://github.com/unfoldtoolbox/UnfoldBIDS.jl/blob/{commit}{path}#{line}",
    repo = Documenter.Remotes.GitHub("unfoldtoolbox", "UnfoldBIDS.jl"),
    sitename = "UnfoldBIDS.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://unfoldtoolbox.github.io/UnfoldBIDS.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => [
            "Quickstart" => "generated/tutorials/quickstart.md",
        ],
        "Reference" => [
            "Overview: Toolbox Functions" => "./generated/reference/overview.md",
        ],
        "HowTo" => [
            "Apply preprocessing functions" => "./generated/HowTo/ApplyPreprocessing.md",
        ],
        "DocStrings" => "api.md",
    ],
)

deploydocs(; repo = "github.com/unfoldtoolbox/UnfoldBIDS.jl", devbranch = "main")
