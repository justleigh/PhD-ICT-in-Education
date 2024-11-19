# List of years you have PISA data for
years <- c(2000, 2003, 2006, 2009, 2012, 2015, 2018, 2022)

# Loop through each year to clean and save the dataset
for (year in years) {
  # Load data for the specific year
  pisa_data <- load_pisa_data(year)
  
  # Calculate the missing data summary
  missing_data_summary <- sapply(pisa_data, function(x) sum(is.na(x)) / length(x) * 100)
  missing_data_summary <- data.frame(Variable = names(missing_data_summary), 
                                     Missing_Percentage = missing_data_summary)
  
  # Identify variables with more than 50% missing data
  high_missing_summary <- missing_data_summary %>%
    filter(Missing_Percentage > 50) %>%
    arrange(desc(Missing_Percentage))
  
  # Remove variables with 100% missing data
  cleaned_data <- pisa_data %>% select(-one_of(high_missing_summary$Variable[high_missing_summary$Missing_Percentage == 100]))
  
  # Print a message summarizing the cleaning process for this year
  cat(sprintf("For year %d: Removed %d variables with 100%% missing data.\n", 
              year, sum(high_missing_summary$Missing_Percentage == 100)))
  
  # Define the path for saving the cleaned dataset in the existing year folder in the processed directory
  cleaned_data_file <- paste0("data/processed/", year, "/cleaned_pisa_data_", year, ".csv")
  write.csv(cleaned_data, cleaned_data_file, row.names = FALSE)
}