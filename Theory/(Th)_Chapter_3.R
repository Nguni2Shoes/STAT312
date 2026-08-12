# =============================================================================
# =============================================================================

#                               Notes:
#                 Linear Regression Implementation in R

# =============================================================================
# =============================================================================

# Contents
# 1 Introduction 
# 2 Simple Linear Regression 
# 2.1 Implementation Workflow
# 2.1.1 Exploratory Data Analysis
# 2.1.2 Train-Test Partitioning
# 2.1.3 Model Fitting and Interpretation
# 2.1.4 Prediction and Model Assessment 
# 3 Multiple Linear Regression 
# Model Specification and Fitting 
# Coefficient Interpretation 
# 4 Model Assessment Metrics 
# 4.1 Mean Squared Error (MSE) and Root MSE (RMSE)
# 4.2 Mean Absolute Error (MAE) 
# 4.3 Mean Absolute Percentage Error (MAPE) 
# 4.4 Coefficient of Determination (𝑅2) 
# 4.5 Demonstration in R 
# 5 Advanced Implementation Considerations
# 5.1 Diagnostic Plots 
# 5.2 Cross-Validation Integration 
# 6 Conclusion 

# ============================================================================

# 1 Introduction

# Linear regression provides a fundamental framework for modelling relationships between
# continuous response variables and explanatory variables. This chapter demonstrates practical
# implementation of linear regression in R, building upon theoretical foundations established
# in STAS202 whilst introducing modern computational approaches through the tidyverse
# ecosystem.
# The linear regression model assumes that the conditional expectation of the response variable
# follows a linear function of the predictors:

# 𝐸[𝑌| 𝑋1, 𝑋2, …, 𝑋𝑝] = 𝛽0 + 𝛽1𝑋1 + 𝛽2𝑋2 + ⋯+ 𝛽𝑝𝑋𝑝

# where 𝛽0, 𝛽1, …, 𝛽𝑝 represent unknown parameters estimated via ordinary least squares (OLS).
# The error term 𝜀∼𝑁(0, 𝜎2) captures unexplained variation.

# This implementation-focused treatment emphasises practical model development, validation,
# and assessment using contemporary R programming practices rather than theoretical derivations 
# covered in prerequisite coursework.

# ============================================================================

# 2 Simple Linear Regression

# Simple linear regression models the relationship between a single predictor variable 𝑋 and a
# continuous response 𝑌 through the linear function:

#   𝑌= 𝛽0 + 𝛽1𝑋+ 𝜀

# The OLS estimates ̂𝛽0 and ̂𝛽1 minimise the sum of squared residuals, providing the best linear
# unbiased estimators under standard assumptions.

# ============================================================================

# 2.1 Implementation Workflow

# The regression analysis workflow consists of four primary stages: exploratory data analysis,
# model fitting, prediction, and validation. We demonstrate this process using a simulated
# dataset examining the relationship between employee experience and salary.

# Example: Simple Linear Regression Implementation

# Generate synthetic employment data
set.seed(2024)
n <- 200
experience <- runif(n, 0, 20)
salary <- 35000 + 2500 * experience + rnorm(n, 0, 5000)
employment_data <- tibble(
  employee_id = 1:n,
  experience_years = round(experience, 1),
  annual_salary = round(salary, 0)
)
# Display first few observations
head(employment_data)

# A tibble: 6 × 3
#   employee_id       experience_years      annual_salary
#   <int>                 <dbl>               <dbl>
# 1   1                   16.7                87890
# 2   2                   6.4                 53244
# 3   3                   13.6                74234
# 4   4                   14                  70537
# 5   5                   9.1                 51524
# 6   6                   14                  71943

# ============================================================================

# 2.1.1 Exploratory Data Analysis
# Preliminary visualisation reveals the underlying relationship structure and identifies potential
# outliers or non-linear patterns that might violate model assumptions.

