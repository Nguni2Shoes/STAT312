# Linear Regression Implementation + CV Model Selection
# STAT312: Chapter 3 (in-class demonstration)
#
# This script bridges two pieces of the module:
#   - Chapter 3:  fitting and *assessing* linear models in R.
#   - Practical 2: using cross-validation to *select* between models.
# It uses the simulated salary data from the Chapter 3 notes, so it runs
# with no external files. Work through it top to bottom, running each
# block in the console.

# Load required packages
library(tidyverse)   # data handling and plotting
library(rsample)     # initial_split(), vfold_cv(), analysis(), assessment()
library(broom)       # tidy() / glance() for model summaries
library(knitr)       # kable() for neat tables

# Simulated data uses a fixed seed so the demonstration is reproducible.
set.seed(2024)


# --------------------------------------------------------------------
# 1. SIMULATE THE SALARY DATA (from Chapter 3)
# --------------------------------------------------------------------
# Simple linear regression story: more experience -> higher salary.
n <- 200
experience <- runif(n, 0, 20)
salary <- 35000 + 2500 * experience + rnorm(n, 0, 5000)

employment_data <- tibble(
  employee_id = 1:n,
  experience_years = round(experience, 1),
  annual_salary = round(salary, 0)
)

# Extend to MULTIPLE regression by adding two categorical predictors.
# These have real effects on salary, which is what makes later model
# selection interesting: a model that ignores them should lose.
employment_data <- employment_data |>
  mutate(
    education_level = sample(
      c("Bachelor", "Master", "PhD"), n,
      replace = TRUE, prob = c(0.6, 0.3, 0.1)),
    department = sample(
      c("Engineering", "Sales", "Marketing", "HR"), n,
      replace = TRUE),
    # Layer education and department effects on top of the experience effect
    annual_salary = annual_salary +
      ifelse(education_level == "Master", 5000,
        ifelse(education_level == "PhD", 10000, 0)) +
      ifelse(department == "Engineering", 8000,
        ifelse(department == "Sales", 3000, 0)) +
      rnorm(n, 0, 2000)
  ) |>
  # Convert categorical variables to factors AFTER building salary, since
  # arithmetic on factors makes no sense.
  mutate(
    education_level = factor(education_level),
    department = factor(department)
  )

glimpse(employment_data)


# --------------------------------------------------------------------
# 2. EXPLORATORY DATA ANALYSIS
# --------------------------------------------------------------------
# Always look at the data before fitting anything. The smooth line lets
# us eyeball whether a straight line is a reasonable summary.
employment_data |>
  ggplot(aes(x = experience_years, y = annual_salary)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, colour = "red") +
  labs(
    title = "Relationship between Experience and Salary",
    x = "Years of Experience",
    y = "Annual Salary"
  ) +
  theme_minimal()


# --------------------------------------------------------------------
# 3. TRAIN-TEST SPLIT
# --------------------------------------------------------------------
# Hold out 20% of the data so we have an honest estimate of how the model
# performs on employees it has never seen.
employment_split <- initial_split(employment_data, prop = 0.8)
train_data <- training(employment_split)
test_data  <- testing(employment_split)

cat("Training observations:", nrow(train_data), "\n")
cat("Testing observations: ", nrow(test_data), "\n")


# --------------------------------------------------------------------
# 4. SIMPLE LINEAR REGRESSION
# --------------------------------------------------------------------
# Fit salary ~ experience on the training set. lm() does ordinary least
# squares; the residuals are minimised in sample.
salary_model <- lm(annual_salary ~ experience_years,
                   data = train_data)

# Coefficient table: estimates, standard errors, t values, p values.
coef(summary(salary_model))

# A compact set of model statistics via broom::glance().
glance(salary_model) |>
  select(r.squared, adj.r.squared, sigma, AIC, nobs)

# Fitted model equation:
#   Salary = intercept + slope * Experience
coef(salary_model)

# Generate predictions on the held-out test set and inspect the residuals.
test_predictions <- test_data |>
  mutate(
    predicted_salary = predict(salary_model, newdata = test_data),
    residual = annual_salary - predicted_salary
  )

head(test_predictions |>
       select(employee_id, experience_years, annual_salary,
              predicted_salary, residual))


# --------------------------------------------------------------------
# 5. ASSESSMENT METRICS
# --------------------------------------------------------------------
# A single helper that computes all the metrics from Chapter 3 on a
# test set. This is the same function used in the notes.
compute_metrics <- function(model, data, response) {
  predictions <- predict(model, newdata = data)
  actual <- data[[response]]
  list(
    mse  = mean((actual - predictions)^2),
    rmse = sqrt(mean((actual - predictions)^2)),
    mae  = mean(abs(actual - predictions)),
    mape = mean(abs((actual - predictions) / actual)) * 100,
    r_squared = cor(actual, predictions)^2
  )
}

simple_metrics <- compute_metrics(salary_model, test_data, "annual_salary")
simple_metrics

# Quick interpretation guide:
#   - RMSE / MAE are in salary units (R), so "error of about RX".
#   - MAPE is a percentage: typical error is X% of the actual salary.
#   - R^2 is the squared correlation between actual and predicted.


# --------------------------------------------------------------------
# 6. MULTIPLE LINEAR REGRESSION
# --------------------------------------------------------------------
# Now add education and department. lm() creates dummy variables for
# factor predictors automatically, using the alphabetically first level
# as the reference category (Bachelor, Engineering).
multiple_model <- lm(
  annual_salary ~ experience_years + education_level + department,
  data = train_data
)

