"""
    uipathorchestratorschedulreadjustment(scheduleplan::DataFrame,robotn::Int,run_unit_time::Int,jobn::Int,timen::Int,schedule::String,blocktime_start::String,blocktime_end::String,blocktime_dow::String;schedulcolumn::Int=6,formulaprint::Bool=false)

# 処理概要
スケジュール作成、処理結果の整合性確認および整形

# 引数
* `scheduleplan`:スケジュール作成のために必要な諸元
* `robotn`:同時最大稼働ロボット数
* `run_unit_time`:実行単位時間、コマ割時間
* `jobn`:ジョブ数
* `timen`:時間コマ数
* `schedule`：ジョブ作成に必要な情報が記載されたシート名を指定
* `blocktime_start`:実行禁止時間帯（開始）
* `blocktime_end`:実行禁止時間帯（終了）
* `blocktime_dow`:実行禁止時間帯設定をするシート名
* `schedulcolumn`:スケジュールON,OFF開始列を指定（デフォルト：６）
* `formulaprint`:数理計画の数式を表示する

# 結果（戻り値）
スケジュール調整結果を出力
"""
function uipathorchestratorschedulreadjustment(scheduleplan::DataFrame,robotn::Int,run_unit_time::Int,jobn::Int,timen::Int,schedule::String,blocktime_start::String,blocktime_end::String,blocktime_dow::String;schedulcolumn::Int=6,formulaprint::Bool=false)
    ## 数理モデル
    m1 = JuMP.Model(Ipopt.Optimizer)

    ## 変数
    JuMP.@variable(m1, 0<=s[1:jobn,1:timen] <=1 ) #ジョブ毎のコマ割りごとに実行有無を表示

    ## 定数
    runtime=zeros(Int,jobn,1) #ジョブ毎の実行時間

    ## ジョブ実行時間
    ###割り当てるコマ数を算出
    for i in 1:jobn
      runtime[i]=scheduleplan[i,:runtime]/run_unit_time
    end

    ## 目的関数
    JuMP.@objective(m1, Min, sum(scheduleplan[1:end,:runtime])/run_unit_time-sum(s[1:jobn,1:timen] ))

    ## 制約条件
    ### ブロック時間設定
    if schedule == blocktime_dow || blocktime_dow =="all"
      timenames=names(scheduleplan)[schedulcolumn:end]
      blockcolstart=0
      blockcolend=0

      for i in 1:length(timenames) 
        if timenames[i] == blocktime_start
          blockcolstart=i
        end

        if timenames[i] == blocktime_end
          blockcolend=i-1
        end
      end

      for i in 1 :jobn
        for j in blockcolstart:blockcolend
          JuMP.@constraint(m1, s[i,j] == 0.0 )
        end
      end
    end

    ### ジョブ実行時間予約指定
    for i in 1:jobn
      flag1 =true
      if scheduleplan[i,:Specifiedtime] == 1
        for j in schedulcolumn:schedulcolumn+timen-1
          if typeof(scheduleplan[i,j]) !=Missing && flag1
            index=j-schedulcolumn+1
            JuMP.@constraint(m1, s[i,index:index+runtime[i]-1] .== 1.0 )
            flag1=false
          end
        end
      elseif scheduleplan[i,:Specifiedtime] == 2
        df = DateFormat("HH:MM");
        StartTime=DateTime(scheduleplan[i,:JobStartTime],df)
        EndTime=DateTime(scheduleplan[i,:JobEndTime],df)
        for j in schedulcolumn:schedulcolumn+timen-1
          if DateTime(string(names(scheduleplan)[j]),df) >= StartTime && DateTime(string(names(scheduleplan)[j]),df) < EndTime
          else
            JuMP.@constraint(m1, s[i,j-schedulcolumn+1] == 0.0 )
          end
        end
      elseif scheduleplan[i,:Specifiedtime] == 0 || ismissing(scheduleplan[i,:Specifiedtime])
      else
        println(i,"行目の指定パターンを確認してください")
      end
    end

    ### ジョブ実行時間制限
    for i in 1 :jobn
      JuMP.@constraint(m1,sum(s[i,1:timen])==Float64(runtime[i]))
    end

    ### ロボット同時実行制限(ロボット数を超過させない)
    for i in 1 :timen
      JuMP.@constraint(m1,sum(s[1:jobn,i])<=Float64(robotn) )
    end

    ### ジョブ連続実行制限
    JuMP.register(m1, :ContinuousOperation, size(s)[2], ContinuousOperation; autodiff = true)

    for i in 1:jobn
      x=s[i,1:timen]
      @constraint(m1,sum(ContinuousOperation(x...))== Float64(runtime[i]-1) )
    end
  
    #数式表示
    if formulaprint
      println(m1)
    end

    ## ソルバーの実行
    status = JuMP.optimize!(m1)

    ## スケジュール案表示
    plan=zeros(Int,jobn,timen)
    plan=map(Int,map(round,JuMP.value.(s)))

    # 割当時間1コマの不具合対策
    if sum(plan) != sum(runtime)
      schedulesubplan=scheduleplan[:,schedulcolumn:end ]
      schedulesubplan[:,:].= hcat(plan,zeros(Int,jobn,1))
      schedulesubplan=hcat(scheduleplan[:,1:schedulcolumn-1 ] , schedulesubplan)
      for i in 1:jobn
        if sum(schedulesubplan[i,schedulcolumn:end]) == runtime[i]
          schedulesubplan[i,:Specifiedtime] =1
        end
      end

      plan = uipathorchestratorschedulreadjustmentsub1(schedulesubplan,robotn,run_unit_time,jobn,timen,schedule,blocktime_start,blocktime_end,blocktime_dow,schedulcolumn=schedulcolumn)
    end

    return plan,runtime
