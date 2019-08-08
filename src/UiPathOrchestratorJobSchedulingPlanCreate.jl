module UiPathOrchestratorJobSchedulingPlanCreate
  using LinearAlgebra
  using JuMP
  using Cbc
  using XLSX
  using DataFrames
  using Plots
  using GR
  using PlotlyJS

include("input.jl")
include("core.jl")
include("output.jl")

function uipathorchestratorschedulrecreate(ExcelFilePath::String,parameters::String,schedule::String;planexport::Bool=false,ExportExcelFilePath::String="",plotengine="PlotlyJS")
  scheduleplan,robotn,run_unit_time,jobn,timen=readprerequisite(ExcelFilePath,parameters,schedule)
  plan,r,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen)
  plan=adjustedresultcheck(plan,runtime,scheduleplan)

  if(plotengine=="PlotlyJS")
    plotplanplotlyjs(plan)
  elseif(plotengine=="GR")
    plotplangr(plan)
  elseif(plotengine=="off"||plotengine=="")
  else
    println("plotengineはPlotlyJS,GR,offのどれかを選択してください")
  end

  if(planexport)
    exportplan(plan,ExcelFilePath=ExportExcelFilePath)
  end

  return plan

end

export uipathorchestratorschedulrecreate,readprerequisite,uipathorchestratorschedulreadjustment,adjustedresultcheck
export exportplan,plotplanmaster,plotplangr,plotplanplotlyjs
end # module
