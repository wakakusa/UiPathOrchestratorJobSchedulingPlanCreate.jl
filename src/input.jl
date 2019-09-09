#計算の前提条件読込み
function readprerequisite(ExcelFilePath::String,parameters::String,schedule::String)
  parameters=DataFrames.DataFrame(XLSX.readtable(ExcelFilePath, parameters)...)  
  scheduleplan=DataFrames.DataFrame(XLSX.readtable(ExcelFilePath, schedule)...)

  # 前提条件設定
  robotn=parameters[parameters[:,:parameter] .== "all_run_robot",:Int][1] #ロボット
  run_unit_time=parameters[parameters[:,:parameter] .== "run_unit_time",:Int][1] #実行単位時間、コマ割時間
  jobn=size(scheduleplan)[1] #ジョブ数
  timen=size(scheduleplan)[2]-5 #時間コマ数

  return scheduleplan,robotn,run_unit_time,jobn,timen
end