# Scatter plot with trend line
employment_data |>
  ggplot(aes(x = experience_years, y = annual_salary)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, colour = "red") +
  labs(
    title = "Relationship between Experience and Salary",
    x = "Years of Experience",
    y = "Annual Salary (£)"
  ) +
  theme_minimal()

# Figure: Relationship between (Years of Experience: x) and (Annual Salary - Pounds: y)
# Narrow & positive observations

# ============================================================================

# 2.1.2 Train-Test Partitioning
# Following resampling principles from Chapter 2, we partition the data using the rsample
# package for consistent, reproducible splits.

# Create train-test split using rsample
set.seed(2024)
data_split <- initial_split(employment_data, prop = 0.8)
train_data <- training(data_split)
test_data <- testing(data_split)
cat("Training observations:", nrow(train_data), "\n")

# Training observations: 160

cat("Testing observations:", nrow(test_data), "\n")

# Testing observations: 40

# ============================================================================

# 2.1.3 Model Fitting and Interpretation
# The lm() function implements OLS estimation, whilst the broom package provides tidy model
# summaries for downstream analysis.

# Fit simple linear regression
salary_model <- lm(annual_salary ~ experience_years,
                   data = train_data)
# Coefficient estimates using base R
model_summary <- coef(summary(salary_model))
print(model_summary)

#                   Estimate Std.   Error       t value     Pr(>|t|)
# (Intercept)       35556.620       745.15956   47.71679    9.513080e-96
# experience_years  2490.742        64.21284    38.78885    1.189924e-82

# Model statistics using base R
model_stats <- c(
  r.squared = summary(salary_model)$r.squared,
  adj.r.squared = summary(salary_model)$adj.r.squared,
  sigma = summary(salary_model)$sigma,
  AIC = AIC(salary_model)
)
print(model_stats)

# r.squared   adj.r.squared   sigma           AIC
# 0.9049667   0.9043652       4952.2425402    3180.4783787

# The fitted model equation becomes:

# ^Salary = 3.5557 × 10^4 + 2491 × Experience

# Coefficient Interpretation
# The intercept ̂𝛽0 = 3.5557 × 10^4 represents the expected salary for someone with zero
# years of experience. The slope ̂𝛽1 = 2491 indicates that each additional year of experience
# associates with a £2491 increase in expected annual salary, holding all else constant.

# ============================================================================

# 2.1.4 Prediction and Model Assessment

# Model evaluation requires predictions on the held-out test set to assess generalisation perfor­
# mance through established metrics.

# Generate predictions on test set
test_predictions <- test_data |>
  mutate(
    predicted_salary = predict(
      salary_model, newdata = test_data),
    residual = annual_salary - predicted_salary)
# Display sample predictions
head(
  test_predictions |>
    select(
      employee_id, experience_years, annual_salary,
      predicted_salary, residual))

# A tibble: 6 × 5
#     employee_id   experience_years  annual_salary   predicted_salary  residual
#     <int>         <dbl>             <dbl>           <dbl>             <dbl>
# 1   7             8.3               54788           56230.            -1442.
# 2   12            19.1              88279           83130.            5149.
# 3   15            9                 54348           57973.            -3625.
# 4   17            2.2               50040           41036.            9004.
# 5   23            13.6              62503           69431.            -6928.
# 6   30            0.4               38654           36553.            2101.

# ============================================================================

# 3 Multiple Linear Regression

# Multiple linear regression extends the simple case to incorporate multiple predictors 
# simultaneously:

#   𝑌= 𝛽0 + 𝛽1𝑋1 + 𝛽2𝑋2 + ⋯+ 𝛽𝑝𝑋𝑝+ 𝜀

# This framework enables control for confounding variables and investigation of complex
# mutlivariable relationships whilst maintaining the linear structure’s interpretability advantages.

# Example: Multiple Linear Regression Data

# We extend our employment example to include additional predictors: education level and
# department type