end


"""
adjustedresultcheck(plan::Array,runtime::Array,scheduleplan::DataFrame,robotn::Int,jobn::Int,timen::Int,blocktime_start::String,blocktime_end::String,blocktime_dow::String;schedulcolumn::Int=6,checkreturn::Bool=false)

# 処理概要
スケジュール調整した結果が正しく結果かどうかチェック。作成されたスケジュールの妥当性チェック

# 引数
* `plan`:uipathorchestratorschedulreadjustmentの実行結果を指定
* `runtime`:readprerequisiteで読み込んだ結果を指定
* `scheduleplan`:スケジュール作成のために必要な諸元
* `robotn`:同時最大稼働ロボット数
* `jobn`:ジョブ数
* `timen`:時間コマ数
* `schedule`：ジョブ作成に必要な情報が記載されたシート名を指定
* `blocktime_start`:実行禁止時間帯（開始）
* `blocktime_end`:実行禁止時間帯（終了）
* `blocktime_dow`:実行禁止時間帯設定をするシート名
* `schedulcolumn`:スケジュールON,OFF開始列を指定（デフォルト：６）
* `blocktime_start`:実行禁止時間帯（開始）
* `blocktime_end`:実行禁止時間帯（終了）
* `blocktime_dow`:実行禁止時間帯設定をするシート名


# 結果（戻り値）
スケジュール調整結果を出力
"""
function adjustedresultcheck(plan::Array,runtime::Array,scheduleplan::DataFrame,robotn::Int,jobn::Int,timen::Int,schedule::String,blocktime_start::String,blocktime_end::String,blocktime_dow::String;schedulcolumn::Int=6,checkreturn::Bool=false)
  adjustedresultcheckflag=true
  adjustedresultcheckmastarflag=Array{Bool}(undef,jobn,4) # #1:ジョブごとに実行時間確保されているかチェック,#2:ロボット数超過,#3:処理時間が連続しているか,#4:ブロック時間が設定できているか
  adjustedresultcheckmastarflag .= false

  #ジョブごとに実行時間確保されているかチェック
  for i in 1:jobn
    adjustedresultcheckflag1=true 
    for j in 1:timen
      if plan[i,j]==1 && adjustedresultcheckflag1
        adjustedresultcheckflag1=false
        if sum(plan[i,j:(j+runtime[i]-1)])!=runtime[i]
          adjustedresultcheckmastarflag[i,1]=false
        else
          adjustedresultcheckmastarflag[i,1]=true
        end
      end
    end
  end

  # ロボット数超過していないか確認
  for i in 1:timen
    if sum(plan[:,i]) > robotn
      adjustedresultcheckmastarflag[:,2] .=false
    else
      adjustedresultcheckmastarflag[:,2] .=true
    end
  end

  # 処理時間が連続しているか確認
  for i in 1:jobn
    x=plan[i,:]
    if sum(ContinuousOperation(x...))!=runtime[i]-1
      adjustedresultcheckmastarflag[i,3]=false
    else
      adjustedresultcheckmastarflag[i,3]=true
    end
  end

  ### ブロック時間設定チェック
  if schedule == blocktime_dow || blocktime_dow =="all"
    timenames=names(scheduleplan)[schedulcolumn:end]
    blockcolstart=0
    blockcolend=0

    for i in 1:length(timenames) 
      if timenames[i] == blocktime_start
        blockcolstart=i
      end

      if timenames[i] == blocktime_end
        blockcolend=i
      end
    end

    for i in 1 :jobn
      subcheckflag=true #チェック状態を掛け算で算出するため

      for j in blockcolstart:blockcolend
        if plan[i,j] in (0.0,0) && subcheckflag
          adjustedresultcheckmastarflag[i,4]=true
        else
          adjustedresultcheckmastarflag[i,4]=false
          subcheckflag=false
        end
      end
    end
  else
    adjustedresultcheckmastarflag[:,4] .=true
  end

  # 総合判定
  if sum(adjustedresultcheckmastarflag) != size(adjustedresultcheckmastarflag,1)*size(adjustedresultcheckmastarflag,2)
    plan=zeros(Int,jobn,timen)
    adjustedresultcheckflag = false
  end

  result=scheduleplan[:,schedulcolumn:end ]
  result[:,:].= hcat(plan,zeros(Int,jobn,1))
  result=hcat(scheduleplan[:,1:schedulcolumn-1 ] , result)
  result[:,end] .=missing

  #処理開始時間および終了時間を取得
  times=names(scheduleplan)

  for i in 1 : size(scheduleplan,1)
    startflag=true
    endflag=true

    for j in schedulcolumn : size(scheduleplan,2)
      if !ismissing(result[i,j])
        if result[i,j] == 1 && startflag
          startflag = false
          result[i,:JobStartTime]=string(times[j])
        end
      end

      if !ismissing(result[i,j]) && !startflag && endflag
        if result[i,j] == 0 && !startflag && endflag
          endflag = false
          result[i,:JobEndTime]=string(times[j])
        end
      elseif ismissing(result[i,j]) && !startflag && endflag
        result[i,:JobEndTime]=string(times[j])
      end
    end
  end


  # 調整が失敗した場合明示的にわかるように、JobStartTime,JobEndTimeを空白にする
  if !adjustedresultcheckflag
    result[:,:JobStartTime] .= missing
    result[:,:JobEndTime].= missing
  end

  if checkreturn
    return result,adjustedresultcheckflag
  else
    return result
  end

