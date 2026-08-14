# ============================================================================
# ============================================================================
#                                 PRACTICAL 1
# ============================================================================
# ============================================================================

# Question 1

# You have just imported the hospital data into df. 
# Which base-R function gives a compact, column-by-column report 
# of the structure of df — the class of each variable and a preview of its values?

# c. str(df)

# ----------------------------------------------------------------------------

# Question 2

# Read the scenario and classify the missing-data mechanism using Rubin’s taxonomy 
# (MCAR, MAR, MNAR).

# In a patient-satisfaction survey, the sickest patients are 
# the least likely to return the form, so the missing satisfaction scores 
# tend to be the low ones. Whether a score is missing depends on the (unobserved) score itself.

# Which mechanism best describes the missingness?

# b. Missing Not At Random (MNAR)

# ----------------------------------------------------------------------------

# Question 3

# Consider the following analytics task on the hospital data.

# Predict the numeric length of stay (in days) of a newly admitted patient from their 
# recorded characteristics.
 
# How is this task best classified?

# b.  Supervised learning - regression (the target is a continuous numeric value).

# ----------------------------------------------------------------------------

# Question 4

# Select all statements that correctly describe what the base-R function does. 
# More than one statement is correct.

# b. aggregate(treatment_cost ~ department, data = df, FUN = mean) 
#    returns a group mean of cost per department. 

# d.  table(df$department) produces a frequency count of each department category.

# ----------------------------------------------------------------------------

# Question 5

# The age column contains a few impossible values such as -5, 150 and 999 that 
# were never recoded. A student computes mean(df$age, na.rm = TRUE) directly. 
# What is the effect of leaving those impossible values in?

# d. The computed mean is biased (distorted upward by the large impossible values); 
#    the values should first be recoded to NA with ifelse() before averaging. 

# ----------------------------------------------------------------------------

# Question 6

# download applied_explore.R and metro_general_admissions.csv

# Scenario. Metro General Hospital’s records office has handed you 
# metro_general_admissions.csv, about 200 admission records with the usual 
# real-world problems: missing values, impossible ages, and inconsistent text in 
# the gender and department columns. Using base R only (no dplyr), load the data and 
# answer the following. All answers are whole numbers.

# (a) How many rows (patient records) are in the data?
#   
#   Answer 1 = 200
# 
# (b) How many age values are missing (NA)?
#   
#   Answer 2 = 9
# 
# (c) How many treatment_cost values are missing?
#   
#   Answer 3 = 15
# 
# (d) How many rows have an impossible age (taken as ≤0 or >120, ignoring the missing ages)?
#   
#   Answer 4 = 6
# 
# (e) How many rows have a negative length_of_stay?
#   
#   Answer 5 = 3
# 
# (f) After standardising the text with trimws(tolower(...)), how many distinct departments are there?
#   
#   Answer 6 = 5
# 
# (g) How many admissions are in the Emergency department (using the cleaned department text)?
#   
#   Answer 7 = 50


# ----------------------------------------------------------------------------

# applied_explore.R

# ============================================================================
# STAT312 Practical 01 - Data fundamentals: exploring the hospital data
# ============================================================================
#
# Scenario: metro_general_admissions.csv holds ~200 admission records from
# Metro General Hospital with the usual real-world problems - missing values,
# impossible ages, inconsistent text. In this script you will LOAD the data
# and EXPLORE it with base R (no dplyr).
#
# HOW TO USE THIS SCRIPT
#   1. Save BOTH applied_explore.R and metro_general_admissions.csv in the SAME
#      folder, then set that folder as your working directory.
#   2. Replace every your_code_goes_here() with your own code. Each blank has a
#      plain-English comment describing the intended code.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Counts are whole numbers. Base R only.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

# -- Step 0: load the data (do NOT change) -----------------------------------
df <- read.csv("metro_general_admissions.csv", stringsAsFactors = FALSE)

# -- Step 1: how many rows (patient records) are in the data? -----------------
n_rows <- nrow(df)        # Consult ?nrow.

# -- Step 2: how many AGE values are missing? --------------------------------
n_age_missing <- sum(is.na(df$age)) # Combine is.na() with sum() on the age column.

# -- Step 3: how many TREATMENT_COST values are missing? ---------------------
n_cost_missing <- sum(is.na(df$treatment_cost)) # Same idea as Step 2, applied to the treatment_cost column.

# -- Step 4: how many rows have an IMPOSSIBLE age? ---------------------------
# Treat an age as impossible if it is <= 0 or > 120 (ignore the NA ages).
n_age_invalid <- sum((df$age <= 0 | df$age > 120) & !is.na(df$age)) # Build a logical condition for "impossible age" (see above), combine with !is.na(), then sum().

# -- Step 5: how many rows have a NEGATIVE length of stay? -------------------
n_los_negative <- sum(df$length_of_stay < 0 & !is.na(df$length_of_stay)) # Same pattern as Step 4, applied to a "negative length of stay" condition.

# -- Step 6: how many DISTINCT departments are there AFTER cleaning the text? -
# Standardise case and trim whitespace first, then count distinct values.
dept_clean <- trimws(tolower(df$department))
n_departments <- length(unique(dept_clean)) # Combine unique() with a length-counting function.

# -- Step 7: how many admissions are in the EMERGENCY department (cleaned)? ---
n_emergency <- sum(dept_clean == "emergency")   # Count how many entries of dept_clean equal the target department name.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Number of rows                 :", n_rows),
  paste("Missing age values             :", n_age_missing),
  paste("Missing treatment_cost values  :", n_cost_missing),
  paste("Rows with impossible age       :", n_age_invalid),
  paste("Rows with negative stay        :", n_los_negative),
  paste("Distinct departments (cleaned) :", n_departments),
  paste("Emergency admissions (cleaned) :", n_emergency)
))


# ----------------------------------------------------------------------------

# Question 7

# Scenario. Riverside Clinic keeps its own admissions log, riverside_clinic_admissions.csv 
# (about 200 records, with the same kinds of real-world messiness as any hospital dataset). 
# You summarise the treatment_cost and a cleaned age, then compare mean cost across
# departments — all in base R (no dplyr). Remember that mean, median and sd need 
# na.rm = TRUE to skip the missing values. Round numeric answers to two decimal places.

# (a) Mean treatment_cost (ignoring missing values):
#   
#   22233.51
# 
# (b) Median treatment_cost:
#   
#   19100
# 
# (c) Standard deviation of treatment_cost:
#   
#   11022.71
# 
# (d) Mean cleaned age, after recoding impossible ages (≤0 or >120) to NA:
#   
#   56.22
# 
# (e) Mean treatment_cost in the Surgery department (using the cleaned department text):
#   
#   32660
# 
# (f) Reading off tapply(df$treatment_cost, dept_clean, mean, na.rm = TRUE), which department has the highest mean treatment cost?
#   
#   Multiple choice 1 Question 7
#   = Surgery

# ----------------------------------------------------------------------------

# applied_summaries.R

# ============================================================================
# STAT312 Practical 01 - Data fundamentals: numeric summaries by group
# ============================================================================
#
# Scenario: riverside_clinic_admissions.csv holds Riverside Clinic's own
# admissions log. You will summarise the treatment cost and (cleaned) age,
# then compare mean cost across departments - all in base R (no dplyr).
#
# HOW TO USE THIS SCRIPT
#   1. Save BOTH applied_summaries.R and riverside_clinic_admissions.csv in the
#      SAME folder, then set that folder as your working directory.
#   2. Replace every your_code_goes_here() with your own code (see the comment).
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Round numeric answers to TWO decimal places. Base R only.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

# -- Step 0: load the data (do NOT change) -----------------------------------
df <- read.csv("riverside_clinic_admissions.csv", stringsAsFactors = FALSE)

# -- Step 1: mean treatment cost, ignoring missing values --------------------
mean_cost <- mean(df$treatment_cost, na.rm = TRUE)    # Consult ?mean; remember to handle missing values.

# -- Step 2: median treatment cost, ignoring missing values ------------------
median_cost <- median(df$treatment_cost, na.rm = TRUE)  # Consult ?median; remember to handle missing values.

# -- Step 3: standard deviation of treatment cost, ignoring missing values ---
sd_cost <- sd(df$treatment_cost, na.rm = TRUE)      # Consult ?sd; remember to handle missing values.