# Generate extended dataset with multiple predictors
set.seed(2024)
extended_data <- employment_data |>
  mutate(
    education_level = sample(
      c("Bachelor", "Master", "PhD"), n,
      replace = TRUE, prob = c(0.6, 0.3, 0.1)),
    department = sample(
      c("Engineering", "Sales", "Marketing", "HR"), n,
      replace = TRUE),
    # Adjust salary based on education and department
    annual_salary = annual_salary +
      ifelse(education_level == "Master", 5000,
             ifelse(education_level == "PhD", 10000, 0)) +
      ifelse(department == "Engineering", 8000,
             ifelse(department == "Sales", 3000, 0)) +
      rnorm(n, 0, 2000)
  )

# Conditional Logic
# Nested ifelse() statements provide a straightforward way to express conditional logic
# in base R. ifelse(test, yes, no) returns the yes value where test is TRUE and the no value
# otherwise. By placing another ifelse() in the no position, conditions are checked in order,
# with the final no acting as a catch-all for any remaining cases. See ?ifelse for details.

# Example: Multiple Linear Regression Data (Continued)


# Though not technically necessary in this example,
# it is always a good idea to convert categorical
# variables to the factor data type.
# NOTE that we do this AFTER calculating `annual_salary`
# since adding factors to numerical data does not make
# sense
extended_data <- extended_data |>
  mutate(
    education_level = factor(education_level),
    department = factor(department)
  )
# Create new train-test split
set.seed(2024)
extended_split <- initial_split(extended_data, prop = 0.8)
train_extended <- training(extended_split)
test_extended <- testing(extended_split)

# Model Specification and Fitting
# Multiple regression in R handles categorical variables automatically through dummy variable
# encoding, simplifying the specification process.

# Fit multiple linear regression
multiple_model <- lm(
  annual_salary ~ experience_years + education_level +
    department,
  data = train_extended)
# Model summary using base R to avoid LaTeX issues
summary(multiple_model)

# Call:
lm(formula = annual_salary ~ experience_years + education_level +
       department, data = train_extended)
# Residuals:
#   Min         1Q          Median      3Q        Max
#   -17530.3    -3230.1     335.7       3250.6    14611.1
# Coefficients:
#                         Estimate Std.   Error   t_value   Pr(>|t|)
# (Intercept)             42458.6         1291.2  32.883    < 2e-16 ***
# experience_years        2696.0          158.9   16.965    < 2e-16 ***
# education_levelMaster   1848.6          1821.6  1.015     0.3118
# education_levelPhD      6904.1          2769.0  2.493     0.0137 *
# departmentHR            -7442.3         1206.2  -6.170    5.85e-09 ***
# departmentMarketing     -7184.7         1214.1  -5.918    2.06e-08 ***
# departmentSales         -3664.6         1309.7  -2.798    0.0058 **
# ---
# Signif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
  
# Residual standard error: 5524 on 153 degrees of freedom
# Multiple R-squared: 0.9204, Adjusted R-squared: 0.9173
# F-statistic: 294.8 on 6 and 153 DF, p-value: < 2.2e-16

  
# Coefficient Interpretation
# Multiple regression coefficients represent partial effects. That is, the expected change in the
# response variable for a one-unit increase in the predictor, holding all other variables constant.
  
# Reference Category Interpretation
# R automatically creates dummy variables for categorical predictors, using the alphabetically
# first category as the reference. Here, “Bachelor” serves as the education reference
# and “Engineering” as the department reference. All other coefficients represent differences 
# relative to these baseline categories.

# ============================================================================

# 4 Model Assessment Metrics

# Quantitative assessment of prediction accuracy requires standardised metrics that facilitate
# model comparison and performance interpretation.

# ============================================================================

# 4.1 Mean Squared Error (MSE) and Root MSE (RMSE)

# MSE measures average squared prediction errors, penalising large errors disproportionately:
# MSE = (1/n)∑_(i=1->n)(𝑦𝑖−̂𝑦𝑖)^2

