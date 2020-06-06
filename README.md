# UiPathOrchestratorJobSchedulingPlanCreate

[![CI](https://github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl/workflows/CI/badge.svg)](https://github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl)

[![Build Status](https://travis-ci.org/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl.svg?branch=master)](https://travis-ci.org/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl)
[![Coverage Status](https://coveralls.io/repos/github/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl/badge.svg?branch=master)](https://coveralls.io/github/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.jl?branch=master)

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://wakakusa.github.io/UiPathOrchestratorJobSchedulingPlanCreate.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://wakakusa.github.io/UiPathOrchestratorJobSchedulingPlanCreate.jl/dev)

## これは何？
Uipath Orchestatorで効率的なジョブ実行（必要最低限のロボットで実行）ができるようにジョブのタイムスケジュールを作成するプログラムです

## インストール方法
julia>]  
(v1.1) add https://github.com/wakakusa/UiPathOrchestratorJobSchedulingPlanCreate.git  
でプログラムがインストールされます。括弧内の数字は、利用しているバージョンが表示されます。

## 使い方
ファイル　schedule.xlsxをコピーして修正してください。  
ExcelFilePathにはコピーしたschedule.xlsxまでのフルパスを指定してください

uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule")
を実行してください

## 今後の計画
最適なロボット数の算出
