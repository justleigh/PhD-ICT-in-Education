# Descriptive Statistics – PISA 2022 Data Preparation and Results

This folder contains all scripts used to prepare, compute, and export descriptive statistics from the fully cleaned and imputed PISA 2022 dataset. The outputs serve as the foundation for exploratory and inferential analyses, ensuring statistical validity and alignment with the PISA 2022 ICT Framework and the Multi-Level Framework of Technology Acceptance and Use (MLFTAU).

## 🧾 Script Overview

| No. | Script Name | Description |
|-----|-------------|-------------|
| 01  | `01_mapping_table_data_type_update.R` | Updates the variable mapping table with verified `cleaned_data_type` labels by cross-referencing actual data types in the final cleaned dataset. |
| 02  | `02_prepare_descriptive_statistics.R` | Prepares the variable mapping table and descriptive statistics file for integration. Joins key metadata (e.g., conceptual group, broad learning context). |
| 03  | `03_generate_descriptive_statistics_results.R` | Aggregates numeric and categorical statistics by conceptual group and learning context. Exports grouped CSV summary files for documentation and interpretation. |

## 📂 Output Files

These scripts generate the following outputs (automatically saved in the corresponding output directory):

- `pisa2022_descriptive_statistics_grouped_numeric.csv`  
- `pisa2022_descriptive_statistics_grouped_categorical.csv`

These files provide grouped summaries by:

- `conceptual_group`:  
  - Student Demographics and Background  
  - Home Environment and Digital Access  
  - School Environment and ICT Resources  
  - Instructional Practices and Teacher Factors  
  - Student Learning and Well-Being Outcomes

- `broad_learning_context`:  
  - In School  
  - Out of School  
  - In and Out

## 🔍 Purpose

This process ensures:

- Accurate numeric/categorical treatment of all variables
- Grouped interpretability aligned with theoretical constructs
- Fully reproducible documentation and transparency of preprocessing

## 🛠 Framework Alignment

Descriptive statistics are interpreted and grouped based on both:

- Thematic relevance (`conceptual_group`)  
- Learning context (`broad_learning_context`)

This alignment supports integration into subsequent random forest and regression models.

---

*This README supports long-term reproducibility and transparency of the EDA phase. It should be updated if script names or output logic changes in future iterations.*