end


"""
uipathorchestratorschedulreadjustmentsub1(schedulesubplan,robotn,run_unit_time,jobn,timen,blocktime_start,blocktime_end,blocktime_dow;schedulcolumn::Int=6)

# 処理概要
調整結果不足分のスケジュール作成、処理結果の整合性確認および整形。

# 引数
* `scheduleplan`:スケジュール作成のために必要な諸元
* `robotn`:同時最大稼働ロボット数
* `run_unit_time`:実行単位時間、コマ割時間
* `jobn`:ジョブ数
* `timen`:時間コマ数
* `blocktime_start`:実行禁止時間帯（開始）
* `blocktime_end`:実行禁止時間帯（終了）
* `blocktime_dow`:実行禁止時間帯設定をするシート名
* `schedulcolumn`:スケジュールON,OFF開始列を指定（デフォルト：６）


# 結果（戻り値）
スケジュール調整結果を出力
"""
# スケジュール作成サブ１
function uipathorchestratorschedulreadjustmentsub1(schedulesubplan::DataFrame,robotn::Int,run_unit_time::Int,jobn::Int,timen::Int,schedule::String,blocktime_start::String,blocktime_end::String,blocktime_dow::String;schedulcolumn::Int=6)
  ## 数理モデル
  msub1 = JuMP.Model(Cbc.Optimizer)
 
   ## 変数
  JuMP.@variable(msub1, s[1:jobn,1:timen] ,Bin ) #ジョブ毎のコマ割りごとに実行有無を表示
 
   ## 定数
   runtime=zeros(Int,jobn,1) #ジョブ毎の実行時間
 
   ## ジョブ実行時間
   ###割り当てるコマ数を算出
   for i in 1:jobn
     runtime[i]=schedulesubplan[i,:runtime]/run_unit_time
   end
 
   ## 目的関数
   JuMP.@objective(msub1, Min, sum(schedulesubplan[1:end,:runtime])/run_unit_time-sum(s[1:jobn,1:timen] ))
 
   ## 制約条件
   ### ジョブ実行時間予約指定
   for i in 1:jobn
     flag =true
     if( convert(Bool,schedulesubplan[i,:Specifiedtime]) )
       for j in schedulcolumn:schedulcolumn+timen-1
         if(schedulesubplan[i,j] != 0 && flag)
           index=j-schedulcolumn+1
           JuMP.@constraint(msub1, s[i,index:index+runtime[i]-1] .== 1.0 )
            flag=false
         end
       end
     end
   end
 
   ### ジョブ実行時間制限
   for i in 1 :jobn
     JuMP.@constraint(msub1,sum(s[i,1:timen])==Float64(runtime[i]))
   end
 
   ### ロボット同時実行制限(ロボット数を超過させない)
   for i in 1 :timen
     JuMP.@constraint(msub1,sum(s[1:jobn,i])<=Float64(robotn) )
   end
   
   ### ブロックタイム設定
   if schedule == blocktime_dow || blocktime_dow =="all"
      timenames=names(scheduleplan)[schedulcolumn:end]
      blockcolstart=0
      blockcolend=0

      for i in 1:length(timenames) 
        if timenames[i] == blocktime_start
          blockcolstart=i
        end

        if timenames[i] == blocktime_end
          blockcolend=i
        end
      end

      for i in 1 :jobn
        for j in blockcolstart:blockcolend
          JuMP.@constraint(msub1, s[i,j] == 0.0 )
        end
      end
   end

   ## ソルバーの実行
   status = JuMP.optimize!(msub1)
 
   ## スケジュール案表示
   subplan=zeros(Int,jobn,timen)
   try
    subplan=map(Int,map(round,JuMP.value.(s)))
   catch
    subplan=zeros(Int,jobn,timen)
   end
 
 return subplan
end