# -- Step 4: mean of a CLEANED age -------------------------------------------
# First recode impossible ages (<= 0 or > 120) to NA, then take the mean.
age_clean <- ifelse(df$age <= 0 | df$age > 120, NA, df$age)
mean_age_clean <- mean(age_clean, na.rm = TRUE)  # Take the mean of age_clean, handling the NAs introduced above.

# -- Step 5: mean treatment cost per department (cleaned text) ----------------
# Standardise the department text, then compute a group mean of cost.
dept_clean <- trimws(tolower(df$department))
cost_by_dept <- tapply(df$treatment_cost, dept_clean, mean, na.rm = TRUE)    # Consult ?tapply to compute a grouped mean of cost by cleaned department.
print(round(cost_by_dept, 2))            # look at the per-department means

# -- Step 6: mean treatment cost in the SURGERY department -------------------
mean_cost_surgery <- cost_by_dept["surgery"]  # Index cost_by_dept by the surgery department's name.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Mean treatment cost            :", round(mean_cost, 2)),
  paste("Median treatment cost          :", round(median_cost, 2)),
  paste("SD of treatment cost           :", round(sd_cost, 2)),
  paste("Mean cleaned age               :", round(mean_age_clean, 2)),
  paste("Mean cost in Surgery           :", round(mean_cost_surgery, 2))
))

# -- Step 7 (for the multiple-choice part): which department has the HIGHEST
#    mean treatment cost? Read it off the printed cost_by_dept above.

# ----------------------------------------------------------------------------

# Question 8

# Scenario. Lakeside Medical Centre has exported its own admissions log, 
# lakeside_medical_admissions.csv (about 200 records). You clean the gender text,
# recode impossible numbers to NA, and build a derived high-cost indicator with 
# ifelse() — all in base R (no dplyr). Counts are whole numbers; round the mean to 
# four and the proportion to four decimal places.

# (a) After gender_clean <- trimws(tolower(df$gender)), how many Female admissions are there?
#     
#     = 108
# 
# (b) How many Male admissions are there (cleaned)?
#   
#   92
# 
# (c) After recoding negative length_of_stay to NA, how many length_of_stay 
#     values are NA in total?
#   
#   18
# 
# (d) Mean cleaned length_of_stay (na.rm = TRUE):
#   
#   5.4341
# 
# (e) Using high_cost <- ifelse(df$treatment_cost > 20000, "Yes", "No"), 
#     how many admissions are labelled “Yes”?
#   
#   79
# 
# (f) What proportion of admissions with a recorded cost are high-cost 
#     (out of the non-missing costs)?
#   
#   0.4202
# 
# (g) In part (e), 12 admissions have a missing treatment_cost. What does 
#     ifelse() assign to those rows in high_cost?
# 
#     = The 12 rows with a missing treatment_cost give high_cost = NA, 
#       because ifelse() returns NA when its condition is NA.

# ----------------------------------------------------------------------------

# ============================================================================
# STAT312 Practical 01 - Data fundamentals: cleaning and derived columns
# ============================================================================
#
# Scenario: lakeside_medical_admissions.csv is Lakeside Medical Centre's own
# admissions log. You will clean a text column, recode invalid numbers to NA,
# build a derived indicator column, and tabulate it - all in base R (no dplyr).
#
# HOW TO USE THIS SCRIPT
#   1. Save BOTH applied_derived.R and lakeside_medical_admissions.csv in the
#      SAME folder, then set that folder as your working directory.
#   2. Replace every your_code_goes_here() with your own code (see the comment).
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Counts are whole numbers; round any proportion to FOUR decimal places.
# Base R only.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

# -- Step 0: load the data (do NOT change) -----------------------------------
df <- read.csv("lakeside_medical_admissions.csv", stringsAsFactors = FALSE)

# -- Step 1: clean the GENDER text -------------------------------------------
# Standardise case and trim whitespace so "MALE", " male ", "Male" all agree.
gender_clean <- trimws(tolower(df$gender))   # Consider tolower() and trimws().
print(table(gender_clean))              # should show just "female" and "male"  

# -- Step 2: count Female and Male admissions (cleaned) ----------------------
n_female <- sum(gender_clean == "female")     # Count entries of gender_clean equal to the female category.
n_male   <- sum(gender_clean == "male")       # Same idea, for the male category.

# -- Step 3: recode negative LENGTH OF STAY to NA ----------------------------
# A negative stay is impossible, so replace it with NA using ifelse().
los_clean <- ifelse(df$length_of_stay < 0, NA, df$length_of_stay)      # Consult ?ifelse to conditionally replace negative values with NA.

# -- Step 4: how many length-of-stay values are NA AFTER recoding? -----------
# (the originally-missing ones PLUS the negatives you just recoded)
n_los_na <- sum(is.na(los_clean))       # Combine is.na() with a counting function on los_clean.

# -- Step 5: mean cleaned length of stay (ignoring NA) -----------------------
mean_los_clean <- mean(los_clean, na.rm = TRUE) # Take the mean of los_clean; remember to handle NAs.

# -- Step 6: build a derived HIGH-COST indicator -----------------------------
# Label an admission "Yes" if treatment_cost > 20000, otherwise "No".
high_cost <- ifelse(df$treatment_cost > 20000, "Yes", "No")      # Consult ?ifelse to label rows "Yes"/"No" based on the cost threshold above.
print(table(high_cost, useNA = "ifany"))

# -- Step 7: count and proportion of high-cost admissions --------------------
# Count the "Yes" admissions; the proportion is out of the NON-missing costs.
n_high_cost <- sum(high_cost == "Yes", na.rm = TRUE)    # Count the "Yes" entries of high_cost, handling any NAs.
prop_high_cost <- mean(df$treatment_cost > 20000, na.rm = TRUE) # Build the same threshold condition on treatment_cost, drop the missing costs, then take a mean.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Female admissions (cleaned)    :", n_female),
  paste("Male admissions (cleaned)      :", n_male),
  paste("Length-of-stay NA after recode :", n_los_na),
  paste("Mean cleaned length of stay    :", round(mean_los_clean, 4)),
  paste("High-cost (Yes) admissions     :", n_high_cost),
  paste("Proportion high-cost (non-NA)  :", round(prop_high_cost, 4))
))


# ============================================================================
# ============================================================================
#                                 PRACTICAL 2
# ============================================================================
# ============================================================================

# Question 1

# You have a single dataset and want to estimate how well a regression model 
# will generalise to new data. The holdout method uses one random train/test split. 
# What is the main problem that k-fold cross-validation solves relative to that single split?

# A single split gives a high-variance error estimate that depends heavily on 
# which observations happen to fall in the test set; cross-validation averages 
# over several splits to give a more stable estimate. 

# Correct. The holdout estimate is (approximately) unbiased but has high variance: 
# a different random split can give a noticeably different test error. 
# k-fold cross-validation averages the error across K folds, reducing that variance.

# ----------------------------------------------------------------------------

# Question 2

# In k-fold cross-validation the data are partitioned into K equal folds. 
# Which statement correctly describes how each observation is used, and what the 
# rsample functions analysis() and assessment() return for a fold?

# Each observation is used for testing exactly once and for training K−1 times; 
# analysis(split) returns the training rows of a fold and assessment(split) returns 
# its held-out test rows. 

# Correct. The folds partition the data, so every observation lands in exactly 
# one fold and is therefore tested once; it appears in the training set of 
# the other K−1 folds. In rsample, analysis(split) is the training part of a fold 
# and assessment(split) is the held-out part.

# ----------------------------------------------------------------------------

# Question 3

# Suppose you fit a regression model, then compute its error on the training 
# data it was fitted to, and separately on a held-out test set. Which error is 
# optimistically biased (systematically too small as an estimate of generalisation error), 
# and why?

# The training (in-sample) error is optimistically biased, 
# because the same data were used to fit the model, so it underestimates 
# the error on new data. 

# Correct. The model is fitted to minimise error on the training data, 
# so the training error is an over-optimistic measure of performance: it tends to 
# be lower than the true generalisation error. This is exactly why we hold data out.

# ----------------------------------------------------------------------------

# Question 4