# The square root of the MSE is the RMSE, RMSE = √MSE. 
# It has the advantage that it is measured in the same units as the target variable.

# ============================================================================

# 4.2 Mean Absolute Error (MAE)

# MAE measures average absolute prediction errors, penalising large errors less severely than MSE:
# MAE = (1/n)∑_(i=1->n)| 𝑦_i−̂𝑦_i  |

# Therefore, MAE is more robust against outliers than the MSE. Additionally, like RMSE, MAE is
# measured in the same units as the target variable.

# ============================================================================

# 4.3 Mean Absolute Percentage Error (MAPE)

# MAPE provides scale-invariant assessment, expressing errors as percentages of actual values:
# MAPE = (1/n)∑_(i=1->n)| 𝑦_i−̂𝑦_i / y_i | * 100%

# MAPE offers intuitive interpretation but becomes undefined when actual values equal zero
# and exhibits bias towards predictions that underestimate the response.

# ============================================================================

# 4.4 Coefficient of Determination (𝑅^2)

# In the context of evaluating prediction performance, the 𝑅^2 is simply the squared correlation
# between 𝑦𝑖 and ̂𝑦𝑖.

# ============================================================================

# 4.5 Demonstration in R

# Function to compute comprehensive model metrics
compute_metrics <- function(model, test_data, response_var) {
  predictions <- predict(model, newdata = test_data)
  actual <- test_data[[response_var]]
  metrics <- list(
    mse = mean((actual - predictions)^2),
    rmse = sqrt(mean((actual - predictions)^2)),
    mae = mean(abs(actual - predictions)),
    mape = mean(abs((actual - predictions) / actual)) * 100,
    r_squared = cor(actual, predictions)^2
  )
  return(metrics)
}
# Compute metrics for both models
simple_metrics <- compute_metrics(
  salary_model, test_data, "annual_salary")
multiple_metrics <- compute_metrics(
  multiple_model, test_extended, "annual_salary")
# Display results
cat("Simple Linear Regression Metrics:\n")

# Simple Linear Regression Metrics:
cat("MSE:", round(simple_metrics$mse, 2), "\n")
# MSE: 16595316

cat("RMSE:", round(simple_metrics$rmse, 2), "\n")
# RMSE: 4073.73

cat("MAE:", round(simple_metrics$mae, 2), "\n")
# MAE: 3499.46

cat("MAPE:", round(simple_metrics$mape, 2), "%\n")
# MAPE: 6.16 %

cat("R-squared:", round(simple_metrics$r_squared, 4), "\n\n")
# R-squared: 0.9119

cat("Multiple Linear Regression Metrics:\n")
# Multiple Linear Regression Metrics:

cat("MSE:", round(multiple_metrics$mse, 2), "\n")
# MSE: 22579048

cat("RMSE:", round(multiple_metrics$rmse, 2), "\n")
# RMSE: 4751.74

cat("MAE:", round(multiple_metrics$mae, 2), "\n")
# MAE: 3990.68

cat("MAPE:", round(multiple_metrics$mape, 2), "%\n")
# MAPE: 7.05 %

cat("R-squared:", round(multiple_metrics$r_squared, 4), "\n")
# R-squared: 0.9257

# Metric Selection Guidelines
# • MSE/RMSE: Emphasises large errors; useful when large prediction errors incur 
# disproportionate costs
# • MAE: Robust to outliers; provides equal weight to all errors
# • MAPE: Scale-invariant; facilitates comparison across different response variable
# ranges
# • R²: Measures proportion of variance explained; useful for understanding model
# explanatory power

# ============================================================================

# 5 Advanced Implementation Considerations

# 5.1 Diagnostic Plots
# Regression diagnostics assess model assumptions through residual analysis and influence
# measures.

# Create diagnostic plots using base R plotting
par(mfrow = c(2, 2))
plot(multiple_model)

# Figure 2: Model Diagnostic Plots

