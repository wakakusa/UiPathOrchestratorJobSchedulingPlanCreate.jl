module UiPathOrchestratorJobSchedulingPlanCreate
using LinearAlgebra,Dates,StatsBase
using JuMP,Ipopt,Cbc
using DataFrames,XLSX
using Plots,GR,PlotlyJS

include("input.jl")
include("commonfunc.jl")
include("engine1.jl")
include("output.jl")

"""
    UiPathOrchestratorJobSchedulingPlanCreate

# 処理概要
UiPathOrchestratorのジョブスケジューリング案の作成

# 使い方
ExcelFilePath=""
uipathorchestratorschedulrecreate(ExcelFilePath,"parameters","schedule",plotengine="GR")
"""

"""
    uipathorchestratorschedulrecreate(ExcelFilePath::String,parameters::String,schedule::String;planexport::Bool=false,ExportExcelFilePath::String="",plotengine="PlotlyJS",schedulcolumn::Int=6)

# 処理概要
スケジュール作成

# 引数
* `ExcelFilePath`:スケジュール作成に必要な情報が記載されたExcelファイルのフルパスを指定。
* `parameters`:パラメーターが記載されたシート名を指定
* `schedule`:ジョブ作成に必要な情報が記載されたシート名を指定
* ` planexport`:(オプション)スケジュール作成結果を出力するかどうか。出力する場合、trueを指定。
* `ExportExcelFilePath`:(オプション)スケジュール作成先を指定。指定しない場合は、カレントディレクトリ（フォルダ）に"UiPathOrchestratorJobSchedulingPlan.xlsx"名で出力
* `plotengine`:(オプション)スケジュール調整結果を出力。指定値は、"GR","PlotlyJS","off"の３種類。offを選択するとグラフ出力しない
* `schedulcolumn`:スケジュールON,OFF開始列を指定（デフォルト：６）

# 結果（戻り値）
スケジュール調整結果を出力
"""
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