# After running K-fold cross-validation you have one error value per fold, e1,e2,…,eK, 
# and the notes attach a cross-validation standard error to their average. 
# Which statement correctly describes how this standard error is computed and 
# what it is used for?

# The standard deviation of the K fold errors divided by K−−√; 
# it measures how precisely the average CV error is estimated, and is used to compare 
# models and apply the one-standard-error rule

# Correct. With fold errors e1,…,eK, the cross-validation estimate is 
# e¯=1/K * ∑_k e_k and its standard error is sd(e1,…,eK)/√K. It quantifies the uncertainty
# in e¯ and underpins both model comparison and the one-standard-error rule.

# ----------------------------------------------------------------------------

# Question 5

# Leave-one-out cross-validation (LOOCV) is a special case of K-fold cross-validation. 
# Which statement correctly characterises LOOCV and its trade-offs against 5- or 10-fold CV?

# LOOCV is K-fold CV with K=n: it is (nearly) unbiased and deterministic, 
# but trains n models and tends to have higher variance than 5- or 10-fold CV because 
# the training sets are almost identical. 

# Correct. Leave-one-out CV is the extreme K=n: each model trains on n−1 
# observations, so the bias is tiny and the result is deterministic (no random 
# fold assignment). Its drawbacks are cost (n fits) and higher variance, because 
# the n training sets are nearly identical and the errors are highly correlated,
# reducing the benefit of averaging.

# ----------------------------------------------------------------------------

# Question 6

# Scenario. A property dataset records the selling price of 200 houses together 
# with four numeric features: floor area (m2), age (years), distance to the city 
# centre (km) and number of rooms. The script holds out 20% of the data as a test set, 
# fits a linear model lm(price ~ area + age + dist + rooms) on the remaining 80%, and 
# evaluates it on the held-out prices. Round numeric answers to four decimal places; 
# counts are whole numbers.
# 
# (a) Number of observations in the training set:
#   
#   160
# 
# (b) Number of observations in the test set:
#   
#   40
# 
# (c) Estimated slope coefficient of area:
#   
#   8.0541
# 
# (d) Estimated slope coefficient of age:
#   
#   -3.1469
# 
# (e) Test-set RMSE of the model:
#   
#   62.2749
# 
# (f) Test-set R2 (the squared correlation between the actual and predicted prices):
#   
#   0.9567
# 
# (g) Reading your test-set R2 from (f) as a percentage share, which is the 
#     correct interpretation?
#   
#   Multiple choice 1 Question 6
#   = That share of the variation in the held-out house prices is explained by 
#     the model, indicating a strong out-of-sample fit.

# ----------------------------------------------------------------------------

# applied_holdout.R

# ============================================================================
# STAT312 Practical - Resampling: the holdout method (train / test split)
# ============================================================================
#
# Scenario: a property dataset records the selling price of 200 houses together
# with four numeric features: floor area (m2), age (years), distance to the
# city centre (km) and number of rooms. You will hold out 20 percent of the
# data, fit a linear model on the rest, and measure how well it predicts the
# held-out prices.
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or the set.seed(...) lines: the seed keeps
#      your answers identical to the marking key.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Round numeric answers to FOUR decimal places (counts are whole numbers).
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

library(rsample)

# -- Data generation (do NOT change) -----------------------------------------
set.seed(10510)
n <- 200
area  <- rnorm(n, 150, 40)    # floor area (m2)
age   <- rnorm(n, 15, 8)      # age of the house (years)
dist  <- rnorm(n, 10, 4)      # distance to the city centre (km)
rooms <- rnorm(n, 4, 1.2)     # number of rooms
price <- 50 + 8 * area - 3 * age - 6 * dist + 15 * rooms + rnorm(n, 0, 60)
house <- data.frame(price = price, area = area, age = age,
                    dist = dist, rooms = rooms)

# -- Step 1: 80/20 holdout split (keep the seed) -----------------------------
set.seed(10510)
split <- your_code_goes_here()      # Consult ?initial_split to create an 80/20 split of house.
train <- your_code_goes_here()      # Extract the training portion of split.
test  <- your_code_goes_here()      # Extract the testing portion of split.

n_train <- nrow(train)
n_test  <- nrow(test)

# -- Step 2: fit the linear model on the TRAINING data -----------------------
fit <- your_code_goes_here()        # Fit a linear model of price on the four predictors, using only the TRAINING data.

# -- Step 3: read off two slope coefficients ---------------------------------
b_area <- your_code_goes_here()     # Pull the area coefficient out of the coefficients of fit.
b_age  <- your_code_goes_here()     # Same idea, for the age coefficient.

# -- Step 4: predict on the held-out TEST data and score it ------------------
pred <- predict(fit, newdata = test)
rmse <- your_code_goes_here()       # Compute the root mean squared error between test$price and pred.
r2   <- your_code_goes_here()       # Compute the squared correlation between test$price and pred.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Training observations       :", n_train),
  paste("Test observations           :", n_test),
  paste("Slope of area               :", round(b_area, 4)),
  paste("Slope of age                :", round(b_age,  4)),
  paste("Test RMSE                   :", round(rmse,   4)),
  paste("Test R-squared              :", round(r2,     4))
))

# ----------------------------------------------------------------------------

# Question 7

# (a) CV MSE of the simple model (yield ~ rain):
#   
#   3.5885
# 
# (b) CV standard error of the simple model:
#   
#   0.3875
# 
# (c) CV MSE of the richer model (yield ~ rain + fert + temp):
#   
#   1.3563
# 
# (d) CV standard error of the richer model:
#   
#   0.1776
# 
# (e) Based on these cross-validation results, which model should you prefer?
# 
#     = The richer model (rainfall, fertiliser and temperature): 
#       its cross-validation MSE is clearly lower (by more than one standard error), 
#       so it generalises better.

# ----------------------------------------------------------------------------

# applied_kfold.R

# ============================================================================
# STAT312 Practical - Resampling: k-fold cross-validation to compare two models
# ============================================================================
#
# Scenario: a crop trial records the yield (tonnes/ha) of 150 plots together
# with seasonal rainfall (mm), fertiliser applied (kg/ha), mean temperature
# (deg C) and soil pH. You will use 5-fold cross-validation to compare a SIMPLE
# model (yield ~ rain) with a RICHER model (yield ~ rain + fert + temp) and
# decide which generalises better.
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or the set.seed(...) lines: the seed keeps
#      your answers identical to the marking key.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Round numeric answers to FOUR decimal places.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

library(rsample)

# -- Data generation (do NOT change) -----------------------------------------
set.seed(13649)
n <- 150
rain <- rnorm(n, 600, 120)   # seasonal rainfall (mm)
fert <- rnorm(n, 100, 25)    # fertiliser applied (kg/ha)
temp <- rnorm(n, 22, 3)      # mean temperature (deg C)
ph   <- rnorm(n, 6.5, 0.6)   # soil pH
yield <- 2 + 0.010 * rain + 0.05 * fert + 0.3 * temp + rnorm(n, 0, 1.2)
crop <- data.frame(yield = yield, rain = rain, fert = fert,
                   temp = temp, ph = ph)

# -- A helper that scores ONE fold for a given model formula -----------------
# The helper fits the model on one part of the fold and scores it on the
# other; consult ?analysis and ?assessment for what each part is.
compute_fold_mse <- function(split, formula) {
  tr <- analysis(split)
  te <- assessment(split)
  m  <- lm(formula, data = tr)
  p  <- predict(m, newdata = te)
  mean((te$yield - p)^2)       # Compute the mean squared error between te$yield and p.
}

# -- Step 1: build the 5-fold splits (keep the seed) -------------------------
set.seed(13649)
cv_folds <- vfold_cv(crop, v = 5)    # Consult ?vfold_cv to build 5 folds of crop.

# -- Step 2: per-fold MSE for each model -------------------------------------
mse_simple <- sapply(cv_folds$splits, compute_fold_mse, formula = yield ~ rain)
mse_rich   <- sapply(cv_folds$splits, compute_fold_mse,
                     formula = yield ~ rain + fert + temp)

