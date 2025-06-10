analyze_SIR_data <- function(file_path, appendix, path_save) {
  

  # Read the .trace file in CSV format
  data <- read.table(file_path, header = TRUE, sep = " ")
  
  # Calculate the total population per day
  total_population_columns <- c("S", "I", "R")
  data$total_population_per_day <- rowSums(data[total_population_columns])
  
  # Calculate the percentage of infected relative to the total population
  data$percentage_infected <- (data$I / data$total_population_per_day)
  
  # Create a "day" column as an incremental index
  data$days <- seq_len(nrow(data))
  
  # Save the dataframe to a CSV file in the same folder as the input file
  data_to_save <- data[c("days", "S", "percentage_infected")]
  colnames(data_to_save) <- c("day", "susceptibles", "percentage_infected")
  output_file_path <- paste0("SIR_analysis", "/percentage_infected_by_day_", appendix, ".csv")
  write.csv(data_to_save, file = output_file_path, row.names = FALSE)
  #write.csv(data_to_save, file = "~/Desktop/cottolengo-hospital-flame-gpu-2/resources/macro_model_files/percentage_infected_by_day.csv", row.names = FALSE)
  
}
