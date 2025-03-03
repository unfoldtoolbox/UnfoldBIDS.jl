using UnfoldBIDS
using Documenter
using Glob
using Literate
#import Artifacts
import LazyArtifacts

# We need this macro to use Artifacts in the docs
macro artifact_str(s)
    LazyArtifacts.@artifact_str(s)
end

sample_BIDS = @show artifact"sample_BIDS"


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
        sidebar_sitename = false,
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => [
            "Quickstart" => "generated/tutorials/quickstart.md",
        ],
        "Reference" => [
            "API: Toolbox Functions" => "api.md",
            "Brain Imaging Data Structure" => "./generated/reference/BIDS.md"
        ],
        "HowTo" => [
            "Apply preprocessing functions" => "./generated/HowTo/ApplyPreprocessing.md",
            "Calculate group average" => "generated/HowTo/group_average.md",
            "Save/ load Unfold results" => "generated/HowTo/IO.md",
            "Find non-BIDS conform data" => "./generated/HowTo/find_non_bids.md"
        ],
    ],
)

deploydocs(; 
    repo = "github.com/unfoldtoolbox/UnfoldBIDS.jl",
    push_preview = true,
    devbranch = "main")
