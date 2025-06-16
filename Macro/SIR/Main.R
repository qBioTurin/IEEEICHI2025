# Install the epimod library
library(devtools)
install_github("https://github.com/qBioTurin/epimod", ref="master", force = TRUE)

library(epimod)

downloadContainers()

setwd("~/IEEEICHI2025/Macro/SIR/")




# Generate the model
start_time <- Sys.time()
model.generation(net_fname = "./Net/SIR.PNPRO")
end_time <- Sys.time()-start_time




### Model Analysis
#   Deterministic:

model.analysis(solver_fname = "SIR.solver",
               parameters_fname = "Input/Functions_list_ModelAnalysis.csv",
               solver_type = "LSODA",
               f_time = 200,
               s_time = 1
)

# Generate plot for deterministic model analysis
source("Rfunction/ModelAnalysisPlot.R")

AnalysisPlot = ModelAnalysisPlot(Stoch = F ,print = F,
                                 trace_path = "./SIR_analysis/SIR-analysis-1.trace")
AnalysisPlot$plAll

# Deterministic analysis with lower infection rate
model.analysis(solver_fname = "SIR.solver",
               parameters_fname = "Input/Functions_list_ModelAnalysis_v2.csv",
               solver_type = "LSODA",
               f_time = 200,
               s_time = 1
)

AnalysisPlot = ModelAnalysisPlot(Stoch = F ,print = F,
                                 trace_path = "./SIR_analysis/SIR-analysis-1.trace")
AnalysisPlot$plAll




#   Stochastic:
model.analysis(solver_fname = "SIR.solver",
               parameters_fname = "Input/Functions_list_ModelAnalysis.csv",
               solver_type = "SSA",
               n_run = 500,
               parallel_processors = 2,
               f_time = 200,
               s_time = 1
)

# Generate plot for stochastic model analysis
AnalysisPlot = ModelAnalysisPlot(Stoch = T ,print = F,
                                 trace_path = "./SIR_analysis/SIR-analysis-1.trace")

AnalysisPlot$plAll
AnalysisPlot$plAllMean

model.analysis(solver_fname = "SIR.solver",
               parameters_fname = "Input/Functions_list_ModelAnalysis_v2.csv",
               solver_type = "SSA",
               n_run = 500,
               parallel_processors = 2,
               f_time = 200,
               s_time = 1
)

AnalysisPlot = ModelAnalysisPlot(Stoch = T ,print = F,
                                 trace_path = "./SIR_analysis/SIR-analysis-1.trace")

AnalysisPlot$plAll
AnalysisPlot$plAllMean




# Generate file for Forge4Flame
source("Rfunction/analyze_SIR_data.R")

analyze_SIR_data(file_path ="SIR_analysis/SIR-analysis-1.trace", appendix = "data", path_save = "SIR_analysis/")
