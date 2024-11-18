# Navigating the Digital Divide: The Role of ICT in Enhancing Educational Outcomes in Thailand

### Project Aim
This project seeks to explore the role of Information and Communications Technology (ICT) in enhancing educational outcomes in Thailand. Grounded in the PISA ICT Framework and the Multi-Level Framework of Technology Acceptance and Use (MLFTAU), this research aims to assess the impact of ICT integration within the Thai educational system, particularly focusing on how ICT access and usage among 15-year-old students correlate with their well-being and their performance in key areas such as reading, mathematics, and science.

This research has the potential to inform educational policymakers and practitioners about the most effective strategies for integrating ICT into Thai schools, ultimately aiming to enhance educational equity and quality in an increasingly digital world.

### Research Questions

The investigation is structured around several key research questions:

1. How does in-classroom use of ICT affect student learning outcomes in Thailand?
2. What role does ICT use outside of the classroom play in the learning outcomes of Thai students?
3. How do various contextual factors, such as socio-economic status and access to technology, moderate the relationship between ICT use and educational performance?

### Folder Structure
The project is organized into the following folders:

- `data/`: Contains data files used in the analysis.
  - `raw/`: Original PISA datasets for each year (e.g., 2000, 2003, etc.).
  - `processed/`: Stage 1 cleaned data files (100% missing variables removed).
  - `metadata/`: Summaries of missing data, codebooks, and variable descriptions.

- `docs/`: Contains additional documentation for the project.
  - `system_details.md`: Details about the system and software environment used for the analysis.

- `output/`: Stores generated outputs such as tables, figures, and final reports.

- `scripts/`: R scripts for data cleaning, metadata generation, and analysis.

- `Rmd/`: R Markdown files for dynamic report generation, including the main analysis report.

- `README.md`: This document, providing an overview of the project.

### Datasets
**PISA Datasets**:
- Years: 2000, 2003, 2006, 2009, 2012, 2015, 2018, 2022.
- Focus: 15-year-old Thai students' performance and ICT access/usage.
- Source: [PISA Thailand Database](https://pisathailand.ipst.ac.th/databases/)

**National Statistical Office (Thailand):** This source provides demographic and socioeconomic data relevant to the educational context in Thailand.

**Information System for Equitable Education (iSEE 2.0):** Managed by the Equitable Education Fund (EEF), iSEE 2.0 offers data on educational resources and equity in education across different regions of Thailand.

**Education Management Information System (EMIS):** From the Office of Basic Education Commission (OBEC), EMIS includes detailed information on school infrastructure, including ICT facilities and resources.

**Management Information System (MIS):** Provided by the National Institute of Educational Testing Services (NIETS), MIS contains data on educational outcomes, such as test scores and assessments, across various levels of Thai education.

Details for reproducibility and accurate documentation of the research project's software environment are as follows:

### System Details
For details on the system and software environment used in this analysis, see [System Details](docs/system_details.md).

**Version Control:**

Git version 2.30.1 (Apple Git-130)
```bash
Repository URL: https://github.com/justleigh/PhD-ICT-Education-Analysis
```

### Installation
To set up this project locally, please follow these steps:

### Installation
To set up this project locally:

1. **Install R and RStudio:**
   - Download R from [CRAN](https://cran.r-project.org/).
   - Download RStudio from [RStudio](https://posit.co/download/rstudio/).

2. **Clone the Repository:**
   git clone https://github.com/justleigh/PhD_Data_Analysis.git

3. **Install Required Packages:** 
To set up this project locally, install the required R packages by running the following in RStudio:

```r
# List of required packages
packages <- c("tidyverse", "haven", "readr", "ggplot2", 
              "rmarkdown", "knitr", "intsvy", 
              "janitor", "stringr", "lubridate", "forcats", "here")

# Install any missing packages
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if (length(new_packages)) install.packages(new_packages)

# Load all packages
lapply(packages, require, character.only = TRUE)
```
  
4. **Check Data:** 
Ensure that all necessary data files are present within the data directory of the project as outlined in the project structure. Due to privacy or size considerations, some data may not be included in the repository and might require separate download or access permissions.

By following these steps, you should be able to set up and begin working on the project in a local environment.

## Usage
How to use the project files, including a guide to running the analysis, generating outputs, and any other relevant user instructions.

## Scripts
A brief overview of the scripts included, what each script does, and in what order they should be run.

## Results
An overview of the kinds of results expected to be generated, including figures, tables, and key findings.

## Dependencies
A list of R packages and other dependencies required to run the scripts and perform the analysis.

## Authors
The names and contact information of the researchers involved in the project.

## License
The license under which the project is released, which governs how others can use and distribute your work.

## Acknowledgements
Credits to any individuals, organizations, or funding bodies that have contributed to the project.

## Citation
Pearson, L. (2025). Navigating the Digital Divide: The Role of ICT in Enhancing Educational Outcomes in Thailand.

## Contact
Please feel free to contact me with questions or feedback at leigh.pea@mahidol.edu.
