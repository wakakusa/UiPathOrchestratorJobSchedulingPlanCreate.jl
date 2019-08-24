function plotplanmaster(plan::DataFrame;schedulcolumn::Int=6)
  xs = map(String,names(plan)[schedulcolumn:end] )
  ys = map(String,plan[:,:jobname])

  plot=Plots.heatmap(xs, ys, convert(Matrix,plan[:,schedulcolumn:end]), legend=false,c=ColorGradient([:white,:blue]))

  return plot

end


function plotplangr(plan::DataFrame;schedulcolumn::Int=6)
  gr()

  plot=plotplanmaster(plan,schedulcolumn=schedulcolumn)
  gui(plot)
end

function plotplanplotlyjs(plan::DataFrame;schedulcolumn::Int=6)
  plotlyjs()

  plot=plotplanmaster(plan,schedulcolumn=schedulcolumn)
  gui(plot)
end

function exportplan(plan::DataFrame;ExcelFilePath::String="")
  if(ExcelFilePath=="")
    ExcelFilePath="UiPathOrchestratorJobSchedulingPlan.xlsx"
  end
 
 XLSX.writetable(ExcelFilePath, REPORT_jobplan=( collect(DataFrames.eachcol(plan)), DataFrames.names(plan) )  )
end

#function exportfullplan(plan::Array,r::Array,scheduleplan::DataFrame;ExcelFilePath::String="")
#  if(ExcelFilePath=="")
#    ExcelFilePath="UiPathOrchestratorJobSchedulingPlan.xlsx"
#  end
#
#  planwork=scheduleplan[6:end]
#  for i in 1:size(plan)[2]
#    planwork[:,i]=plan[:,i]
#  end
#
#  rwork=scheduleplan[6:end]
#  for i in 1:size(plan)[2]
#    rwork[:,i]=r[:,i]
#  end
#
# XLSX.writetable(ExcelFilePath, REPORT_jobplan=( collect(DataFrames.eachcol(planwork)), DataFrames.names(planwork) ), REPORT_robotplan=( collect(DataFrames.eachcol(rwork)), DataFrames.names(rwork) ))
#end

plotplan=plotplanplotlyjs
