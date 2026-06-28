# CW Spillovers - Measurements, Results, and Conclusions
# Dylan Wall
# Rice University - POLI 469 (Fall 2025)
########################################################

setwd("/Users/dylanwall/Desktop/0.RStudio/POLI 469")
rm(list = ls())

# Import Correlates of War - Direct Contiguity (dyad-year-level)
library(readr)
raw_contdird <- read_csv("contdird.csv")

# Import Country-Year Dataset
raw_countryyr <- read_csv("country_year_dataset.csv")

# Check for matching COW ID's
print(raw_contdird$state1no)
print(raw_contdird$state2no)
print(raw_countryyr$cow_code)

# Find Bolivia
print(raw_contdird$state1ab[raw_contdird$state1no == 145])
print(raw_countryyr$statenme[raw_countryyr$cow_code == 145])

# Simplify & merge datasets -----------------------------------------------

colnames(raw_contdird)
colnames(raw_countryyr)

# Simplify continuity dataset, keep only land border or short water border dyads
raw_contdird <- raw_contdird[raw_contdird$conttype <= 2,]
contdird <- raw_contdird[c("state1no", "state2no", "year", "conttype")]

# Create State 1 dataset (civil war country)
state1_countryyr <- raw_countryyr[c("cow_code", "year", 
                                    "any_civilwar", 
                                    "max_civilwar_intensity", 
                                    "num_active_rebelgroups", 
                                    "civil_war_episode_length")]
state1_countryyr <- setNames(state1_countryyr, c("state1no", "year", 
                                                 "state1_civilwar", 
                                                 "state1_civilwar_intensity", 
                                                 "state1_num_rebelgroups", 
                                                 "state1_civilwar_episode_length"))

# Create State 2 dataset (terrorism country)
state2_countryyr <- raw_countryyr[c("cow_code", "year", 
                                    "n_terrorist_attacks", 
                                    "n_killed_terrorist_attacks")]
state2_countryyr <- setNames(state2_countryyr, c("state2no", "year", 
                                                 "state2_n_terrorist_attacks", 
                                                 "state2_n_killed_terrorist_attacks"))

# Merge datasets
mergedA <- merge(contdird, state1_countryyr,
                 by = c("state1no", "year"),
                 all.x = TRUE)
mergedAB <- merge(mergedA, state2_countryyr,
                      by = c("state2no", "year"),
                      all.x = TRUE)

# Lagging the civil war variables by 1 year
library(dplyr)
final_dyadyr <- mergedAB %>%
  group_by(state2no) %>%
  mutate(
    state1_civilwar_lag = lag(state1_civilwar, 1),
    state1_civilwar_intensity_lag = lag(state1_civilwar_intensity, 1),
    state1_num_rebelgroups_lag = lag(state1_num_rebelgroups, 1),
    state1_civilwar_episode_length_lag = lag(state1_civilwar_episode_length, 1)
  )

# Test hypothesis (with lag) ---------------------------------------------------------

# Poisson regression
model_pois_lag <- glm(state2_n_terrorist_attacks ~ state1_civilwar_lag, family = poisson, data = final_dyadyr)
summary(model_pois_lag)

    # Intercept: 
        # When State 1 did NOT have civil war, the expected number of terrorist attacks in State 2 is ~26 attacks.
        # Civil war in State 1 increases the expected number of attacks in State 2 from ~26 to ~44.
    # Effect: 
        # When State 1 experienced civil war in the previous period, State 2 experiences about 67.5% more terrorist                attacks on average, all else equal.

# Negative binomial regression
library(MASS)
model_nb_lag <- glm.nb(state2_n_terrorist_attacks ~ state1_civilwar_lag, data = final_dyadyr)
summary(model_nb_lag)

    # If State 1 had civil war in the previous year, State 2 experiences an estimated 67% more terrorist attacks, on           average.

# Distribution of terrorism attacks
library(ggplot2)
table(final_dyadyr$state2_n_terrorist_attacks)
summary(final_dyadyr$state2_n_terrorist_attacks)
ggplot(data = final_dyadyr, mapping = aes(x = state2_n_terrorist_attacks)) +
  geom_histogram()
sum(is.na(final_dyadyr$state2_n_terrorist_attacks)) # 24071


# Test hypothesis (no lag) ------------------------------------------------

# Poisson regression
model_pois <- glm(state2_n_terrorist_attacks ~ state1_civilwar, family = poisson, data = final_dyadyr)
summary(model_pois)

# Negative binomial regression
library(MASS)
model_nb <- glm.nb(state2_n_terrorist_attacks ~ state1_civilwar, data = final_dyadyr)
summary(model_nb)

# Model table -------------------------------------------------------------

library(modelsummary)

modelsummary(
  models = list("Poisson" = model_pois,
                "Negative Binomial" = model_nb,
                "Poisson (with Lag)" = model_pois_lag,
                "Negative Binomial (with Lag)" = model_nb_lag),
  output = "four_models.docx",
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  gof_map = c("nobs", "aic", "deviance")
)

# Fixed effects for region -------------------------------------------------

library(countrycode)
final_dyadyr$region <- countrycode(final_dyadyr$state1no, origin = 'cown', destination = 'region')

# install.packages('fixest')
library(fixest)
mainmodel <- fepois(state2_n_terrorist_attacks ~ state1_civilwar_lag, data = final_dyadyr,
       fixef = 'region')
summary(mainmodel)


final_dyadyr$region <- countrycode(final_dyadyr$state2no, origin = 'cown', destination = 'region')

mainmodel_conservative <- fepois(state2_n_terrorist_attacks ~ state1_civilwar_lag, data = final_dyadyr,
                    fixef = 'region')



glm(state2_n_terrorist_attacks ~ state1_civilwar_lag + factor(region), family = poisson, data = final_dyadyr) %>% summary

# Model table -------------------------------------------------------------

modelsummary(
  models = list("FE Poisson: Civil War (Lag)" = mainmodel),
  output = "main_models.docx",
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  gof_map = c("nobs", "aic", "deviance")
)


modelsummary(
  models = list("FE Poisson: Civil War (Lag)" = mainmodel_conservative),
  output = "main_model_conservative.docx",
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  gof_map = c("nobs", "aic", "deviance")
)


range(final_dyadyr$year, na.rm = TRUE)
table(final_dyadyr$year)
