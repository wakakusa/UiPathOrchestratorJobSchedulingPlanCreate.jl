# 処理時間が連続しているか確認
function ContinuousOperation(x...) 
  sigma=0
  for i in 1:length(x)-1
      sigma=sigma+x[i]*x[i+1]     
  end
  return sigma
end

function uipathorchestratorschedulreadjustment(scheduleplan::DataFrame,robotn::Int,run_unit_time::Int,jobn::Int,timen::Int;schedulcolumn::Int=6)
## 数理モデル
 m1 = JuMP.Model(with_optimizer(Ipopt.Optimizer))

  ## 変数
 JuMP.@variable(m1, 0<=s[1:jobn,1:timen] <=1 ) #ジョブ毎のコマ割りごとに実行有無を表示
 JuMP.@variable(m1, 0<=r[1:robotn,1:timen,1:jobn] <=1 ) #ロボット毎のコマ割りごとに実行有無を表示

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
  JuMP.@objective(m1, Min, sum(r[1:robotn,1:timen,1:jobn] ))

  ## 制約条件
  ### ロボット同時実行制限
  for  i in 1:jobn
    sigma=0
    for j in 1:timen
      for k in 1: robotn

      end
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
        end  #### 連続性をチェックするための関数を定義
        #  function ContinuousOperation(x...) 
        #    sigma=0
        #    for i in 1:length(x)-1
        #        sigma=sigma+x[i]*x[i+1]     
        #    end
        #    return sigma
        #  end
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

  return plan,r,runtime
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