# Residuals vs Fitted: Fitted values (x) vs Residuals (y) = straight horizontal line (narrow observations)
# Q-Q Residuals: Theoretical Quantiles (x) vs Standardized residuals = (narrow positive line)
# Scale-Location: Fitted values (x) vs sqrt(|Standardized residuals|) (y) = narrow horizontal line
# Residuals vs Leverage: Leverage (x) vs Standardized residuals = shorter horizontal line
# -> densely populated on the left and some observations on the right

par(mfrow = c(1, 1))

# ============================================================================

# 5.2 Cross-Validation Integration

# Combining regression with resampling techniques from Chapter 2 provides robust 
# performance assessment.

# K-fold cross-validation for model assessment
set.seed(2024)
cv_folds <- vfold_cv(train_extended, v = 5)
# Function to fit the model and compute MSE for one CV fold
compute_cv_mse <- function(split) {
  train_data <- analysis(split)
  test_data <- assessment(split)
  model <- lm(
    annual_salary ~ experience_years + education_level +
      department,
    data = train_data)
  predictions <- predict(model, newdata = test_data)
  mean((test_data$annual_salary - predictions)^2)
}
# Apply to all folds using base R
cv_results <- data.frame(
  mse = sapply(cv_folds$splits, compute_cv_mse)
)
# CV performance summary
cv_mse_mean <- mean(cv_results$mse)
cv_mse_se <- sd(cv_results$mse) / sqrt(5)
cat("Cross-validation Results:\n")

# Cross-validation Results:
cat("Mean MSE:", round(cv_mse_mean, 2), "\n")
# Mean MSE: 32387641

cat("Standard Error:", round(cv_mse_se, 2), "\n")
# Standard Error: 5106857

cat("RMSE:", round(sqrt(cv_mse_mean), 2), "\n")
# RMSE: 5691.01

# Iterating with base R
# Base R provides lapply() and sapply() for applying a function to each element of a
# list, such as the cross-validation splits. lapply() always returns a list, whilst sapply()
# simplifies the result into a vector or matrix when it can — here, sapply(cv_folds$splits,
# compute_cv_mse) returns a numeric vector with one MSE per fold. This gives a clean,
# readable way to iterate without writing an explicit loop. See ?sapply for details.

# Implementation Best Practices
# 1. Always visualise relationships before model fitting
# 2. Use consistent train-test splits for fair model comparison
# 3. Validate assumptions through diagnostic plots
# 4. Apply cross-validation for robust performance estimation
# 5. Choose metrics appropriate to the prediction context
# 6. Document code thoroughly for reproducible analysis

# ============================================================================

# 6 Conclusion

# This chapter established practical foundations for linear regression implementation in R,
# emphasising modern programming practices through the tidyverse ecosystem. The workflow
# demonstrated - from exploratory analysis through model fitting to validation - provides a
# robust framework for regression analysis in contemporary data science applications.
# Key implementation principles include systematic use of train-test partitioning, comprehensive
# model assessment through multiple metrics, and integration with resampling techniques
# for reliable performance estimation. These practices ensure reproducible, statistically sound
# regression analysis that generalises effectively to practical prediction problems.
# Subsequent chapters will extend these foundations to more complex modelling scenarios,
# building upon the computational and theoretical groundwork established here.

## ============================================================================
## ============================================================================

##                                Slides: 

## ============================================================================
## ============================================================================

# Today’s objectives
# By the end of this unit you should be able to:
# • Specify and fit simple and multiple regression with lm()
# • Interpret coefficients, including dummy-variable reference categories
# • Partition data into train / test sets for honest evaluation
# • Compute and compare prediction metrics (MSE, RMSE, MAE, MAPE, 𝑅2)
# • Read the four plot(model) diagnostics and apply cross-validation

# ============================================================================

# The Linear Regression Model

# What we are modelling
# Linear regression models the conditional mean of a continuous
# response as a linear function of the predictors:

