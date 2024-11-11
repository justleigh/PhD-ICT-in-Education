# Navigating the Digital Divide: The Role of ICT in Enhancing Educational Outcomes in Thailand

### Project Aim
This project seeks to explore the role of Information and Communications Technology (ICT) in enhancing educational outcomes in Thailand. Grounded in the PISA ICT Framework and guided by the Unified Theory of Acceptance and Use of Technology (UTAUT), this research aims to assess the impact of ICT integration within the Thai educational system, particularly focusing on how ICT access and usage among 15-year-old students correlate with their well-being and their performance in key areas such as reading, mathematics, and science.

This research has the potential to inform educational policymakers and practitioners about the most effective strategies for integrating ICT into Thai schools, ultimately aiming to enhance educational equity and quality in an increasingly digital world.

### Research Questions

The investigation is structured around several key research questions:

1. How does in-classroom use of ICT affect student learning outcomes in Thailand?
2. What role does ICT use outside of the classroom play in the learning outcomes of Thai students?
3. How do various contextual factors, such as socio-economic status and access to technology, moderate the relationship between ICT use and educational performance?

### Datasets
The analysis will be conducted using data from the following sources:

**PISA Data:** This includes international datasets from the years 2000, 2003, 2006, 2009, 2012, 2015, 2018, and 2022, focusing on 15-year-old Thai students' performance in various educational domains and their access to and use of ICT.

**National Statistical Office (Thailand):** This source provides demographic and socioeconomic data relevant to the educational context in Thailand.

**Information System for Equitable Education (iSEE 2.0):** Managed by the Equitable Education Fund (EEF), iSEE 2.0 offers data on educational resources and equity in education across different regions of Thailand.

**Education Management Information System (EMIS):** From the Office of Basic Education Commission (OBEC), EMIS includes detailed information on school infrastructure, including ICT facilities and resources.

**Management Information System (MIS):** Provided by the National Institute of Educational Testing Services (NIETS), MIS contains data on educational outcomes, such as test scores and assessments, across various levels of Thai education.

Details for reproducibility and accurate documentation of the research project's software environment are as follows:

### Computer Architecture and Operating System:
Model Name: MacBook Air

Chip: Apple M1 

Total Number of Cores: 8 (4 performance and 4 efficiency)

Memory: 8 GB 

System Version: macOS 11.3.1 (20E241)

Kernel Version: Darwin 20.4.0

System Integrity Protection: Enabled 

### R Environment:
R version: 4.3.0 (2023-04-21)

Platform: aarch64-apple-darwin20 (64-bit)

Running under: macOS Big Sur 11.3.1

### R Packages:
Base Packages: stats, graphics, grDevices, utils, datasets, methods, base

Other attached packages: ggplot2_3.4.4

### System Details:
Matrix Products (BLAS & LAPACK) and their paths:

BLAS: /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib

LAPACK: /Library/Frameworks/R.framework/Versions/4.3-arm64/Resources/lib/libRlapack.dylib with LAPACK version 3.11.0

### Locale and Time Zone:
Locale: en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

Time zone: Asia/Bangkok

tzcode source: internal

### Software Toolchain & Supporting Infrastructure:
**Integrated Development Environment (IDE):**

RStudio, Version: 2023.06.2 Build 561

Release: "Mountain Hydrangea" (de44a311, 2023-08-25) for macOS

**Version Control:**

Git version 2.30.1 (Apple Git-130)

Repository URL: https://github.com/justleigh/PhD_Data_Analysis

### Installation
To set up this project locally, please follow these steps:

**1.** Install R: If you do not already have R installed on your computer, you can download it from the Comprehensive R Archive Network (CRAN). Choose the version appropriate for your operating system (Windows, MacOS, or Linux).

**2.** Install RStudio: RStudio is a powerful and user-friendly interface for R. It's recommended to use RStudio for this project for ease of managing files, scripts, and packages. Download the free version of RStudio from RStudio's website.

**3.** Clone or Download the Project Repository: If the project is hosted on a version control system like GitHub, you can clone the repository using Git or download the entire project as a ZIP file and then unpack it in your local workspace.

To clone the repository using Git, run: git clone https://github.com/justleigh/PhD_Data_Analysis

**4.** Open the R Project: Open RStudio, go to File > Open Project, and navigate to the directory where you cloned or unpacked the project. Open the file ending with .Rproj.

**5.** Install Required Packages: This project may require certain R packages to be installed. You can install them by running the following commands in RStudio's console:

  packages <- c("tidyverse", "haven", "readr", "ggplot2", "dplyr", "knitr", "rmarkdown")
  
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)

  lapply(packages, require, character.only = TRUE)
  
**6.** Check Data: Ensure that all necessary data files are present within the data directory of the project as outlined in the project structure. Due to privacy or size considerations, some data may not be included in the repository and might require separate download or access permissions.

By following these steps, you should be able to set up and begin working on the project in a local environment.

## Usage
How to use the project files, including a guide to running the analysis, generating outputs, and any other relevant user instructions.

## Structure
The project is organized into the following directories and files:

- `README.md`: Provides an overview of the project, including its aim, research questions, datasets, and instructions for setup and usage.
- `PhD_Data_Analysis.Rproj`: The RStudio project file, which sets the working directory and project-specific settings.
- `data/`: Contains raw data files used in the analysis. This includes PISA datasets and other relevant data from the National Statistical Office (Thailand), iSEE 2.0, EMIS, and MIS.
- `docs/`: Holds documentation related to the project, such as detailed descriptions of the datasets, data dictionaries, and any relevant research papers or reports.
- `scripts/`: Contains R scripts for data cleaning, analysis, and visualization. Each script should be named clearly to indicate its purpose (e.g., `01_data_preprocessing.R`, `02_data_analysis.R`, etc.).
- `output/`: Stores the outputs generated by the scripts, such as processed data, tables, figures, and the final analysis report.
- `Rmd/`: Contains R Markdown files for dynamic report generation, including the main analysis report and any supplementary documents.

## Data
PISA Dataset: PISA2000data.csv
  
  - Accessed on: 2023-10-23
  
  - Source URL: https://pisathailand.ipst.ac.th/databases/

PISA Dataset: PISA2003data.csv
  
  - Accessed on: 2023-10-23
  
  - Source URL: https://pisathailand.ipst.ac.th/databases/

PISA Dataset: PISA2006data.csv
  
  - Accessed on: 2023-10-23
  
  - Source URL: https://pisathailand.ipst.ac.th/databases/

PISA Dataset: PISA2009data.csv
  
  - Accessed on: 2023-10-23
  
  - Source URL: https://pisathailand.ipst.ac.th/databases/

PISA Dataset: PISA2012data.csv
  
  - Accessed on: 2023-10-23
  
  - Source URL: https://pisathailand.ipst.ac.th/databases/

PISA Dataset: PISA2015data.csv
  
  - Accessed on: 2023-10-23
  
  - Source URL: https://pisathailand.ipst.ac.th/databases/

PISA Dataset: PISA2018data.csv
  
  - Accessed on: 2023-10-23
  
  - Source URL: https://pisathailand.ipst.ac.th/databases/

PISA Dataset: PISA2022data.csv
  
  - Accessed on: 2024-03-08
  
  - Source URL: https://pisathailand.ipst.ac.th/databases/

Thai Government Dataset: [Exact Dataset Name]
  
  - Accessed on: [Date]
  
  - Source URL: [Exact URL]

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
How to cite the project or its findings if used in other works.

## Contact
Please feel free to contact me with questions or feedback at leigh.pea@mahidol.edu.
