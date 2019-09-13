module UiPathOrchestratorJobSchedulingPlanCreate
using LinearAlgebra,Dates,Random,Distributions
using JuMP,Ipopt,MathOptInterface
using DataFrames,XLSX
using Plots,GR,PlotlyJS

include("input.jl")
include("commonfunc.jl")
include("engine1.jl")
include("output.jl")
include("engine2.jl")

function uipathorchestratorschedulrecreate(ExcelFilePath::String,parameters::String,schedule::String;planexport::Bool=false,ExportExcelFilePath::String="",plotengine="PlotlyJS",schedulcolumn::Int=6)
  scheduleplan,robotn,run_unit_time,jobn,timen=readprerequisite(ExcelFilePath,parameters,schedule)
  plan,r,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen,schedulcolumn=schedulcolumn)
  plan=adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen,schedulcolumn=schedulcolumn)

  if(plotengine=="PlotlyJS")
    plotplanplotlyjs(plan,schedulcolumn=schedulcolumn)
  elseif(plotengine=="GR")
    plotplangr(plan,schedulcolumn=schedulcolumn)
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