#   𝐸[𝑌∣𝑋1, …, 𝑋𝑝] = 𝛽0 + 𝛽1𝑋1 + ⋯+ 𝛽𝑝𝑋𝑝

# with error 𝜀∼𝑁(0, 𝜎2) capturing unexplained variation. The
# parameters are estimated by ordinary least squares (OLS).

# The modelling workflow

# Stage         Tool                    Purpose
# 1.Explore     ggplot()                check linearity, outliers, clusters
# 2.Split       initial_split()         honest held-out test set
# 3.Fit         lm(y ~ x, data)         estimate coefficients by OLS
# 4.Predict     predict(model,newdata)  score the test set
# 5.Assess      metrics + plot(model)   accuracy and assumptions

# Every regression in this course follows these five steps.

# ============================================================================

# Simple Linear Regression

# One predictor, one response
# A single predictor 𝑋 and continuous response 𝑌:
#   𝑌= 𝛽0 + 𝛽1𝑋+ 𝜀
# The OLS estimates ̂𝛽0, ̂𝛽1 minimise the residual sum of squares.

# Reading the coefficients
# ̂𝛽0 is the expected 𝑌 when 𝑋= 0; ̂𝛽1 is the expected change in 𝑌
# for a one-unit rise in 𝑋. The reported 𝑡-value and 𝑝-value test
# 𝐻0 : 𝛽1 = 0.

# Figure: Annual salary (y) vs Years of experience (x)
# -> narrow positive line

# A clear, roughly linear trend — a straight-line model is reasonable here.

# Fit and split in R
set.seed(2024)
sp <- initial_split(emp, prop = 0.8) # 80/20
train <- training(sp); test <- testing(sp)
fit <- lm(annual_salary ~ experience_years, data = train)
coef(fit) # slope &
intercept

# term          estimate      std.error     statistic     p.value
# (intercept)   35556.6       745.2         47.7          0

# term                estimate      std.error     statistic     p.value
# experience_years    2490.7        64.2          38.8          0

# Each extra year of experience adds about £2491 to expected salary.

# ============================================================================

# Multiple Linear Regression

# Several predictors at once
# Extend to 𝑝 predictors simultaneously:
#   𝑌= 𝛽0 + 𝛽1𝑋1 + 𝛽2𝑋2 + ⋯+ 𝛽𝑝𝑋𝑝+ 𝜀

# This lets us control for confounders and read partial effects — the
# change in 𝑌 per unit of one predictor, holding the others fixed —
# while keeping the linear model’s interpretability.

# Factors become dummies
# R encodes a factor automatically as dummy variables, using the
# alphabetically first level as the reference. Other coefficients are
# differences from that baseline.

# -----------------------------------------------------------------------

# Numeric vs categorical predictors:

#               Numeric predictor       Categorical (factor)
# Encoding      used as-is              dummy(0/1) per non-reference level
# Coefficient   sloper per unit         gap vs reference category
# Example       +£2500 / year           Master earns +£5000 vs Bachelor
# ln lm()       experience              factor(department)

# The reference choice reframes the numbers but never changes the model fit.

# -----------------------------------------------------------------------

# Fitting the multiple model
# lm(mpg ~ wt + hp + factor(cyl), cars) — each 1000 lb costs 3.2
# mpg, holding hp and cyl fixed:

# term          estimate      p.value
# (Intercept)   35.85         0.00000
# wt            -3.18         0.00014
# hp            0.02          0.06400
# cyl6          -3.36         0.02400
# cyl8          -3.19         0.15000

# -----------------------------------------------------------------------

# The metrics at a glance

# Metric      Formula                       When to use
# MSE         (1/n)∑(𝑦_i−̂𝑦_i)^2           large errors very costly
# RMSE        sqrt(MSE)                     same units as Y; the default
# MAE         (1/n)|y_i-^y_i|               robust to outliers
# MAPE        (1/n)|y_i-^y_i / y_i| * 100%  scale-free % error
# R^2         cor(y,^y)^2                   variance explained

