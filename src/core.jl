#計算の前提条件読込み
function readprerequisite(ExcelFilePath::String,parameters::String,schedule::String)
  parameters=DataFrames.DataFrame(XLSX.readtable(ExcelFilePath, parameters)...)  
  scheduleplan=DataFrames.DataFrame(XLSX.readtable(ExcelFilePath, schedule)...)

  # 前提条件設定
  robotn=parameters[parameters[:,:parameter] .== "all_run_robot",:Int][1] #ロボット
  run_unit_time=parameters[parameters[:,:parameter] .== "run_unit_time",:Int][1] #実行単位時間、コマ割時間
  jobn=size(scheduleplan)[1] #ジョブ数
  timen=size(scheduleplan)[2]-5 #時間コマ数

  return scheduleplan,robotn,run_unit_time,jobn,timen
end

function uipathorchestratorschedulreadjustment(scheduleplan::DataFrame,robotn::Int,run_unit_time::Int,jobn::Int,timen::Int)
## 数理モデル
  m1=JuMP.Model( with_optimizer(Cbc.Optimizer ))

  ## 変数
 JuMP. @variable(m1, 0<=s[1:jobn,1:timen] <=1,Bin ) #ジョブ毎のコマ割りごとに実行有無を表示
 JuMP.@variable(m1, 0<=r[1:robotn,1:timen,1:jobn] <=1,Bin ) #ロボット毎のコマ割りごとに実行有無を表示

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
    for j in 6:6+timen-1
      if(typeof(scheduleplan[i,j] ) != Missing && flag)
        index=j-5
        JuMP.@constraint(m1, s[i,index:index+runtime[i]-1] .== 1 )
         flag=false
      end
    end
    end
  end

  ### ジョブ実行時間制限
  for i in 1 :jobn
    JuMP.@constraint(m1,sum(s[i,1:timen])==runtime[i])
  end

  ### ロボット同時実行制限(ロボット数を超過させない)
  for i in 1 :timen
    JuMP.@constraint(m1,sum(s[1:jobn,i])<=robotn)
  end

  ### ジョブ連続実行制限
  for i in 1:jobn
    sigma=0
    flag=true
    for j in 1:timen
      if(s[i,j]==1 && flag)
        sigma=sum(s[i,j:j+runtime[i]-1])
        flag=false
      end
    end
    JuMP.@constraint(m1,sigma==runtime[i])
  end

  ## ソルバーの実行
  status = JuMP.optimize!(m1)

  ## スケジュール案表示
  plan=zeros(Int,jobn,timen)

  for i in 1:jobn
    temp=sort(JuMP.value.(s[i,1:timen]) ,rev=true)[1:runtime[i]]

    for j in 1:timen
      for k in 1:runtime[i]
        if( JuMP.value.(s[i,j])==temp[k])
          plan[i,j]=1
        end
     end
    end
  end

  return plan,r,runtime
end

function adjustedresultcheck(plan::Array,runtime::Array,scheduleplan::DataFrame)
  adjustedresultcheckmastarflag=true
  jobn,timen=size(plan)

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

  if(adjustedresultcheckmastarflag==false)
    plan=zeros(Int,jobn,timen)
  end

  result=scheduleplan[:,6:end ]
  result[:,:].= plan
  result=hcat(scheduleplan[:,1:2 ] , result)

  return result

end

