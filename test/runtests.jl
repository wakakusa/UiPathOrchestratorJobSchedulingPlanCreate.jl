using Test
using DataFrames
using XLSX
using UiPathOrchestratorJobSchedulingPlanCreate

@testset "UiPathOrchestratorJobSchedulingPlanCreate.jl" begin
    # Write your own tests here.
    schedulcolumn=6
    jobname=Array{Any}(["スケジュール1","スケジュール2","スケジュール3","スケジュール4","スケジュール5","スケジュール6","スケジュール7","スケジュール8","スケジュール9","スケジュール10"])
    runtime=Array{Any}([30,60,15,30,60,45,30,15,60,30])
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
    rename!(schedule,[:jobname,:runtime,:Specifiedtime,:JobStartTime,:JobEndTime,Symbol("0:00"),Symbol("0:15"),Symbol("0:30"),Symbol("0:45"),Symbol("1:00"),Symbol("1:15"),Symbol("1:30"),Symbol("1:45"),Symbol("2:00")])

    InputFilePath=joinpath(@__DIR__, "schedule.xlsx")
    OutputFilePath=joinpath(@__DIR__, "scheduleoutput.xlsx")

    scheduleplan,robotn,run_unit_time,jobn,timen=UiPathOrchestratorJobSchedulingPlanCreate.readprerequisite(InputFilePath,"parameters","schedule")

    rename!(schedule,names(scheduleplan))
    @test scheduleplan[1:schedulcolumn-1,1:schedulcolumn-1] == schedule[1:schedulcolumn-1,1:schedulcolumn-1]
    @test scheduleplan[1,8:9] == schedule[1,8:9]
    @test (robotn,run_unit_time,jobn,timen) == (6,15,10,8)
    
    output=DataFrames.DataFrame(XLSX.readtable(OutputFilePath, "v0.19.2")...)
    plan,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen)
    plan=adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen)
    @test sum(convert(Matrix,plan[:,schedulcolumn:end-1])) == sum(runtime)
#    @test convert(Matrix,plan[:,schedulcolumn:end-1]) == convert(Matrix,output[:,schedulcolumn:end-1])
    @test convert(Matrix,plan[1:7,schedulcolumn:end-1]) == convert(Matrix,output[1:7,schedulcolumn:end-1])
    @test convert(Matrix,plan[9:10,schedulcolumn:end-1]) == convert(Matrix,output[9:10,schedulcolumn:end-1])
    @test sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="off")[:,schedulcolumn:end-1])) == sum(runtime)
    @test sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="GR")[:,schedulcolumn:end-1])) == sum(runtime)
#    @test sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="PlotlyJS")[:,schedulcolumn:end-1])) == sum(runtime)
    @test sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="それ以外")[:,schedulcolumn:end-1])) == sum(runtime)
    @test uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="それ以外",checkreturn=true)[2]
    @test createtimeset()[1][1]=="00:00"
    if Sys.isapple()
        sum(convert(Matrix,uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="PlotlyJS")[:,schedulcolumn:end-1])) == sum(runtime)
    end

    OutputTestFilePath=joinpath(@__DIR__, "TestUiPathOrchestratorJobSchedulingPlan.xlsx")
    uipathorchestratorschedulrecreate(InputFilePath,"parameters","schedule",plotengine="off",planexport=true,ExportExcelFilePath=OutputTestFilePath)
    @test isfile(OutputTestFilePath)
    @test DataFrames.DataFrame(XLSX.readtable(OutputTestFilePath, "REPORT_jobplan")...)[1:5,1:5] == schedule[1:5,1:5]
    rm(OutputTestFilePath)

    exportplan(plan,robotn,run_unit_time,ExcelFilePath=OutputTestFilePath)
    @test isfile(OutputTestFilePath)
    @test DataFrames.DataFrame(XLSX.readtable(OutputTestFilePath, "REPORT_parameters")...)[2,2] == robotn 
    @test DataFrames.DataFrame(XLSX.readtable(OutputTestFilePath, "REPORT_jobplan")...)[1:5,1:5] == schedule[1:5,1:5]
    rm(OutputTestFilePath)

    #ジョブスケジュール作成失敗の場合のテスト
    robotn=1
    plan,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen)
    @test convert(Matrix,adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen)[:,schedulcolumn:end-1] ) == zeros(Int,jobn,timen)

    # 特定範囲内に収める
    scheduleplan,robotn,run_unit_time,jobn,timen=UiPathOrchestratorJobSchedulingPlanCreate.readprerequisite(InputFilePath,"parameters","schedule2")
    robotn=1
    plan,runtime=uipathorchestratorschedulreadjustment(scheduleplan,robotn,run_unit_time,jobn,timen)
    @test sum(convert(Matrix,adjustedresultcheck(plan,runtime,scheduleplan,robotn,jobn,timen)[:,schedulcolumn:end-1] ) )== sum(runtime)
end