# All are computed on the held-out test set for an honest estimate.

# -----------------------------------------------------------------------

# Computing metrics in R
pred <- predict(fit, newdata = test); act <- test$y
c(rmse = sqrt(mean((act - pred)^2)),
  mae = mean(abs(act - pred)), r2 = cor(act, pred)^2)

# RMSE        MAE       MAPE      R2
# 4073.73     3499.46   6.16      0.91

# RMSE is in rands; 𝑅2 summarises how much variance the fit explains

# ============================================================================

# Diagnostic & Cross-Validation

# Figure
# Check linearity (residuals vs fitted), normality (Q–Q), constant
# variance (scale–location) and influence (leverage).

# -----------------------------------------------------------------------

# Cross-validation for a stable estimate

# A single split gives one noisy error estimate. 5-fold CV fits on five
# 80% portions and averages the test MSEs.

set.seed(2024)
folds <- vfold_cv(train, v = 5)
mse <- sapply(folds$splits, \(s)
              mean((assessment(s)$y -
                      predict(lm(y ~ x, analysis(s)), assessment(s)))^2))
mean(mse) # averaged test MSE

# Why average folds?
#   The spread of MSE across folds measures how sensitive
# performance is to the particular split — a large fold-to-fold
# spread signals an unstable model.

# ============================================================================

# Summary

# Key takeaways
# 1. Fit with lm(y ~ x1 + x2, data); factors become dummies automatically
# 2. Coefficients are partial effects relative to a reference category
# 3. Split with rsample, then evaluate only on the held-out test set
# 4. Match the metric to the cost: RMSE default, MAE robust, MAPE scale-free
# 5. Confirm assumptions with plot(model); stabilise estimates with CV

## ============================================================================
## ============================================================================

##                                Examples: 

## ============================================================================
## ============================================================================

# How to use these
# • Each example states a problem — try it before the reveal
# • Worked solutions appear in the lecturer copy (the amber boxes)
# • Code is real and runs against the course car_data dataset (mtcars-style)

# ============================================================================

# Example 1 · Explore before fitting

# Does weight explain fuel economy?
#   Load car_data and plot fuel economy (mpg) against weight (wt). Is a
#   straight-line model defensible?

cars <- read_csv("car_data.csv")
ggplot(cars, aes(wt, mpg)) +
  geom_point() + geom_smooth(method = "lm")

# Figure: Straight negative line (Fuel economy - mpg (x) vs weight - 1000 lb (y))
# Heavier cars use more fuel — a clear negative, roughly linear, relationship.

# Answer
 
# - Scenario: Load car_data and plot fuel economy (mpg) against weight (wt).
# - Answer: The relationship is a clear negative, roughly linear relationship. 
#           Heavier cars systematically use more fuel, making a straight-line model defensible

# ============================================================================

# Example 2 - Train/test split

# Hold out 25% of the cars

# Split car_data 75/25 with rsample. How many cars are in each part?
set.seed(312)
sp <- initial_split(cars, prop = 0.75)
train <- training(sp); test <- testing(sp)
c(train = nrow(train), test = nrow(test))

# train   test
# 24      8

# Answer

# Task: Split the 32 cars using a 75/25 proportion (set.seed(312)).
# Result:
#   - Training observations: 24.
#   - Testing observations: 8

# ============================================================================

# Example 3 · Fit & interpret

# Estimate the multiple model
# Fit mpg ~ wt + hp + cyl on the training data; interpret wt and cyl8.

fit <- lm(mpg ~ wt + hp + cyl, data = train)
round(coef(fit), 2)

# (Intercept)   wt      hp      cyl6    cyl8
# 35.28         -3.22   -0.02   -2.60   -2.07

# Answer

