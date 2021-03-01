# 使い方

## パッケージインストール
julia>]  
(v1.1) add https://github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.git  
でプログラムがインストールされます。括弧内の数字は、利用しているバージョンが表示されます。  

## Excelファイルの修正  
ファイル　schedule.xlsxをコピーして修正してください。  

## プログラムの実行  
juliaを起動して以下の順番に実行してください。  
ExcelFilePathにはコピーしたschedule.xlsxまでのフルパスを指定してください。  
  + using UiPathOrchestratorJobSchedulingPlanCreate  
  + uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule")  

