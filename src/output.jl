"""
    plotplanmaster(plan::DataFrame;schedulcolumn::Int=6)

# 処理概要
スケジュール調整した結果をグラフに出力
* 注意：グラフ描画エンジンの指定が必要。詳細はパッケージ：Plotsの利用方法を参照

# 引数
* `plan`:adjustedresultcheckの実行結果を指定
* `schedulcolumn`:スケジュールON,OFF開始列を指定（デフォルト：６）

# 結果（戻り値）
グラフ出力
"""
function plotplanmaster(plan::DataFrame;schedulcolumn::Int=6)
  xs = map(String,names(plan)[schedulcolumn:end] )
  ys = map(String,plan[:,:jobname])

  plot=Plots.heatmap(xs, ys, convert(Matrix,plan[:,schedulcolumn:end]), legend=false,c=cgrad([:white,:blue]))

  return plot

end


"""
    plotplangr(plan::DataFrame;schedulcolumn::Int=6)

# 処理概要
スケジュール調整した結果をGRを使ってグラフに出力

# 引数
* `plan`:adjustedresultcheckの実行結果を指定
* `schedulcolumn`:スケジュールON,OFF開始列を指定（デフォルト：６）

# 結果（戻り値）
* グラフ出力
"""
function plotplangr(plan::DataFrame;schedulcolumn::Int=6)
  ENV["GKS_ENCODING"]="utf-8"
  gr()

  plot=plotplanmaster(plan,schedulcolumn=schedulcolumn)
  gui(plot)
  return plot
end


"""
    plotplanplotlyjs(plan::DataFrame;schedulcolumn::Int=6)

# 処理概要
スケジュール調整した結果をPlotlyJSを使ってグラフに出力

# 引数
* `plan`:adjustedresultcheckの実行結果を指定
* `schedulcolumn`:スケジュールON,OFF開始列を指定（デフォルト：６）

# 結果（戻り値）
* グラフ出力
"""
function plotplanplotlyjs(plan::DataFrame;schedulcolumn::Int=6)
  plotlyjs()

  plot=plotplanmaster(plan,schedulcolumn=schedulcolumn)
  gui(plot)
  return plot
end


"""
    exportplan(plan::DataFrame;ExcelFilePath::String="")

# 処理概要
スケジュール調整した結果をExcelファイルに出力

# 引数
* `plan`:adjustedresultcheckの実行結果を指定
* `ExcelFilePath`:出力ファイル名をフルパスで記載。指定しない場合は、カレントディレクトリ（フォルダ）に"UiPathOrchestratorJobSchedulingPlan.xlsx"名で出力
"""
function exportplan(plan::DataFrame;ExcelFilePath::String="")
  if(ExcelFilePath=="")
    ExcelFilePath="UiPathOrchestratorJobSchedulingPlan.xlsx"
  end
 
 XLSX.writetable(ExcelFilePath, REPORT_jobplan=( collect(DataFrames.eachcol(plan)), DataFrames.names(plan) )  )
end


"""
    exportplan(plan::DataFrame,robotn::Int,run_unit_time::Int;ExcelFilePath::String="")

# 処理概要
スケジュール調整した結果をExcelファイルに出力

# 引数
* `plan`:adjustedresultcheckの実行結果を指定
* `robotn`:
* `run_unit_time`:
* `ExcelFilePath`:出力ファイル名をフルパスで記載。指定しない場合は、カレントディレクトリ（フォルダ）に"UiPathOrchestratorJobSchedulingPlan.xlsx"名で出力
"""
function exportplan(plan::DataFrame,robotn::Int,run_unit_time::Int;ExcelFilePath::String="")
  if(ExcelFilePath=="")
    ExcelFilePath="UiPathOrchestratorJobSchedulingPlan.xlsx"
  end

  parameters=DataFrame(parameter=["run_unit_time","all_run_robot"],Int=[run_unit_time,robotn],unit=["min",""],説明=["スケジュール実行単位","割り当て可能ロボット総数"])

  XLSX.writetable(ExcelFilePath, REPORT_parameters=( collect(DataFrames.eachcol(parameters)), DataFrames.names(parameters) ) ,REPORT_jobplan=( collect(DataFrames.eachcol(plan)), DataFrames.names(plan) )  )
end