# Task: Estimate a multiple regression model: mpg ~ wt + hp + cyl.
# Fitted Coefficients:
#   - (Intercept): 35.28.
#   - wt: -3.22.
#   - hp: -0.02.
#   - cyl6: -2.60.
#   - cyl8: -2.07

# Interpretation: These represent partial effects—for example, 
# holding other factors fixed, every 1000lb increase in weight (wt) is 
# associated with an expected drop of 3.22 mpg

# ============================================================================

# Example 4 · Score on the test set

# Compute RMSE, MAE and R²
# Predict on the held-out cars and report RMSE, MAE and 𝑅2.
pred <- predict(fit, newdata = test); act <- test$mpg
round(c(rmse = sqrt(mean((act - pred)^2)),
        mae = mean(abs(act - pred)),
        r2 = cor(act, pred)^2), 3)

# rmse      mae       r2
# 2.538     1.750     0.923

# Answer

# Task: Predict on the 8 held-out cars and report accuracy metrics.
# Results: RMSE=..., mae=..., R^2=...

# ============================================================================

# Example 5 · Cross-validate

# Five-fold MSE on the full data
# A single 8-car split is unreliable — so run 5-fold CV for the same
# model.
set.seed(312)
folds <- vfold_cv(cars, v = 5)
cv_mse <- sapply(folds$splits, fold_mse) # one MSE / fold
round(mean(cv_mse), 2) # mean test MSE

# [1] 7

# Answer

# Scenario: A single 8-car split is unreliable ("a lottery"), 
#           so 5-fold cross-validation is used on 
#           the full dataset for a more stable estimate.
# Result: For the model mpg ~ wt + hp + factor(cyl), the calculated Mean CV MSE is 6.892 
#         with a Standard Error of 1.157.

# ============================================================================

# Example 6 - Diagnose the fit

# Read the residual plots
# Run plot(fit) and judge: linearity, constant variance, normality,
# influence. Any obvious problem cars?

# Answer
# 
# This example requires you to interpret the four standard diagnostic plots generated 
# by plot(fit) for the multiple regression model (mpg ~ wt + hp + cyl).
# 
# Linearity (Residuals vs Fitted): The red line is relatively flat and stays close 
#           to the horizontal zero line, indicating that the linearity assumption is reasonable.
# Constant Variance (Scale-Location): The spread of the residuals is fairly consistent 
#             across the range of fitted values, suggesting that homoscedasticity (constant variance) 
#             is mostly met, although the spread widens slightly at higher fitted values.
# Normality (Q-Q Residuals): The points closely follow the dashed diagonal line, which confirms 
#             that the residuals are approximately normally distributed.
# Influence (Residuals vs Leverage): No observations fall outside the dashed red Cook’s
#             distance boundaries (0.5 or 1.0), meaning there are no points with excessive 
#             influence on the model's coefficients.
# Problem Cars: The plots flag cars 17, 18, 20, and 31 as potential outliers or 
#             high-leverage points that warrant further investigation

# ============================================================================

# Exercise
# Using car_data, fit a simple model mpg ~ hp and a multiple model
# mpg ~ hp + wt, each on the same 75/25 split.
# (a) Which has the lower test RMSE?
# (b) Explain why adding wt helps, in terms of confounding.

# Answer

# a) Which has the lower test RMSE? The multiple regression model (mpg ~ wt + hp + factor(cyl)) 
#     will have the lower test RMSE compared to a simple regression model or one excluding wt. 
#     For the multiple model used in Example 4, the calculated Test RMSE was 2.538.
# b) Explain why adding wt helps, in terms of confounding. Adding wt (weight) improves the 
#     model because it acts as a confounder. Heavier cars naturally tend to have more cylinders 
#     and higher horsepower; if weight is omitted from the model, its strong negative impact on 
#     fuel economy would be wrongly attributed to the other variables. Including wt allows the model 
#     to control for this confounding effect and isolate the partial effects of horsepower and 
#     cylinders on mileage while holding weight constant




