summary(multiple_model)
glance(multiple_model) |>
  select(r.squared, adj.r.squared, sigma, AIC, nobs)

# Compare simple vs multiple on the SAME test set.
multiple_metrics <- compute_metrics(multiple_model, test_data, "annual_salary")

# Side-by-side comparison
comparison <- tibble(
  metric = names(simple_metrics),
  simple  = as.numeric(simple_metrics),
  multiple = as.numeric(multiple_metrics)
)
comparison

# Note: adding the real predictors should drop the RMSE and raise R^2.
# Coefficients are "partial effects": the expected change in salary for a
# one-unit change in the predictor, holding the others constant.


# --------------------------------------------------------------------
# 7. DIAGNOSTIC PLOTS
# --------------------------------------------------------------------
# The four base R diagnostic plots check linearity, normality of
# residuals, equal variance (homoscedasticity), and influential points.
par(mfrow = c(2, 2))
plot(multiple_model)
par(mfrow = c(1, 1))


# --------------------------------------------------------------------
# 8. CROSS-VALIDATION FOR MODEL SELECTION (Practical 2 bridge)
# --------------------------------------------------------------------
# The test-set comparison above depends on one split. Cross-validation
# averages over many splits for a more stable comparison, which is the
# core idea of Practical 2.
#
# We define THREE competing specifications, just like the practical:
#   simple    - key driver only
#   full      - everything available
#   optimised - a hand-picked middle ground
model_specs <- list(
  simple    = annual_salary ~ experience_years,
  full      = annual_salary ~ .,
  optimised = annual_salary ~ experience_years + education_level + department
)

# 10-fold CV on the TRAINING data (the test set stays untouched for the
# very final check).
set.seed(123)
cv_folds <- vfold_cv(train_data, v = 10)

# Function to fit one specification on one fold and return its metrics.
# This mirrors calc_metrics() in the Practical 2 model answers.
calc_fold_metrics <- function(split, formula) {
  fold_train <- analysis(split)
  fold_test  <- assessment(split)
  fit  <- lm(formula, data = fold_train)
  preds <- predict(fit, newdata = fold_test)
  tibble(
    rmse = sqrt(mean((fold_test$annual_salary - preds)^2)),
    mae  = mean(abs(fold_test$annual_salary - preds)),
    r2   = cor(fold_test$annual_salary, preds)^2
  )
}

# Apply each specification to every fold using map() + unnest().
# (Chapter 3 shows the base-R sapply() equivalent; this tidyverse style
#  is what Practical 2 expects.)
cv_results <- imap_dfr(model_specs, function(spec, name) {
  cv_folds |>
    mutate(metrics = map(splits, ~ calc_fold_metrics(.x, spec))) |>
    unnest(metrics) |>
    summarise(
      rmse_mean = mean(rmse), rmse_se = sd(rmse) / sqrt(n()),
      mae_mean  = mean(mae),  mae_se  = sd(mae)  / sqrt(n()),
      r2_mean   = mean(r2),   r2_se   = sd(r2)   / sqrt(n())
    ) |>
    mutate(model = name)
}) |>
  relocate(model)

# Summary table with mean +/- SE across the folds.
cv_results |>
  select(model, rmse_mean, rmse_se, mae_mean, mae_se, r2_mean, r2_se) |>
  kable(
    digits = 2,
    col.names = c("Model", "RMSE", "RMSE SE", "MAE", "MAE SE",
                  "R^2", "R^2 SE"),
    caption = "Cross-Validation Performance (10 folds)"
  )

# Select the model with the lowest mean RMSE.
best_model_name <- cv_results |>
  arrange(rmse_mean) |>
  slice(1) |>
  pull(model)
cat("Best model by CV RMSE:", best_model_name, "\n")


# --------------------------------------------------------------------
# 9. FINAL MODEL + INTERPRETATION
# --------------------------------------------------------------------
# Re-fit the selected specification on ALL the data and read off the
# coefficients in business terms.
final_fit <- lm(model_specs[[best_model_name]], data = employment_data)

glance(final_fit) |>
  select(r.squared, adj.r.squared, sigma, AIC, nobs)

tidy(final_fit) |>
  mutate(
    conf.low = estimate - 1.96 * std.error,
    conf.high = estimate + 1.96 * std.error
  ) |>
  select(term, estimate, conf.low, conf.high, p.value) |>
  kable(digits = 2)

# Each significant coefficient is the expected salary change for a
# one-unit / one-level change, holding everything else fixed. For
# example, the experience slope is roughly how much salary rises per
# extra year of experience.


# --------------------------------------------------------------------
# 10. REFLECTION: CV vs IN-SAMPLE
# --------------------------------------------------------------------
# Practical 2 Task 8 asks how CV changes model choice compared with just
# reading off in-sample R^2. Compare the two:
in_sample_r2 <- glance(final_fit)$r.squared
cv_r2 <- cv_results |>
  filter(model == best_model_name) |>
  pull(r2_mean)

cat("In-sample R^2:", round(in_sample_r2, 3), "\n")
cat("CV R^2:       ", round(cv_r2, 3), "\n")
cat("Gap:          ", round(in_sample_r2 - cv_r2, 3), "\n")

# A small gap -> the model generalises well and overfitting is not a
# concern. A large gap -> in-sample fit is optimistic and CV was the
# honest estimate. That gap is the whole reason to cross-validate.
