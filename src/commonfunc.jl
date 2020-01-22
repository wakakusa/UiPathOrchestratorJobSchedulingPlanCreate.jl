"""
    createtimeset()

# 処理概要
時刻のデータセットを作成

# 引数
* なし

# 結果（戻り値）
* 時間の組み合わせ（文字列）
"""
function createtimeset()
  timemaster=Matrix{String}(undef,1,1441)
  HH=["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
  MM=["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]

  timemaster[1,1441]=string("24:00")

  for i in 1:size(HH)[1]
      for j in 1:size(MM)[1]
          timemaster[1,60*(i-1)+j]=string(HH[i],":",MM[j])
      end
  end

  timessymbol=map(Symbol,timemaster)
  timesdate=map(dt->DateTime(dt,"HH:MM"),timemaster)
 
  return timemaster,timessymbol,timesdate
end


"""
    ContinuousOperation(x...)

# 処理概要
処理時間が連続しているか確認

# 引数
* `x`:

# 結果（戻り値）
* 連続している時間数
"""
function ContinuousOperation(x...) 
  sigma=0
  for i in 1:length(x)-1
      sigma=sigma+x[i]*x[i+1]     
  end
  return sigma
end
