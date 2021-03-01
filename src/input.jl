#計算の前提条件読込み
"""
    readprerequisite(ExcelFilePath::String,parameters::String,schedule::String;schedulcolumn::Int=6)

# 処理概要
スケジュール作成

# 引数
* `ExcelFilePath`:スケジュール作成に必要な情報が記載されたExcelファイルのフルパスを指定。
* `parameters`:パラメーターが記載されたシート名を指定
* `schedule`:ジョブ作成に必要な情報が記載されたシート名を指定
* `schedulcolumn`:スケジュールON,OFF開始列を指定（デフォルト：６）

# 結果（戻り値）
パラメータの読込み結果を出力
"""
function readprerequisite(ExcelFilePath::String,parameters::String,schedule::String;schedulcolumn::Int=6)
  parameters=DataFrames.DataFrame(XLSX.readtable(ExcelFilePath, parameters)...)
  scheduleplan=DataFrames.DataFrame(XLSX.readtable(ExcelFilePath, schedule)...)

  # 前提条件設定
  robotn=parameters[parameters[:,:parameter] .== "all_run_robot",:value][1] #ロボット
  run_unit_time=parameters[parameters[:,:parameter] .== "run_unit_time",:value][1] #実行単位時間、コマ割時間
  jobn=size(scheduleplan)[1] #ジョブ数
  timen=size(scheduleplan)[2]-schedulcolumn #時間コマ数

  blocktime_start=string(parameters[parameters[:,:parameter] .== "blocktime_start",:value][1])[1:5]  #スケジュール割当禁止開始時間
  blocktime_end=string(parameters[parameters[:,:parameter] .== "blocktime_end",:value][1])[1:5]  #スケジュール割当禁止終了時間
  blocktime_dow=parameters[parameters[:,:parameter] .== "blocktime_dow",:value][1]  #スケジュール割当禁止を設定するシート名

  return scheduleplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow
end
