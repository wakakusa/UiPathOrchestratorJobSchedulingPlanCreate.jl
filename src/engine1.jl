function uipathorchestratorschedulreadjustment(scheduleplan::DataFrame,robotn::Int,run_unit_time::Int,jobn::Int,timen::Int;schedulcolumn::Int=6)
## 数理モデル
 m1 = JuMP.Model(with_optimizer(Ipopt.Optimizer))

  ## 変数
 JuMP.@variable(m1, 0<=s[1:jobn,1:timen] <=1 ) #ジョブ毎のコマ割りごとに実行有無を表示

  ## 定数
  runtime=zeros(Int,jobn,1) #ジョブ毎の実行時間

  ## ジョブ実行時間
  ###割り当てるコマ数を算出
  for i in 1:jobn
    runtime[i]=scheduleplan[i,:runtime]/run_unit_time
  end

  ###要調整 ジョブに余裕を持たせるかどうか
  #runtime=runtime.+1

  ## 目的関数
  JuMP.@objective(m1, Min, sum(scheduleplan[1:end,:runtime])/run_unit_time-sum(s[1:jobn,1:timen] ))

  ## 制約条件
  ### 割当コマ数が１の場合の不具合対策
  ### 条件その１
  for i in 1:jobn
    if(runtime[i]==1)
      x1=Int(round(timen/2))
      x2=Int(round(timen/2))+1
      JuMP.@NLconstraint(m1, abs(sum(s[i,j] for j in 1:x1)-sum(s[i,] for j in x2:timen )) >= 1.0 )
    end
  end

  ### 条件その2
  for i in 1:jobn
    if(runtime[i]==1)
      x1=1:2:timen
      x2=2:2:timen
      JuMP.@NLconstraint(m1, abs(sum(s[i,j] for j in x1)-sum(s[i,] for j in x2 )) >= 1.0 )
    end
  end

  ### 条件その3
  for i in 1:jobn
    if(runtime[i]==1)
      x1=StatsBase.sample(1:timen, Int(round(timen/2)) ,replace=false, ordered=true)
      x2=setdiff(1:timen,x1)
      JuMP.@NLconstraint(m1, abs(sum(s[i,j] for j in x1)-sum(s[i,] for j in x2 )) >= 1.0 )
    end
  end

  ### 条件その4
  for i in 1:jobn
    if(runtime[i]==1)
      x1=StatsBase.sample(1:timen, Int(round(timen/2)) ,replace=true, ordered=true)
      x2=setdiff(1:timen,x1)
      JuMP.@NLconstraint(m1, abs(sum(s[i,j] for j in x1)-sum(s[i,] for j in x2 )) >= 1.0 )
    end
  end
  
  ### 条件その5
  for i in 1:jobn
    if(runtime[i]==1)
      x1=StatsBase.sample(1:timen, rand(1:timen,1)[1] ,replace=true, ordered=true)
      x2=setdiff(1:timen,x1)
      JuMP.@NLconstraint(m1, abs(sum(s[i,j] for j in x1)-sum(s[i,] for j in x2 )) >= 1.0 )
    end
  end


  ### ジョブ実行時間予約指定
  for i in 1:jobn
    flag =true
    if( convert(Bool,scheduleplan[i,:Specifiedtime]) )
      for j in schedulcolumn:schedulcolumn+timen-1
        if(typeof(scheduleplan[i,j] ) != Missing && flag)
          index=j-5
          JuMP.@constraint(m1, s[i,index:index+runtime[i]-1] .== 1.0 )
           flag=false
        end
      end
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
  
  ## ソルバーの実行
  status = JuMP.optimize!(m1)

  ## スケジュール案表示
  plan=zeros(Int,jobn,timen)
  plan=map(Int,map(round,JuMP.value.(s)))

  return plan,runtime
end

function adjustedresultcheck(plan::Array,runtime::Array,scheduleplan::DataFrame,robotn::Int,jobn::Int,timen::Int;schedulcolumn::Int=6)
  adjustedresultcheckmastarflag=true

  #ジョブごとに実行時間確保されているかチェック
  for i in 1:jobn
    adjustedresultcheckflag1=true 
    for j in 1:timen
      if(adjustedresultcheckmastarflag && plan[i,j]==1 && adjustedresultcheckflag1)
        adjustedresultcheckflag1=false
        if(sum(plan[i,j:(j+runtime[i]-1)])!=runtime[i])
          adjustedresultcheckmastarflag=false
        end
      end
    end
  end

  # ロボット数超過していないか確認
  for i in 1:timen
    if(sum(plan[:,i]) > robotn)
      adjustedresultcheckmastarflag=false
    end
  end

  # 処理時間が連続しているか確認
  for i in 1:jobn
    x=plan[i,:]
    if(sum(ContinuousOperation(x...))!=runtime[i]-1)
      adjustedresultcheckmastarflag=false
    end
  end

  if(!adjustedresultcheckmastarflag)
    plan=zeros(Int,jobn,timen)
  end

  result=scheduleplan[:,schedulcolumn:end ]
  result[:,:].= plan
  result=hcat(scheduleplan[:,1:schedulcolumn-1 ] , result)

  #処理開始時間および終了時間を取得
  times=names(scheduleplan)

  for i in 1 :  size(scheduleplan)[1]
    startflag=true
    endflag=true

    for j in schedulcolumn : size(scheduleplan)[2]
      if(result[i,j] == 1 && startflag)
        startflag = false
        result[i,:JobStartTime]=string(times[j])
      end

      if(result[i,j] == 0 && !startflag && endflag )
        endflag = false
        result[i,:JobEndTime]=string(times[j])
      end
    end
  end

  return result

end

