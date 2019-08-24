# API

## uipathorchestratorschedulrecreate(ExcelFilePath::String,parameters::String,schedule::String;planexport::Bool=false,ExportExcelFilePath::String="",plotengine="PlotlyJS",schedulcolumn::Int=6)  
- 処理概要:スケジュール作成   
- 引数   
    +  ExcelFilePath:スケジュール作成に必要な情報が記載されたExcelファイルのフルパスを指定。  
    +  parameters:パラメーターが記載されたシート名を指定  
    +  schedule:ジョブ作成に必要な情報が記載されたシート名を指定  
    +  planexport(オプション):スケジュール作成結果を出力するかどうか。出力する場合、trueを指定。  
    +  ExportExcelFilePath(オプション):スケジュール作成先を指定。指定しない場合は、カレントディレクトリ（フォルダ）に"UiPathOrchestratorJobSchedulingPlan.xlsx"名で出力  
    +  plotengine(オプション):スケジュール調整結果を出力。指定値は、"GR","PlotlyJS","off"の３種類。offを選択するとグラフ出力しない   
    + schedulcolumn:スケジュールON,OFF開始列を指定（デフォルト：６）
- 結果（戻り値）：スケジュール調整結果を出力  

## readprerequisite(ExcelFilePath::String,parameters::String,schedule::String)  
- 処理概要:スケジュール作成   
- 引数   
    +  ExcelFilePath:スケジュール作成に必要な情報が記載されたExcelファイルのフルパスを指定。  
    +  parameters:パラメーターが記載されたシート名を指定  
    +  schedule:ジョブ作成に必要な情報が記載されたシート名を指定  
    + schedulcolumn:スケジュールON,OFF開始列を指定（デフォルト：６）
- 結果（戻り値）：パラメータの読込み結果を出力  

## uipathorchestratorschedulreadjustment(scheduleplan::DataFrame,robotn::Int,run_unit_time::Int,jobn::Int,timen::Int,schedulcolumn::Int=6)  
- 処理概要:処理結果の整合性確認および整形   
- 引数   
    +  scheduleplan:  
    +  robotn:  
    +  run_unit_time:ジョブ作成に必要な情報が記載されたシート名を指定 
    +  jobn:
    +  timen:
    + schedulcolumn:スケジュールON,OFF開始列を指定（デフォルト：６）
- 結果（戻り値）：スケジュール調整結果を出力   

## adjustedresultcheck(plan::Array,runtime::Array,scheduleplan::DataFrame)  
- 処理概要:スケジュール調整した結果が正しく結果かどうかチェック   
- 引数   
    +  plan:uipathorchestratorschedulreadjustmentの実行結果を指定  
    +  runtime:readprerequisiteで読み込んだ結果を指定
    +  uipathorchestratorschedulreadjustment:readprerequisiteで読み込んだ結果を指定
    + schedulcolumn:スケジュールON,OFF開始列を指定（デフォルト：６）
- 結果（戻り値）：スケジュール調整結果を出力

## plotplanmaster(plan::DataFrame,schedulcolumn::Int=6)  
- 処理概要:スケジュール調整した結果をグラフに出力   
- 引数   
    +  plan:adjustedresultcheckの実行結果を指定  
    + schedulcolumn:スケジュールON,OFF開始列を指定（デフォルト：６）
- 結果（戻り値）：グラフ出力  
- 注意：グラフ描画エンジンの指定が必要。詳細はパッケージ：Plotsの利用方法を参照 

## plotplangr(plan::DataFrame,schedulcolumn::Int=6)  
- 処理概要:スケジュール調整した結果をGRを使ってグラフに出力   
- 引数  
    +  plan:adjustedresultcheckの実行結果を指定  
    + schedulcolumn:スケジュールON,OFF開始列を指定（デフォルト：６）
- 結果（戻り値）：グラフ出力  

## plotplanplotlyjs(plan::DataFrame,schedulcolumn::Int=6)  
- 処理概要:スケジュール調整した結果をPlotlyJSを使ってグラフに出力  
- 引数  
    +  plan:adjustedresultcheckの実行結果を指定  
    + schedulcolumn:スケジュールON,OFF開始列を指定（デフォルト：６）
- 結果（戻り値）：グラフ出力 

## exportplan(plan::DataFrame;ExcelFilePath::String="")  
- 処理概要:スケジュール調整した結果をExcelファイルに出力   
- 引数   
    +  plan:adjustedresultcheckの実行結果を指定  
    +  ExcelFilePath:出力ファイル名をフルパスで記載。指定しない場合は、カレントディレクトリ（フォルダ）に"UiPathOrchestratorJobSchedulingPlan.xlsx"名で出力  