# -- Step 3: CV error (mean of fold MSEs) and its standard error -------------
cv_simple <- mean(mse_simple)   # Compute the CV error estimate for the simple model from mse_simple.
se_simple <- sd(mse_simple) / sqrt(5)   # Compute the standard error of the CV error for the simple model.
cv_rich   <- mean(mse_rich)      # Compute the CV error estimate for the richer model from mse_rich.
se_rich    <- sd(mse_rich) / sqrt(5)   # Compute the standard error of the CV error for the richer model.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("CV MSE  simple model        :", round(cv_simple, 4)),
  paste("CV SE   simple model        :", round(se_simple, 4)),
  paste("CV MSE  richer model        :", round(cv_rich,   4)),
  paste("CV SE   richer model        :", round(se_rich,   4))
))



# ----------------------------------------------------------------------------

# Question 8

# (a) Estimated slope coefficient of experience:
#   
#   12.2381
# 
# (b) The largest hat value maxihii:
#   
#   0.0953
# 
# (c) The in-sample MSE:
#   
#   406.2416
# 
# (d) The analytical LOOCV MSE:
#   
#   436.0635
# 
# (e) Compare the in-sample MSE with the LOOCV MSE. Which statement is correct?
#   
#    = The LOOCV MSE is larger than the in-sample MSE: the 
#       in-sample error is optimistic because each prediction reuses 
#       the point it is fitted to, whereas LOOCV leaves each point out, 
#       giving a more honest estimate of generalisation error.

# ----------------------------------------------------------------------------

# applied_loocv.R

# ============================================================================
# STAT312 Practical - Resampling: analytical LOOCV for a linear model
# ============================================================================
#
# Scenario: a payroll dataset records the monthly salary (currency units) of
# 120 employees together with years of experience, years of education and hours
# worked per week. For a linear model, leave-one-out cross-validation has a
# closed form that needs only ONE model fit, using the hat values:
#
#     LOOCV = mean( ( residual_i / (1 - h_ii) )^2 )
#
# You will compute this analytical LOOCV and compare it with the in-sample MSE.
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or the set.seed(...) line: the seed keeps
#      your answers identical to the marking key.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Round numeric answers to FOUR decimal places.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

# -- Data generation (do NOT change) -----------------------------------------
set.seed(39094)
n <- 120
exper <- rnorm(n, 10, 5)     # years of work experience
educ  <- rnorm(n, 16, 2)     # years of education
hours <- rnorm(n, 40, 6)     # hours worked per week
salary <- 200 + 12 * exper + 9 * educ + 1.5 * hours + rnorm(n, 0, 20)
emp <- data.frame(salary = salary, exper = exper, educ = educ, hours = hours)

# -- Step 1: fit the linear model on ALL the data ----------------------------
fit <- lm(salary ~ exper + educ + hours, data = emp)      # Fit a linear model of salary on the three predictors, using emp.

# -- Step 2: pull out the slope of experience --------------------------------
b_exper <- coef(fit)["exper"]     # Pull the experience coefficient out of the coefficients of fit.

# -- Step 3: residuals and hat values ----------------------------------------
r <- residuals(fit)                  # the residuals
h <- hatvalues(fit)           # Consult ?hatvalues to get the leverage values of fit.
max_h <- max(h)                      # the largest hat value (leverage)

# -- Step 4: in-sample MSE and analytical LOOCV ------------------------------
insample_mse <- mean(r^2) # The in-sample MSE is the mean of squared residuals.
loocv_mse    <- mean((r / (1 - h))^2)  # Apply the closed-form LOOCV formula given above, using r and h.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Slope of experience         :", round(b_exper,      4)),
  paste("Largest hat value           :", round(max_h,        4)),
  paste("In-sample MSE               :", round(insample_mse, 4)),
  paste("Analytical LOOCV MSE        :", round(loocv_mse,    4))
))



# ----------------------------------------------------------------------------

# ============================================================================
# ============================================================================
#                                 PRACTICAL 3
# ============================================================================
# ============================================================================

# Question 1

# At a single test point x0, the expected squared prediction error of a fitted model decomposes as
# 
# E[(Y−f^(x0))2]=Bias2[f^(x0)]+Var[f^(x0)]+σ2.
# 
# For a particular model and test point these three components are
# 
# Bias2[f^(x0)]=2.1,  Var[f^(x0)]=0.9,  σ2=1.1.
# 
# Which statement is correct?

# c. The expected squared prediction error at x0 is 4.1, 
# and no matter how the model is changed it cannot be driven below 1.1.

# Correct. Bias2+Var+σ2=2.1+0.9+1.1=4.1. The first two terms are properties of 
# the estimator and can be traded off against each other; σ2=1.1 is inherent noise 
# in Y given X and is a hard floor on the expected error.

# ----------------------------------------------------------------------------

# Question 2

# A hospital models the number of theatre minutes each scheduled operation will require. 
# A prediction that is out by ten minutes is absorbed easily, but one that is out by 
# two hours disrupts the rest of the day’s list and forces cancellations. 
# The analyst wants the reported metric to reflect that a few very large errors are 
# far worse than many small ones.

# Of the assessment metrics covered in this module, which one is most appropriate here, 
# and which explanation of that choice is correct?

# RMSE. Squaring before averaging weights large errors disproportionately, so 
# the metric is driven up sharply by the errors that matter most here, and it is 
# reported in the same units as the response. 

# Correct. Squaring makes the metric grow with the square of the error, so the 
# occasional two-hour miss contributes far more than a series of ten-minute misses — 
# the asymmetry the theatre manager cares about.

# ----------------------------------------------------------------------------

# Question 3

# A multiple linear regression of annual insurance premium (R) on the numeric predictor
# vehicle_age and the categorical predictor cover is fitted with lm(). Before fitting, 
# cover was converted to a factor. Its four categories are Standard, Premier, Basic and 
# Comprehensive. They are listed here in a random order, which is not the order R uses. 
# The estimated coefficients are:

# Term 	              Estimate
# (Intercept) 	      2322
# vehicle_age 	      141
# coverComprehensive 	-297
# coverPremier 	      -438
# coverStandard 	    -933
# 
# Holding vehicle_age fixed, what is the expected difference in annual insurance 
# premium (R) for a unit in category Standard compared with a unit in category Premier?

# c. -495

# Correct. Each dummy coefficient is a contrast against the reference level Basic, 
# so the expected difference between two non-reference levels is the difference of 
# their dummy coefficients: −933−(−438)=−495.

# ----------------------------------------------------------------------------

# Question 4

# Consider a multiple linear regression fitted by ordinary least squares. 
# Select all of the following statements that are correct.

# d. A coefficient in a multiple regression is a partial effect: the expected 
# change in the response for a one-unit increase in that predictor, with the other 
# predictors in the model held fixed. 

# e. When R^2 is computed on a held-out test set as the squared correlation between the actual 
# and the predicted values, it can be lower than the same model’s in-sample R^2.

# ----------------------------------------------------------------------------

# Question 5

# A provincial licensing department holds five years of records for every vehicle 
# registered in the province: registration date, vehicle class, engine capacity, 
# licensing office, fee paid and whether the licence was renewed late.

# An analyst sweeps every candidate fee structure through the fitted model and reports
# the schedule that reaches the revenue target with the smallest increase for the 
# lowest vehicle class.
# 
# Which type of analytics does this activity represent, and why?

# Prescriptive analytics — it goes beyond estimating an outcome 
# and recommends the course of action that best meets a stated objective. 

# Prescriptive analytics builds on a predictive model by searching over the 
# available actions and recommending the one that best meets an objective, 
# usually subject to constraints. It answers what should be done.

# ----------------------------------------------------------------------------

# Question 6

# (a) The estimated coefficient on irradiance:
#   
#   23.6214
# 
# (b) The estimated coefficient on the Tracking array indicator:
#   
#   20.5053
# 
# (c) Holding irradiance, ambient temperature and soiling fixed, the expected difference 
#     in daily output between a Tracking array and a Seasonal array:
#   
#   13.0826
# 
# (d) The model’s predicted output for the single new day described in the script 
#     (a Tracking-array section):
#   
#   175.6459
# 
# (e) The RMSE on the held-out test set:
#   
#   3.4968
# 
# (f) The residual standard error of the fitted model:
#   
#  3.9449
# 
# (g) In this fitted model, what does the intercept refer to?
#   
#   Multiple choice 1 Question 6
#   It is the expected daily output for a Fixed array when irradiance, 
#   ambient temperature and soiling are all zero, because Fixed is alphabetically 
#   first and so becomes the reference category absorbed into the intercept.

