# Civil War Spillovers and Terrorism in Neighboring States

> **Project Overview:** A quantitative macro-level analysis examining whether domestic civil wars increase terrorist activity in contiguous neighboring countries. This project handles the full data science pipeline in R: extracting and cleaning international conflict databases, constructing a complex dyad-year panel dataset, and executing fixed-effects econometric modeling.

## Research Question
*Do civil wars in one country systematically increase the incidence of terrorism in neighboring states?*

### Theoretical Framework
Civil wars fundamentally alter regional security dynamics through three core spillover mechanisms:
1. **Resource Diffusion:** Cross-border flow of illicit weapons and displaced tactical fighters.
2. **Opportunity Expansion:** Weakened border governance and security vacuums in adjacent territories.
3. **Ideational Diffusion:** Successful insurgencies serving as operational blueprints for foreign militant networks.

---

## Data & Methodology

### Data Sources
| Dataset | Source | Purpose |
| :--- | :--- | :--- |
| **UCDP Dyadic Dataset** | Uppsala Conflict Data Program | Tracking civil war occurrence and intensity |
| **Global Terrorism Database (GTD)** | START Consortium | Quantifying localized terrorist attacks |
| **Direct Contiguity Dataset** | Correlates of War (COW) | Defining shared geographic borders |

### Research Design & Statistical Modeling
The underlying datasets were merged into a multi-variable **dyad-year panel** where:
* **State A** = Potential source country experiencing civil war.
* **State B** = Neighboring recipient country experiencing potential spillover.
* **Temporal Lag:** The independent variable (Civil War) is lagged by one year ($t-1$) to establish directional causality.

An empirical analysis was conducted by estimating a **regional fixed-effects Poisson regression** to model the skewed, count-based nature of the dependent variable (number of terrorist attacks).

---

## Key Finding
* **The 15% Metric:** Controlling for regional fixed effects, the model estimates that **states experience approximately 15% more terrorist attacks** in the year following an active civil war in a contiguous neighboring country. 
* While the macro-level model cannot isolate specific micro-mechanisms, the results strongly validate the theory that domestic civil conflicts generate significant negative security externalities across international borders.
