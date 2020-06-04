using Documenter, UiPathOrchestratorJobSchedulingPlanCreate

makedocs(;
    modules=[UiPathOrchestratorJobSchedulingPlanCreate],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Function" => "function.md",
        "Excel" => "excel.md",
    ],
    repo="https://github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl/blob/{commit}{path}#L{line}",
    sitename="UiPathOrchestratorJobSchedulingPlanCreate.jl",
    authors="wakakusa",
    assets=String[],
)

deploydocs(;
    repo="github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl",
)
