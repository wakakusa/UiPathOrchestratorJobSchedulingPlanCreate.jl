module UiPathOrchestratorJobSchedulingPlanCreate
using LinearAlgebra
using JuMP,Ipopt
using DataFrames,XLSX
using Plots,GR,PlotlyJS

include("input.jl")
include("core.jl")
include("output.jl")

function uipathorchestratorschedulrecreate(ExcelFilePath::String,parameters::String,schedule::String;planexport::Bool=false,ExportExcelFilePath::String="",plotengine="PlotlyJS")
  scheduleplan,robotn,run_unit_time,jobn,timen=readprerequisite(ExcelFilePath,parameters,schedule)
  plan,r,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen)
  plan=adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen)

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

export uipathorchestratorschedulrecreate,readprerequisite,uipathorchestratorschedulreadjustment,adjustedresultcheck,ContinuousOperation
export exportplan,plotplanmaster,plotplangr,plotplanplotlyjs
end # module
