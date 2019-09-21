module UiPathOrchestratorJobSchedulingPlanCreate
using LinearAlgebra,Dates,StatsBase
using JuMP,Ipopt,Cbc
using DataFrames,XLSX
using Plots,GR,PlotlyJS

include("input.jl")
include("commonfunc.jl")
include("engine1.jl")
include("output.jl")

function uipathorchestratorschedulrecreate(ExcelFilePath::String,parameters::String,schedule::String;planexport::Bool=false,ExportExcelFilePath::String="",plotengine="PlotlyJS",schedulcolumn::Int=6,checkreturn::Bool=false)
  scheduleplan,robotn,run_unit_time,jobn,timen=readprerequisite(ExcelFilePath,parameters,schedule,schedulcolumn=schedulcolumn)
  plan,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen,schedulcolumn=schedulcolumn)
  if(checkreturn)
    plan,adjustedresultcheckflag=adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen,schedulcolumn=schedulcolumn,checkreturn=checkreturn)
  else
    plan=adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen,schedulcolumn=schedulcolumn,checkreturn=checkreturn)
  end

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

  if(checkreturn)
    return plan,adjustedresultcheckflag
  else
    return plan
  end

end

export uipathorchestratorschedulrecreate,readprerequisite,uipathorchestratorschedulreadjustment,adjustedresultcheck,ContinuousOperation
export exportplan,plotplanmaster,plotplangr,plotplanplotlyjs
export createtimeset
end # module
