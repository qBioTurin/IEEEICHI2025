library(epimod)

library(devtools)
install_github("https://github.com/qBioTurin/epimod", ref="master", force = TRUE)
library(epimod)

renv::rebuild("epimod", recursive = TRUE)

downloadContainers()

start_time <- Sys.time()
model.generation(net_fname = "./Net/SIR.PNPRO")
end_time <- Sys.time()-start_time

### Model Analysis
# Deterministic:

model.analysis(solver_fname = "SIR.solver",
               parameters_fname = "Input/Functions_list_ModelAnalysis.csv",
               solver_type = "LSODA",
               f_time = 7*10, # weeks
               s_time = 1
)

source("Rfunction/ModelAnalysisPlot.R")

AnalysisPlot = ModelAnalysisPlot(Stoch = F ,print = F,
                                 trace_path = "./SIR_analysis/SIR-analysis-1.trace")
AnalysisPlot$plAll

model.analysis(solver_fname = "SIR.solver",
               parameters_fname = "Input/Functions_list_ModelAnalysis.csv",
               solver_type = "SSA",
               n_run = 500,
               parallel_processors = 2,
               f_time = 7*10, # weeks
               s_time = 1
)

AnalysisPlot = ModelAnalysisPlot(Stoch = T ,print = F,
                                 trace_path = "./SIR_analysis/SIR-analysis-1.trace")

AnalysisPlot$plAll
AnalysisPlot$plAllMean 

source("Rfunction/analyze_SIR_data.R")

analyze_SIR_data(file_path ="SIR_analysis/SIR-analysis-1.trace", appendix = "data", path_save = "SIR_analysis/")


