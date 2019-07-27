# UiPathOrchestratorJobSchedulingPlanCreate.jl

## これは何？
Uipath Orchestatorで効率的なジョブ実行（必要最低限のロボットで実行）ができるようにジョブのタイムスケジュールを作成するプログラムです

## インストール方法
julia>]  
(v1.1) add https://github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.git  
でプログラムがインストールされます。括弧内の数字は、利用しているバージョンが表示されます。

## クイックガイド
ファイル　schedule.xlsxをコピーして修正してください。  
ExcelFilePathにはコピーしたschedule.xlsxまでのフルパスを指定してください

uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule")
を実行してください