# ----------------------------------------------------------------------------

# applied_multiple.R

# ============================================================================
# STAT312 Practical - Multiple regression with a categorical predictor
# ============================================================================
#
# Scenario: 220 days of operating records from a solar farm. For each day the
# record holds the daily energy output (MWh), the solar irradiance received
# (kWh/m2/day), the mean ambient temperature (deg C), the percentage of output
# lost to dust soiling on the panels, and the type of mounting array used on
# that section of the farm ("Fixed", "Seasonal" or "Tracking").
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or the set.seed(...) lines: the seed keeps
#      your answers identical to the marking key.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Round numeric answers to FOUR decimal places.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

library(rsample)

# -- Data generation (do NOT change) -----------------------------------------
set.seed(86614)
n <- 220
irradiance <- rnorm(n, 5.2, 1.1)    # kWh/m2/day
amb_temp   <- rnorm(n, 21, 4.5)     # deg C
soiling    <- runif(n, 0, 8)        # % of output lost to dust
array_type <- sample(c("Fixed", "Seasonal", "Tracking"), n,
                     replace = TRUE, prob = c(0.45, 0.25, 0.30))
output <- 40 + 23.5 * irradiance - 0.45 * amb_temp - 1.2 * soiling +
  ifelse(array_type == "Seasonal", 7.4,
         ifelse(array_type == "Tracking", 20.2, 0)) +
  rnorm(n, 0, 4)
solar <- data.frame(
  output      = output,
  irradiance  = irradiance,
  amb_temp    = amb_temp,
  soiling     = soiling,
  array_type  = factor(array_type)
)

# -- Step 1: a 75/25 training/test partition (keep the seed) -----------------
set.seed(86614)
sp <- initial_split(solar, prop = 0.75)
tr <- training(sp)
te <- testing(sp)

# -- Step 2: fit the model on the TRAINING data ------------------------------
# Regress daily output on irradiance, ambient temperature, soiling and the
# array type. Note that array_type is a factor.
fit <- lm(output ~ irradiance + amb_temp + soiling + array_type, data = tr)

# -- Step 3: read the fitted coefficients off the model ----------------------
b_irr   <- coef(fit)["irradiance"]   # The estimated coefficient on irradiance.
b_track <- coef(fit)["array_typeTracking"]  # The estimated coefficient on the Tracking array indicator.

# -- Step 4: compare two array types --------------------------------------
# The expected difference in daily output between a Tracking-array section and
# a Seasonal-array section, holding irradiance, ambient temperature and soiling
# fixed. Before you combine any coefficients, work out from the fitted model
# what each array-type coefficient is measured against.
diff_ts <- coef(fit)["array_typeTracking"] - coef(fit)["array_typeSeasonal"]

# -- Step 5: predict for one new day at a Tracking-array section -------------
# The day has irradiance 5.5 kWh/m2/day, ambient temperature 18 deg C
# and soiling 5 per cent. Its details are already assembled in new_site.
new_site <- data.frame(
  irradiance = 5.5,
  amb_temp   = 18,
  soiling    = 5,
  array_type = factor("Tracking", levels = levels(solar$array_type))
)
pred_new <- predict(fit, newdata = new_site)   # Use new_site to obtain the model prediction for this day.

# -- Step 6: two measures of spread ------------------------------------------
pred_te  <- predict(fit, newdata = te)   # Model predictions for the test observations.
rmse_te  <- sqrt(mean((te$output - pred_te)^2))  # Root mean squared error on the test set.
sigma_tr <- summary(fit)$sigma     # The residual standard error of the fitted model. Consult ?summary.lm.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Coefficient on irradiance        :", round(b_irr,    4)),
  paste("Coefficient on Tracking          :", round(b_track,  4)),
  paste("Tracking minus Seasonal          :", round(diff_ts,  4)),
  paste("Predicted output, new day        :", round(pred_new, 4)),
  paste("Test RMSE                        :", round(rmse_te,  4)),
  paste("Residual standard error          :", round(sigma_tr, 4))
))

# ----------------------------------------------------------------------------

# Question 7

# (a) How many of the test rounds were disrupted?
#   
#   6
# 
# (b) RMSE over all test rounds:
#   
#   1.5073
# 
# (c) MAE over all test rounds:
#   
#   1.0464
# 
# (d) MAPE (%) over all test rounds:
#   
#   17.4396
# 
# (e) RMSE over the undisrupted test rounds only:
#   
#   0.9532
# 
# (f) MAE over the undisrupted test rounds only:
#   
#   0.8271
# 
# (g) Compare the RMSE and the MAE with and without the disrupted rounds. When the 
# disrupted rounds are removed, which of the two falls by the smaller percentage, and why?

# The MAE, because each error enters it in proportion to its own magnitude, 
# whereas the RMSE squares errors before averaging, so a handful of very large errors 
# dominates the RMSE.

# ----------------------------------------------------------------------------

# applied_metrics.R

# ============================================================================
# STAT312 Practical - Assessment metrics under outlier contamination
# ============================================================================
#
# Scenario: 260 courier delivery rounds. For each round the record holds the
# time taken (hours), the distance travelled (km), the number of parcels
# carried, whether the round was urban (1) or rural (0), and a flag marking the
# rounds affected by a period of port and road disruption (disrupted = 1).
# The disrupted rounds are genuine and stay in the data.
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or the set.seed(...) lines: the seed keeps
#      your answers identical to the marking key.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Round numeric answers to FOUR decimal places. Report MAPE as a PERCENTAGE.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

library(rsample)

# -- Data generation (do NOT change) -----------------------------------------
set.seed(37963)
n <- 260
distance  <- runif(n, 5, 120)              # km travelled
parcels   <- rpois(n, 6) + 1               # parcels carried
urban     <- rbinom(n, 1, 0.55)            # 1 = urban round
disrupted <- rbinom(n, 1, 0.12)        # 1 = affected by the disruption
hours <- 1.4 + 0.055 * distance + 0.18 * parcels + 0.6 * urban +
  rnorm(n, 0, 0.35) + disrupted * rexp(n, rate = 1 / 6)
courier <- data.frame(
  hours     = hours,
  distance  = distance,
  parcels   = parcels,
  urban     = urban,
  disrupted = disrupted
)

# -- Step 1: a 70/30 training/test partition (keep the seed) -----------------
set.seed(37963)
sp <- initial_split(courier, prop = 0.7)
tr <- training(sp)
te <- testing(sp)

# -- Step 2: fit the model on the TRAINING data ------------------------------
# Regress delivery time on distance, parcels and the urban indicator. The
# disruption flag is NOT a predictor: it only marks which rounds were affected.
fit <- lm(hours ~ distance + parcels + urban, data = tr)

# -- Step 3: prediction errors on the HELD-OUT data --------------------------
pred <- predict(fit, newdata = te)  # Model predictions for the test observations.
err  <- te$hours - pred  # Prediction error of each test observation.

# -- Step 4: the three error metrics over ALL test rounds --------------------
n_disr   <- sum(te$disrupted == 1)    # How many test rounds were disrupted.
rmse_all <- sqrt(mean(err^2))   # Root mean squared error.
mae_all  <- mean(abs(err))     # Mean absolute error.
mape_all <- 100 * mean(abs(err / te$hours))    # Mean absolute percentage error, as a percentage.

# -- Step 5: the same metrics over the UNDISRUPTED test rounds only ----------
# Recompute RMSE and MAE using only those test rounds that were not disrupted.
rmse_cln <- sqrt(mean(err[te$disrupted == 0]^2))
mae_cln  <- mean(abs(err[te$disrupted == 0]))

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Disrupted rounds in test set     :", n_disr),
  paste("RMSE, all test rounds            :", round(rmse_all, 4)),
  paste("MAE,  all test rounds            :", round(mae_all,  4)),
  paste("MAPE, all test rounds (%)        :", round(mape_all, 4)),
  paste("RMSE, undisrupted rounds only    :", round(rmse_cln, 4)),
  paste("MAE,  undisrupted rounds only    :", round(mae_cln,  4))
))

# ----------------------------------------------------------------------------

# Question 8

