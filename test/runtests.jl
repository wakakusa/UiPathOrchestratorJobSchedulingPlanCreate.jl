using Test
using DataFrames
using XLSX
using UiPathOrchestratorJobSchedulingPlanCreate

@testset "UiPathOrchestratorJobSchedulingPlanCreate.jl" begin
    # Write your own tests here.
    jobname=Array{Any}(["スケジュール1","スケジュール2","スケジュール3","スケジュール4","スケジュール5","スケジュール6","スケジュール7","スケジュール8","スケジュール9","スケジュール10"])
    runtime=Array{Any}([30,60,15,15,30,45,30,15,60,30])
    Specifiedtime=Array{Any}([true,true,true,true,true,false,false,false,false,false])
    JobStartTime=Array{Any}(["0:30","0:45","0:15","0:00","1:00",missing,missing,missing,missing,missing])
    JobEndTime=Array{Any}(["1:00","1:45","0:30","0:30","2:00",missing,missing,missing,missing,missing])
#   0:00
    col1=Array{Any}([missing,missing,missing,1,missing,missing,missing,missing,missing,missing])
#    0:15
    col2=Array{Any}([missing,missing,1,1,missing,missing,missing,missing,missing,missing])
#    0:30
    col3=Array{Any}([1,missing,missing,missing,missing,missing,missing,missing,missing,missing])
#    0:45
    col4=Array{Any}([1,1,missing,missing,missing,missing,missing,missing,missing,missing])
#    1:00
    col5=Array{Any}([missing,1,missing,missing,1,missing,missing,missing,missing,missing])
#    1:15
    col6=Array{Any}([missing,1,missing,missing,1,missing,missing,missing,missing,missing])
#    1:30
    col7=Array{Any}([missing,1,missing,missing,1,missing,missing,missing,missing,missing])
#    1:45
    col8=Array{Any}([missing,missing,missing,missing,1,missing,missing,missing,missing,missing])
#    2:00
    col9=Array{Any}([missing,missing,missing,missing,missing,missing,missing,missing,missing,missing])
#    DataFrame作成
    schedule=DataFrame(jobname=jobname,runtime=runtime,Specifiedtime=Specifiedtime,JobStartTime=JobStartTime,JobEndTime=JobEndTime,col1=col1,col2=col2,col3=col3,col4=col4,col5=col5,col6=col6,col7=col7,col8=col8,col9=col9)

    InputFilePath=joinpath(@__DIR__, "schedule.xlsx")
    OutputFilePath=joinpath(@__DIR__, "scheduleoutput.xlsx")

    scheduleplan,robotn,run_unit_time,jobn,timen=UiPathOrchestratorJobSchedulingPlanCreate.readprerequisite(InputFilePath,"parameters","schedule")

    names!(schedule,names(scheduleplan))
    @test scheduleplan[1:5,1:5] == schedule[1:5,1:5]
    @test scheduleplan[1,8:9] == schedule[1,8:9]
    @test (robotn,run_unit_time,jobn,timen) == (6,15,10,9)
    
    output=DataFrames.DataFrame(XLSX.readtable(OutputFilePath, "REPORT_jobplan")...)
    plan,r,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen)
    plan=adjustedresultcheck(plan,runtime,scheduleplan)
    @test plan == output
    @test uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="off") == output
    @test uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="GR") == output
    @test uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="それ以外") == output
    if Sys.isapple()
        @test uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="PlotlyJS") == output
    end

    OutputTestFilePath=joinpath(@__DIR__, "UiPathOrchestratorJobSchedulingPlan.xlsx")
    uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="off",planexport=true)
    @test isfile(OutputTestFilePath)
    rm(OutputTestFilePath)

    #ジョブスケジュール作成失敗の場合のテスト
    robotn=1
    plan,r,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen)
    @test convert(Matrix,adjustedresultcheck(plan,runtime,scheduleplan)[:,3:end] ) == zeros(Int,jobn,timen)

end
