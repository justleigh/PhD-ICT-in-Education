# Load necessary libraries
library(readr)
library(dplyr)

# Read in the cleaned dataset
pisa_data_cleaned_4 <- read.csv("data/private/processed/2022/pisa2022_cleaned_4_high_missingness_exclusion.csv")

# Select only numeric variables for correlation analysis
numeric_vars <- pisa_data_cleaned_4 %>%
  select_if(is.numeric)

# Calculate the correlation matrix
cor_matrix <- cor(numeric_vars, use = "complete.obs")  # Use "complete.obs" to handle missing data

# Identify highly correlated pairs (correlation > 0.85)
high_correlation_pairs <- which(abs(cor_matrix) > 0.85, arr.ind = TRUE)
high_correlation_pairs <- high_correlation_pairs[high_correlation_pairs[,1] < high_correlation_pairs[,2], ]  # Remove duplicates

# Create a data frame to store the results
if (nrow(high_correlation_pairs) > 0) {
  correlated_vars <- data.frame(
    Variable1 = rownames(cor_matrix)[high_correlation_pairs[, 1]],
    Variable2 = rownames(cor_matrix)[high_correlation_pairs[, 2]],
    Correlation = round(cor_matrix[high_correlation_pairs], 2)  # Round correlation values to 2 decimal places
  )
  
  # Save the results to a CSV file in the specified folder
  write.csv(correlated_vars, "data/private/metadata/2022/statistical_screening_results.csv", row.names = FALSE)
  
  cat("The statistical screening results have been saved to 'data/private/metadata/2022/statistical_screening_results.csv'.\n")
} else {
  cat("No pairs with correlation greater than 0.85 were found.\n")
}