# (a) In-sample R2 of the small model:
#   
#   0.5158
# 
# (b) In-sample R2 of the large model:
#   
#   0.5371
# 
# (c) Adjusted R2 of the small model:
#   
#   0.5004
# 
# (d) Adjusted R2 of the large model:
#   
#   0.4838
# 
# (e) Test-set RMSE of the small model:
#   
#   1.0373
# 
# (f) Test-set RMSE of the large model:
#   
#   1.0919
# 
# (g) Taking the three comparisons together, what do these results show?
#   
#   Multiple choice 1 Question 8
#   The rise in R2 is guaranteed and so carries no evidence; the fall in adjusted 
#   R2 and the rise in held-out RMSE both show the added columns bought only fitted noise. 

# ----------------------------------------------------------------------------

# applied_adjr2.R

# ============================================================================
# STAT312 Practical - R-squared, adjusted R-squared, and useless predictors
# ============================================================================
#
# Scenario: 140 vineyard blocks. For each block the record holds the sugar
# content of the harvested grapes (degrees Brix), the sunlight hours over the
# season, the supplementary irrigation applied (mm), and the age of the vines
# (years). The record also carries 7 further columns, aux1 ... aux7,
# logged automatically by the estate management system.
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or the set.seed(...) lines: the seed keeps
#      your answers identical to the marking key.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# Round numeric answers to FOUR decimal places.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

library(rsample)

# -- Data generation (do NOT change) -----------------------------------------
set.seed(50308)
n <- 140
sunlight   <- rnorm(n, 1850, 160)     # sunlight hours over the season
irrigation <- rnorm(n, 320, 70)       # supplementary irrigation (mm)
vine_age   <- runif(n, 3, 28)         # age of the vines (years)
brix <- 8 + 0.0072 * sunlight + 0.0035 * irrigation + 0.06 * vine_age +
  rnorm(n, 0, 1.1)
vine <- data.frame(brix = brix, sunlight = sunlight,
                   irrigation = irrigation, vine_age = vine_age)
aux_block <- as.data.frame(matrix(rnorm(n * 7), nrow = n))
names(aux_block) <- paste0("aux", seq_len(7))
vine <- cbind(vine, aux_block)

# -- Step 1: a 70/30 training/test partition (keep the seed) -----------------
set.seed(50308)
sp <- initial_split(vine, prop = 0.7)
tr <- training(sp)
te <- testing(sp)

# -- Step 2: the two competing model specifications --------------------------
# f_small uses only the three agronomic predictors.
# f_large uses those three PLUS every aux column.
f_small <- brix ~ sunlight + irrigation + vine_age
f_large <- as.formula(paste("brix ~ sunlight + irrigation + vine_age +",
                            paste(names(aux_block), collapse = " + ")))

# -- Step 3: fit both models on the TRAINING data ----------------------------
m_small <- lm(f_small, data = tr)
m_large <- lm(f_large, data = tr)

# -- Step 4: in-sample fit statistics ----------------------------------------
# Both quantities are reported by summary() of a fitted lm object.
r2_small  <- summary(m_small)$r.squared   # In-sample R-squared of the small model.
r2_large  <- summary(m_large)$r.squared   # In-sample R-squared of the large model.
adj_small <- summary(m_small)$adj.r.squared   # Adjusted R-squared of the small model.
adj_large <- summary(m_large)$adj.r.squared   # Adjusted R-squared of the large model.

# -- Step 5: honest performance on the HELD-OUT data -------------------------
# Root mean squared error of each model on the test blocks.
pred_small <- predict(m_small, newdata = te)
pred_large <- predict(m_large, newdata = te)

rmse_small <- sqrt(mean((te$brix - pred_small)^2))
rmse_large <- sqrt(mean((te$brix - pred_large)^2))

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("R-squared,          small model :", round(r2_small,   4)),
  paste("R-squared,          large model :", round(r2_large,   4)),
  paste("Adjusted R-squared, small model :", round(adj_small,  4)),
  paste("Adjusted R-squared, large model :", round(adj_large,  4)),
  paste("Test RMSE,          small model :", round(rmse_small, 4)),
  paste("Test RMSE,          large model :", round(rmse_large, 4))
))

# ----------------------------------------------------------------------------

# ============================================================================
# ============================================================================
#                          EXTRA PRACTICAL 1-3
# ============================================================================
# ============================================================================

# Question 1

# Chapter 1 sets up the learning problem using two quantities: the expected risk
# 
# R(f)=∬L(y,f(x))p(x,y)dxdy
# 
# and the empirical risk
# 
# R^n(f)=1n∑ni=1L(yi,f(xi)).
# 
# Which statement correctly describes the relationship between them, and why we 
# work with the second one?

# R^n(f) is a sample estimate of R(f) built from the n observations we happen to have. 
# We minimise it as a stand-in for the expected risk, which would require knowing p(x,y) 
# for every possible (x,y) pair. 

# Correct. The expected risk R(f)=∬L(y,f(x))p(x,y)dxdy is an average over the 
# population, so computing it would require the true joint density p(x,y).
# We never have that, so we substitute the training sample and minimise
# R^n(f)=1n∑iL(yi,f(xi)) instead. Everything in Chapter 2 exists to manage the gap 
# this substitution opens up.

# ----------------------------------------------------------------------------

# Question 2

# A researcher wants to estimate the average monthly data spend of students at a 
# university with 18 000 registered students. She sets up a stall outside the 
# campus computer laboratory for three days and interviews whoever agrees to stop 
# and answer.
# 
# Which statement best describes this sampling design and its consequence?

# This is convenience sampling, a non-probability method. Because each unit’s chance 
# of being included is unknown and unequal, the sample may systematically over-represent 
# students who spend a lot of time in the computer laboratory, and the estimate of average 
# monthly data spend can be biased in a direction that a larger sample size will not fix. 

# Correct. Approaching whoever is available is convenience sampling — a non-probability
# method. Chapter 1’s point is that non-probability designs make inclusion probabilities 
# unknown, so the sample need not represent the population: here it tilts towards students 
# who spend a lot of time in the computer laboratory. Crucially, this is a bias, not noise,
# so a bigger sample simply estimates the wrong number more precisely.

# ----------------------------------------------------------------------------

# Question 3

# A survey records each respondent’s years of schooling, district and monthly income. 
# Respondents in rural districts are much less likely to report an income, but district
# is recorded for everyone. Whether income is missing does not depend on the income 
# itself once district is known.
# 
# An analyst plans to drop every row containing any missing value (listwise deletion, 
# i.e. complete-case analysis) and work with what remains. Which statement is correct?

# The mechanism is MAR. Deleting every incomplete row can bias the analysis, 
# because the rows that survive are not a representative subset — they systematically 
# under-represent part of the population. Listwise deletion is 

# Correct. Missingness depends on an observed variable but not on the unobserved 
# value itself — that is the definition of MAR. The warning in Chapter 1 is that 
# listwise deletion (dropping every row with any NA) is unbiased only under MCAR. 
# Under MAR the surviving rows are a systematically skewed subset, so any summary 
# computed on them can be biased.

# ----------------------------------------------------------------------------

# Question 4

# A dataset has 220 observations. You must choose a training proportion α for a 
# single holdout split, and you are weighing α=0.60 against α=0.85:

# α 	  training observations 	test observations
# 0.60 	132 	                  88
# 0.85 	187 	                  33

# Which statement correctly describes the trade-off?

#  The trade-off is between the quality of the model and the precision of the 
# estimate: α=0.85 favours the model (187 training observations) at the cost of a 
# noisy estimate from 33 test observations, while α=0.60 does the reverse.

# Correct. This is exactly the trade-off in Chapter 2’s “Optimal Split Proportions”. 
# Large α: more training data, so the fitted model is closer to what you would get from 
# the full dataset — but the test set shrinks to 33 observations, and an error estimated 
# from 33 observations has high variance. Small α: a 88-observation test set gives a tighter 
# estimate, but of a model fitted to only 132 observations, which may be worse than the
# model you will actually deploy.

# ----------------------------------------------------------------------------

# Question 5

# Consider how cross-validation is used in practice. 
# Select all of the following statements that are correct.

# b. In K-fold cross-validation every observation is used for testing 
#     exactly once and for training exactly K−1 times. 

# c. Stratification is usually most worthwhile when the target is imbalanced 
#     or strongly skewed, and matters less when it is roughly symmetric and the 
#     folds are large. 

