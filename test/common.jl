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
schedulemaster=DataFrame(jobname=jobname,runtime=runtime,Specifiedtime=Specifiedtime,JobStartTime=JobStartTime,JobEndTime=JobEndTime,col1=col1,col2=col2,col3=col3,col4=col4,col5=col5,col6=col6,col7=col7,col8=col8,col9=col9)
rename!(schedulemaster,[:jobname,:runtime,:Specifiedtime,:JobStartTime,:JobEndTime,Symbol("0:00"),Symbol("0:15"),Symbol("0:30"),Symbol("0:45"),Symbol("1:00"),Symbol("1:15"),Symbol("1:30"),Symbol("1:45"),Symbol("2:00")])

InputFilePath=joinpath(@__DIR__, "schedule.xlsx")
OutputFilePath=joinpath(@__DIR__, "scheduleoutput.xlsx")

scheduleplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow=readprerequisite(InputFilePath,"parameters","schedule")

rename!(schedulemaster,names(scheduleplan))