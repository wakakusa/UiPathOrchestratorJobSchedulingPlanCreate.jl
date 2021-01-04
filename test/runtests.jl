using Test
using DataFrames
using XLSX
using UiPathOrchestratorJobSchedulingPlanCreate

# Write your own tests here.
@testset "UiPathOrchestratorJobSchedulingPlanCreate.jl 基本機能" begin
    include(joinpath(@__DIR__, "common.jl"))

    @test scheduleplan[1:schedulcolumn-1,1:schedulcolumn-1] == schedulemaster[1:schedulcolumn-1,1:schedulcolumn-1]
    @test scheduleplan[1,8:9] == schedulemaster[1,8:9]
    @test (robotn,run_unit_time,jobn,timen) == (6,15,10,8)
    
    output=DataFrames.DataFrame(XLSX.readtable(OutputFilePath, "v0.19.2")...)
    plan,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow)
    plan=adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow)
    @test sum(convert(Matrix,plan[:,schedulcolumn:end-1])) == sum(runtime)
#    @test convert(Matrix,plan[:,schedulcolumn:end-1]) == convert(Matrix,output[:,schedulcolumn:end-1])
    @test convert(Matrix,plan[1:7,schedulcolumn:end-1]) == convert(Matrix,output[1:7,schedulcolumn:end-1])
    @test convert(Matrix,plan[9:10,schedulcolumn:end-1]) == convert(Matrix,output[9:10,schedulcolumn:end-1])
    @test sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="off")[:,schedulcolumn:end-1])) == sum(runtime)
    @test sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="GR")[:,schedulcolumn:end-1])) == sum(runtime)
    @test sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="それ以外")[:,schedulcolumn:end-1])) == sum(runtime)
    @test uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="それ以外",checkreturn=true)[2]
    @test createtimeset()[1][1]=="00:00"

    OutputTestFilePath=joinpath(@__DIR__, "TestUiPathOrchestratorJobSchedulingPlan.xlsx")
    uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="off",planexport=true,ExportExcelFilePath=OutputTestFilePath)
    @test isfile(OutputTestFilePath)
    @test DataFrames.DataFrame(XLSX.readtable(OutputTestFilePath, "REPORT_jobplan")...)[1:5,1:5] == schedulemaster[1:5,1:5]
    rm(OutputTestFilePath)

    exportplan(plan,robotn,run_unit_time,ExcelFilePath=OutputTestFilePath)
    @test isfile(OutputTestFilePath)
    @test DataFrames.DataFrame(XLSX.readtable(OutputTestFilePath, "REPORT_parameters")...)[2,2] == robotn 
    @test DataFrames.DataFrame(XLSX.readtable(OutputTestFilePath, "REPORT_jobplan")...)[1:5,1:5] == schedulemaster[1:5,1:5]
    rm(OutputTestFilePath)

    # PlotlyJSを別途追加
    using Pkg
    Pkg.add("PlotlyJS")
    Pkg.add("Blink")
    Pkg.add("ORCA")
    using PlotlyJS
    @test sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="PlotlyJS")[:,schedulcolumn:end-1])) == sum(runtime)
end

@testset "ジョブスケジュール作成失敗の場合のテスト" begin
    include(joinpath(@__DIR__, "common.jl"))
    robotn=1
   plan,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow)
    @test convert(Matrix,adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow)[:,schedulcolumn:end-1] ) == zeros(Int,jobn,timen)
end

@testset "特定範囲内に収める" begin
    include(joinpath(@__DIR__, "common.jl"))
    scheduleplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow=readprerequisite(InputFilePath,"parameters","schedule2")
    robotn=1
    plan,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow)
    @test sum(convert(Matrix,adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow)[:,schedulcolumn:end-1] ) )== sum(runtime)
end

@testset "ブロックタイム設定" begin
    include(joinpath(@__DIR__, "common.jl"))
    scheduleplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow=readprerequisite(InputFilePath,"parameters","schedule3")
    robotn=2
    plan,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow)
    @test sum(convert(Matrix,adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow)[:,schedulcolumn:end-1] ) )== sum(runtime)
end