# d. A small K (say K=5) tends to give a higher-bias but lower-variance estimate 
#     than a large K, because each model is trained on a smaller fraction of the data 
#     but the fold estimates are less correlated. 

# ----------------------------------------------------------------------------

# Question 6

# A simple linear regression of monthly maintenance spend (R) on the single 
# predictor machine_hours is fitted with lm(). Part of coef(summary(fit)) is shown:

# Term 	          Estimate 	Std.Error 	t value
# (Intercept) 	  403.1 	  44.789 	    9.00
# machine_hours 	15.05 	  1.684 	    8.94
# 
# Which statement is a correct reading of this output?

# Each extra unit of machine_hours is associated with an estimated change of 15.05 
# in monthly maintenance spend (R), on average. The t value of 8.94 is the estimate 
# divided by its standard error, and being far from 0 it indicates the slope is 
# statistically distinguishable from zero. 

# Correct. In a simple linear regression β^1=15.05 is the estimated average change 
# in the response per one-unit increase in the predictor — an association, not a causal 
# effect. The t value column is just Estimate / Std. Error =15.05/1.684=8.94: it 
# re-expresses the estimate in units of its own standard error, so large values mean the 
# estimate is large relative to its uncertainty.

# ----------------------------------------------------------------------------

# Question 7

# Scenario. A citrus packhouse logs, for each fruit sampled off the line, 
# its mass (grams), its sugar content (degrees Brix) and its firmness (kgf). 
# The Brix meter is slower to read on small fruit and operators sometimes skip it; 
# the firmness probe occasionally fails outright. Your job is to assess the quality 
# of this data before anyone models it.
# 
# The IQR outlier rule (Chapter 1). A value x is flagged as an outlier when
# 
# x<Q1−1.5×IQR or x>Q3+1.5×IQR,
# 
# where Q1 and Q3 are the first and third quartiles and IQR=Q3−Q1.
# 
# Round numeric answers to four decimal places.

# (a) Completeness. What proportion of the sugar_brix readings are missing?
#   
#   0.2867
# 
# (b) How many fruit_mass values does the IQR rule flag as outliers?
#   
#   7
# 
# (c) The mean fruit_mass computed over all rows:
#   
#   183.2228
# 
# (d) How many rows survive listwise deletion (that is, are complete across all three 
#     columns)?
#   
#   195
# 
# (e) The mean fruit_mass computed over only the surviving rows:
#   
#   189.7283
# 
# (f) Compare your answers to (c) and (e). What does the difference tell you?
#   
#   Multiple choice 1 Question 7
#   The Brix reading is missing more often on small fruit, so complete-case deletion 
#   removes small fruit preferentially and the surviving rows have a higher mean mass. 
#   The missingness depends on an observed variable, so this is MAR and listwise deletion 
#   is biased.

# ----------------------------------------------------------------------------

# applied_quality.R

# ============================================================================
# STAT312 Practical 3.5 (take-home) - Data quality: completeness, outliers,
#                                     and the cost of deleting incomplete rows
# ============================================================================
#
# Scenario: a citrus packhouse logs, for each fruit sampled off the line, its
# mass (grams), its sugar content (degrees Brix) and its firmness (kgf). The
# Brix meter is slower to read on small fruit and operators sometimes skip it;
# the firmness probe occasionally fails outright.
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or the set.seed(...) line.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# This is a FORMATIVE take-home: the comments point you at the functions you
# need, and ?help is always worth reading. Round answers to FOUR decimals.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

# -- Data generation (do NOT change) -----------------------------------------
set.seed(58170)
n <- 300
fruit_mass <- rnorm(n, 180, 26)
big_idx <- sample(n, 7)
fruit_mass[big_idx] <- fruit_mass[big_idx] + runif(7, 95, 150)
sugar_brix <- 9 + 0.020 * fruit_mass + rnorm(n, 0, 0.7)
firmness   <- rnorm(n, 65, 9)
p_miss <- plogis((180 - fruit_mass) / 22) * 0.55
sugar_brix[runif(n) < p_miss] <- NA
firmness[runif(n) < 0.06] <- NA
citrus <- data.frame(fruit_mass = fruit_mass,
                     sugar_brix = sugar_brix,
                     firmness   = firmness)

# -- Orientation: have a look before you compute anything --------------------
# Nothing to fill in here. str() and summary() are always the first two things
# to run on a new data frame; summary() reports an NA count per column.
str(citrus)
summary(citrus)

# -- Step 1: COMPLETENESS ----------------------------------------------------
# Chapter 1 assesses completeness as the PROPORTION of missing entries in a
# column. Consult ?is.na and ?mean -- note that the mean of a logical vector is
# the proportion of TRUEs, which is the whole trick here.
prop_missing <- mean(is.na(citrus$sugar_brix))   # Proportion of sugar_brix entries that are missing.

# -- Step 2: OUTLIERS by the IQR rule ----------------------------------------
# The question text gives the rule. Consult ?quantile (you will want the
# type = 7 default, which is what quantile() uses unless told otherwise).
Q1   <- quantile(citrus$fruit_mass, 0.25)   # First quartile of fruit_mass.
Q3   <- quantile(citrus$fruit_mass, 0.75)   # Third quartile of fruit_mass.
IQRv <- Q3 - Q1   # The interquartile range from Q1 and Q3.

# Now flag the fruit that fall outside the fences described in the question,
# and count them. Consult ?sum -- summing a logical vector counts its TRUEs.
n_outliers <- sum(citrus$fruit_mass < Q1 - 1.5 * IQRv | citrus$fruit_mass > Q3 + 1.5 * IQRv)

# -- Step 3: LISTWISE DELETION ------------------------------------------------
# First, the mean fruit mass using every row in the data.
mean_all <- mean(citrus$fruit_mass)

# Now keep only the rows that are complete across ALL THREE columns.
# Consult ?complete.cases -- it returns one logical value per row.
keep <- complete.cases(citrus)

n_complete    <- sum(keep)   # How many rows survive.
mean_complete <- mean(citrus$fruit_mass[keep])   # Mean fruit mass over the surviving rows only.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Proportion of brix readings missing :", round(prop_missing,  4)),
  paste("IQR outliers in fruit_mass          :", n_outliers),
  paste("Mean fruit mass, all rows           :", round(mean_all,      4)),
  paste("Rows surviving listwise deletion    :", n_complete),
  paste("Mean fruit mass, complete rows only :", round(mean_complete, 4))
))

# -- Something to think about (not marked) -----------------------------------
# Compare the last two means. Which fruit did deletion throw away, and why?



# ----------------------------------------------------------------------------

# Question 8

# Scenario. A quantity surveyor has records of 180 completed building projects: 
# the floor area of each (m2) and its final cost (R thousand). You will fit a simple 
# linear regression of cost on floor area, read its coefficient table, and then check 
# whether the model’s assumptions actually hold.
# 
# The script asks you to run plot(fit), which draws Chapter 3’s four diagnostic panels. 
# Look at them — the first (residuals against fitted values) is the one this question 
# is about. Then you will summarise what it shows with a single number: the correlation 
# between the absolute residuals and the fitted values. If the residual spread were 
# constant, that correlation would be near zero.
# 
# Round numeric answers to four decimal places.

# (a) The estimated intercept:
#   
#   88.1737
# 
# (b) The estimated slope on floor_area:
#   
#   7.8531
# 
# (c) The standard error of that slope:
#   
#   0.0656
# 
# (d) The t value for that slope:
#   
#   119.7962
# 
# (e) The correlation between the absolute residuals and the fitted values:
#   
#   0.4979
# 
# (f) The maximum leverage (largest hat value) in the data:
#   
#   0.0245
# 
# (g) Taking the diagnostic plot and your answer to (e) together, what is 
#     wrong with this model, and what follows for the coefficient table?

# The spread of the residuals grows with the fitted value, so the constant-variance 
# assumption fails. The coefficient estimates stay unbiased, but their standard errors, 
# t values and any intervals built from them are unreliable.

# ----------------------------------------------------------------------------

# applied_diagnostics.R

