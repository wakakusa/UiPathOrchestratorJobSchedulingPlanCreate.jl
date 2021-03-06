using UiPathOrchestratorJobSchedulingPlanCreate
using Documenter

makedocs(;
    modules=[UiPathOrchestratorJobSchedulingPlanCreate],
    authors="wakakusa",
    repo="https://github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl/blob/{commit}{path}#L{line}",
    sitename="UiPathOrchestratorJobSchedulingPlanCreate.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://wakakusa.github.io/UiPathOrchestratorJobSchedulingPlanCreate.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Function" => "function.md",
        "Excel" => "excel.md",
        "Hint" => "hints.md",
    ],
)

deploydocs(;
    repo="github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl",
)
