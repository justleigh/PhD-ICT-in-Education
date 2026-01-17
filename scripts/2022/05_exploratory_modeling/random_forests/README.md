# Random Forest Scripts – PISA 2022 Exploratory Modeling

This folder contains nine systematically developed Random Forest scripts used to estimate variable importance across different theoretical frameworks, learning contexts, and predictor structures. Each script is numbered in execution order and named to reflect its analytical focus.

## 🔍 Purpose

To identify the most important predictors of student outcomes in mathematics, reading, and science using Random Forest models, guided by the PISA Questionnaire Framework, the PISA ICT Framework, and the Multi-Level Framework of Technology Acceptance and Use (MLFTAU). All models are explicitly contextualized within either in-school or out-of-school learning settings. 

## 🧩 Common Modeling Parameters

- Dataset: `pisa2022_cleaned_19_composites_added.rds`
- Outcomes: PV1–PV10 for MATH, READ, SCIE
- Sampling: 5,000 students per PV, weighted by `W_FSTUWT`
- Importance Metrics:
  - Standard RF: Increase in Node Purity
  - Conditional RF: Permutation Importance (normalized)
- COVID-related variables: Excluded
- Derived variable inputs for PVs: Excluded
- Outputs: Raw and aggregated importance tables, top 20 plots, conditional PDPs, and model tracker updates

## 🧾 Script List

| No. | Script Name | Description |
|-----|-------------|-------------|
| 01 | `01_rf_global_all_predictors.R` | All predictors modeled regardless of framework domains or constructs |
| 02 | `02_rf_pisa_contextual_ict_in_class_domains.R` | All in-school predictors (contextual and ICT-related) |
| 03 | `03_rf_pisa_contextual_ict_in_class_constructs.R` | All in-school predictors (contextual and ICT-related) |
| 04 | `04_rf_mfiltau_contextual_ict_in_class_domains.R` | MLFTAU in-school contextual predictors (contextual and ICT-related) |
| 05 | `05_rf_mfiltau_contextual_ict_in_class_constructs.R` | MLFTAU in-school contextual predictors (contextual and ICT-related) |
| 06 | `06_rf_pisa_contextual_ict_outside_domains.R` | All out-of-school predictors (contextual and ICT-related) |
| 07 | `07_rf_pisa_contextual_ict_outside_constructs.R` | All out-of-school predictors (contextual and ICT-related) |
| 08 | `08_rf_mfiltau_contextual_ict_outside_domains.R` | MLFTAU outside-school contextual predictors (contextual and ICT-related) |
| 09 | `09_rf_mfiltau_contextual_ict_outside_constructs.R` | MLFTAU outside-school contextual predictors (contextual and ICT-related) |

---