# ============================================================================
# STAT312 Practical 3.5 (take-home) - Simple linear regression and residual
#                                     diagnostics
# ============================================================================
#
# Scenario: a quantity surveyor has records of 180 completed building
# projects: the floor area of each (square metres) and its final cost
# (R thousand). A simple linear regression of cost on floor area looks like an
# obvious place to start.
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or the set.seed(...) line.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# This is a FORMATIVE take-home: the comments point you at the functions you
# need, and ?help is always worth reading. Round answers to FOUR decimals.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

# -- Data generation (do NOT change) -----------------------------------------
set.seed(48519)
n <- 180
floor_area <- runif(n, 40, 420)
sigma_i    <- 18 + 0.26 * floor_area
cost       <- 100 + 7.8 * floor_area + rnorm(n, 0, sigma_i)
projects   <- data.frame(cost = cost, floor_area = floor_area)

# -- Step 1: fit the simple linear regression --------------------------------
# One predictor only. Consult ?lm and ?formula.
fit <- lm(cost ~ floor_area, data = projects)

# -- Step 2: read the coefficient table --------------------------------------
# coef(summary(fit)) returns a MATRIX with one row per term and the columns
# Estimate, Std. Error, t value, Pr(>|t|). You can pull a single number out of
# it with [row, column] indexing, by name or by position -- consult ?"[".
ct <- coef(summary(fit))
print(ct)          # look at it before you index it

b0_hat <- ct[1]  # Estimated intercept.
b1_hat <- ct[2]   # Estimated slope on floor_area.
se_b1  <- ct[4]   # Standard error of that slope.
t_b1   <- ct[6] # t value for that slope.

# -- Step 3: look at the residuals -------------------------------------------
# The four standard diagnostic panels come from plot(fit); run it and look.
par(mfrow = c(2, 2))
plot(fit)
par(mfrow = c(1, 1))

# Now put a number on what the first panel shows. Consult ?residuals, ?fitted,
# ?abs and ?cor. A residual plot with no structure should show NO relationship
# between the SIZE of a residual and the fitted value.
res  <- residuals(fit)   # The model residuals.
fitv <- fitted(fit)   # The fitted values.

cor_absres <- cor(abs(res), fitv)   # Correlation between the absolute residuals and the fitted values.

# -- Step 4: leverage ---------------------------------------------------------
# Leverage measures how unusual an observation is in the PREDICTOR space.
# Consult ?hatvalues.
max_hat <- max(hatvalues(fit))   # The largest leverage value in the data.

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Intercept                        :", round(b0_hat,     4)),
  paste("Slope on floor_area              :", round(b1_hat,     4)),
  paste("Std. Error of the slope          :", round(se_b1,      4)),
  paste("t value of the slope             :", round(t_b1,       4)),
  paste("cor(|residual|, fitted)          :", round(cor_absres, 4)),
  paste("Maximum leverage                 :", round(max_hat,    4))
))

# -- Something to think about (not marked) -----------------------------------
# Look again at the first diagnostic panel and at R-squared. Would you have
# noticed anything wrong from the coefficient table alone?



# ----------------------------------------------------------------------------

# Question 9

# Scenario. A dairy herd record gives, for each of 240 cows, its daily feed intake
# (kg dry matter) and its daily milk yield (litres). Fitting the model is not the point 
# of this exercise. The question is how much you can trust a test score computed from a 
# single holdout split.
# 
# To find out, you will repeat the whole split–fit–score cycle 200 times at each of 
# two training proportions, α=0.5 and α=0.9, and compare not just the average test RMSE
# but its spread across repetitions.
# 
# Round numeric answers to four decimal places.

# (a) For a single split at α=0.9, how many observations are held out for testing?
#   
#   24
# 
# (b) The mean test RMSE across the 200 repetitions at α=0.5:
#   
#   2.6939
# 
# (c) The standard deviation of those test RMSEs at α=0.5:
#   
#   0.1233
# 
# (d) The mean test RMSE across the 200 repetitions at α=0.9:
#   
#   2.6717
# 
# (e) The standard deviation of those test RMSEs at α=0.9:
#   
#   0.3805
# 
# (f) Compare your answers to (c) and (e). Why does the spread differ?
#   
#   Multiple choice 1 Question 9
#   Holding back fewer observations makes the test score less precise: with a smaller 
#   test set each estimate is computed from fewer errors, so it varies more from split 
#   to split, even though the model itself is trained on more data.

# ----------------------------------------------------------------------------

# applied_splitsize.R

# ============================================================================
# STAT312 Practical 3.5 (take-home) - How the split proportion affects the
#                                     performance ESTIMATE
# ============================================================================
#
# Scenario: a dairy herd record gives, for each of 240 cows, its daily feed
# intake (kg dry matter) and its daily milk yield (litres). Fitting the model is
# not the point of this exercise. The question is how much you can TRUST a test
# score computed from a single holdout split -- and how that changes with the
# training proportion alpha.
#
# The idea: repeat the whole split-fit-score cycle 200 times at each alpha
# and look at the SPREAD of the resulting test RMSEs.
#
# HOW TO USE THIS SCRIPT
#   1. Replace every your_code_goes_here() with your own code.
#   2. Do NOT change the data block or any set.seed(...) line.
#   3. Run the whole script with Source. Enter the printed values into Moodle.
#
# This is a FORMATIVE take-home: the comments point you at the functions you
# need, and ?help is always worth reading. Round answers to FOUR decimals.
# ============================================================================

your_code_goes_here <- function(...) {
  stop("Placeholder not replaced. Replace each your_code_goes_here() with your own code.")
}

library(rsample)

# -- Data generation (do NOT change) -----------------------------------------
set.seed(53887)
n <- 240
feed  <- rnorm(n, 22, 4)
yield <- 6.5 + 0.92 * feed + rnorm(n, 0, 2.6)
dairy <- data.frame(yield = yield, feed = feed)

reps <- 200
a_lo <- 0.5     # the SMALL training proportion
a_hi <- 0.9     # the LARGE training proportion

# -- Step 1: one repetition of the holdout cycle ------------------------------
# Fill in the body of this helper. For ONE random split at proportion `alpha`
# it must: split the data, fit yield on feed to the training part, predict on
# the held-out part, and return the test RMSE.
# Consult ?initial_split, ?training, ?testing, ?lm, ?predict.
one_holdout <- function(alpha) {
  sp <- initial_split(dairy, alpha)  # A random split of dairy at proportion alpha.
  tr <- training(sp)
  te <- testing(sp)
  m  <- lm(yield ~ feed, data = tr)   # Fit the model on the training part.
  p  <- predict(m, newdata = te)   # Predict for the held-out part.
  sqrt(mean((te$yield - p)^2))         # Return the root mean squared error of those predictions.
}

# -- Step 2: repeat it many times at each alpha (do NOT change) ---------------
# sapply() runs one_holdout() once per repetition and collects the results into
# a numeric vector -- see ?sapply. The seed is reset before each run so that
# your numbers match the marking key exactly.
set.seed(53887); rmse_lo <- sapply(seq_len(reps), function(r) one_holdout(a_lo))
set.seed(53887); rmse_hi <- sapply(seq_len(reps), function(r) one_holdout(a_hi))

# -- Step 3: how big is the test set at the LARGE proportion? ------------------
set.seed(53887)
n_test_hi <- nrow(testing(initial_split(dairy, prop = a_hi)))   # Number of held-out rows for a single split at a_hi.

# -- Step 4: summarise each collection of 200 estimates ------------------
# For each alpha: where do the estimates sit on average, and how much do they
# vary from one split to the next? Consult ?mean and ?sd.
mean_lo <- mean(rmse_lo)
sd_lo   <- sd(rmse_lo)
mean_hi <- mean(rmse_hi)
sd_hi   <- sd(rmse_hi)

# -- Report the values to enter into Moodle ----------------------------------
writeLines(c(
  paste("Test rows at the large alpha     :", n_test_hi),
  paste("Mean test RMSE, small alpha      :", round(mean_lo, 4)),
  paste("SD   test RMSE, small alpha      :", round(sd_lo,   4)),
  paste("Mean test RMSE, large alpha      :", round(mean_hi, 4)),
  paste("SD   test RMSE, large alpha      :", round(sd_hi,   4))
))

# -- Something to think about (not marked) -----------------------------------
# Try hist(rmse_lo) and hist(rmse_hi) on the same x-axis range. If you had run
# only ONE split at the large alpha, how far out could your answer have been?



# ----------------------------------------------------------------------------










