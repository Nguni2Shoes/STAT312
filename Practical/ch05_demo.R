# Logistic Regression for Binary Classification
# STAT312: Chapter 5 (in-class demonstration)
#
# This script walks through the worked examples from the Chapter 5 notes:
# the logistic function, simple logistic regression (customer purchase),
# classification performance evaluation, and multiple logistic regression
# (customer churn). All data is simulated in-script, so this runs with no
# path edits. Work through it top to bottom, running each block in the
# console.

# Load required packages
library(tidyverse)   # data handling and plotting
library(rsample)     # initial_split(), training(), testing()
library(yardstick)   # conf_mat(), metrics(), roc_curve(), etc.


# --------------------------------------------------------------------
# EXAMPLE 1 · THE LOGISTIC (SIGMOID) FUNCTION
# --------------------------------------------------------------------
# h(t) = 1 / (1 + exp(-t)) maps any real number onto (0, 1). It's the
# link that turns an unbounded linear predictor into a valid probability.
t_values <- seq(-6, 6, length.out = 100)
logistic_data <- tibble(
  t = t_values,
  probability = 1 / (1 + exp(-t))
)

ggplot(logistic_data, aes(x = t, y = probability)) +
  geom_line(colour = "steelblue", linewidth = 1.2) +
  geom_hline(yintercept = c(0, 0.5, 1),
             linetype = "dashed", colour = "grey50", alpha = 0.7) +
  geom_vline(xintercept = 0,
             linetype = "dashed", colour = "grey50", alpha = 0.7) +
  labs(title = "The Standard Logistic Function",
       x = "Linear Predictor (t)", y = "Probability p(t)") +
  scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1)) +
  theme_minimal()

# Note h(0) = 0.5 exactly, and the curve is steepest there. Try a few
# values by hand to build intuition:
h <- function(t) 1 / (1 + exp(-t))
h(c(-4, -1, 0, 1, 4))


# --------------------------------------------------------------------
# EXAMPLE 2 · ODDS AND LOG-ODDS (LOGIT)
# --------------------------------------------------------------------
# logit(p) = ln(p / (1 - p)) maps a probability onto the whole real line
# and is linear in the predictors. This is the quantity glm() actually
# models.
p <- 0.8
odds <- p / (1 - p)
log_odds <- log(odds)
cat("p =", p, " odds =", odds, " log-odds =", round(log_odds, 3), "\n")

p2 <- 0.2
cat("p =", p2, " odds =", round(p2 / (1 - p2), 3),
    " log-odds =", round(log(p2 / (1 - p2)), 3), "\n")
# Log-odds are symmetric about p = 0.5 (0 on the log-odds scale).


# --------------------------------------------------------------------
# EXAMPLE 3 · SIMPLE LOGISTIC REGRESSION (Customer Purchase Behaviour)
# --------------------------------------------------------------------
# Simulate purchase likelihood as a function of customer age.
set.seed(2024)
n <- 500

customer_data <- tibble(
  customer_id = 1:n,
  age = round(rnorm(n, mean = 45, sd = 15)),
  purchase_logit = -2.5 + 0.06 * age + rnorm(n, 0, 0.5),
  purchase_prob = 1 / (1 + exp(-purchase_logit)),
  purchased = rbinom(n, 1, purchase_prob)
) |>
  filter(age >= 18, age <= 80) |>
  mutate(purchased = factor(purchased, levels = c(0, 1),
                             labels = c("No", "Yes")))

customer_data |>
  select(customer_id, age, purchased) |>
  head()

# Visualise: does purchase probability rise with age?
customer_data |>
  ggplot(aes(x = age, y = as.numeric(purchased) - 1)) +
  geom_point(alpha = 0.6, position = position_jitter(height = 0.02)) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"),
              se = TRUE, colour = "red") +
  labs(title = "Purchase Probability by Customer Age",
       x = "Age (years)", y = "Purchase Probability") +
  scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1)) +
  theme_minimal()

# Train/test split, stratified on the outcome so both sets keep the
# same class balance.
set.seed(2024)
customer_split <- initial_split(
  customer_data, prop = 0.8,
  strata = purchased)
train_data <- training(customer_split)
test_data <- testing(customer_split)

# Fit with glm(family = binomial()) -- maximum likelihood, not OLS.
purchase_model <- glm(
  purchased ~ age,
  data = train_data,
  family = binomial())
coef(summary(purchase_model))

# NOTE: glm() takes the factor's SECOND alphabetical level ("Yes") as
# the positive class here, since levels are c("No", "Yes").

# Interpretation: exponentiate the age coefficient to get an odds ratio.
odds_ratio <- exp(coef(purchase_model)["age"])
cat("Odds ratio for age:", round(odds_ratio, 4), "\n")
cat("Each additional year increases purchase odds by",
    round((odds_ratio - 1) * 100, 1), "%\n")


# --------------------------------------------------------------------
# EXAMPLE 4 · CLASSIFICATION PERFORMANCE (Confusion Matrix + Metrics)
# --------------------------------------------------------------------
# Turn predicted probabilities into class labels at a 0.5 threshold,
# then evaluate with yardstick. Remember: yardstick treats the FIRST
# factor level as positive by default, so we set event_level = "second"
# throughout since our positive class ("Yes") is the second level.
test_results <- test_data |>
  mutate(
    pred_prob = predict(purchase_model, newdata = test_data, type = "response"),
    pred_class = factor(ifelse(pred_prob > 0.5, "Yes", "No"),
                         levels = c("No", "Yes"))
  )

conf_matrix <- test_results |>
  conf_mat(truth = purchased, estimate = pred_class)
print(conf_matrix)
summary(conf_matrix, event_level = "second")

# Individual metrics, explicit about the positive class each time.
test_results |> accuracy(truth = purchased, estimate = pred_class,
                          event_level = "second")
test_results |> precision(truth = purchased, estimate = pred_class,
                           event_level = "second")
test_results |> recall(truth = purchased, estimate = pred_class,
                        event_level = "second")
test_results |> f_meas(truth = purchased, estimate = pred_class, beta = 1,
                        event_level = "second")

# ROC curve and AUC (probability-based, threshold-free) -- NOT EXAMINABLE
# but useful for intuition.
prob_metrics <- test_results |>
  roc_auc(truth = purchased, pred_prob, event_level = "second")
cat("AUC:", round(prob_metrics$.estimate, 4), "\n")

test_results |>
  roc_curve(truth = purchased, pred_prob, event_level = "second") |>
  autoplot() +
  labs(title = "ROC Curve: Customer Purchase Prediction",
       subtitle = paste("AUC =", round(prob_metrics$.estimate, 3))) +
  theme_minimal()


# --------------------------------------------------------------------
# EXAMPLE 5 · MULTIPLE LOGISTIC REGRESSION (Customer Churn)
# --------------------------------------------------------------------
# Extend to several predictors: tenure, monthly charges, streaming TV.
set.seed(2024)
n <- 1000

churn_data <- tibble(
  customer_id = 1:n,
  tenure_months = rpois(n, lambda = 24),
  monthly_charges = round(rnorm(n, mean = 75, sd = 20), 2),
  streaming_tv = sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.6, 0.4)),
  churn_logit = -1.49 - 0.06 * tenure_months + 0.025 * monthly_charges +
    ifelse(streaming_tv == "Yes", 0.8, 0) + rnorm(n, 0, 0.5),
  churn_prob = 1 / (1 + exp(-churn_logit)),
  churned = rbinom(n, 1, churn_prob)
) |>
  mutate(churned = factor(churned, levels = c(0, 1), labels = c("No", "Yes")),
         streaming_tv = factor(streaming_tv)) |>
  filter(tenure_months >= 1, monthly_charges > 0)

set.seed(20250825)
churn_split <- initial_split(churn_data, prop = 0.8, strata = churned)
churn_train <- training(churn_split)
churn_test <- testing(churn_split)

churn_model <- glm(churned ~ tenure_months + monthly_charges + streaming_tv,
                    data = churn_train, family = binomial())

# Coefficient table with odds ratios and 95% confidence intervals.
coef_summary <- as.data.frame(coef(summary(churn_model)))
names(coef_summary) <- c("estimate", "std.error", "statistic", "p.value")
coef_summary$term <- rownames(coef_summary)
coef_summary$odds_ratio <- exp(coef_summary$estimate)
coef_summary$conf_low <- exp(coef_summary$estimate - 1.96 * coef_summary$std.error)
coef_summary$conf_high <- exp(coef_summary$estimate + 1.96 * coef_summary$std.error)
coef_summary[, c("term", "estimate", "odds_ratio", "conf_low", "conf_high", "p.value")]

# Interpretation (holding other variables constant):
cat("Each extra month of tenure reduces churn odds by approximately",
    round((1 - exp(coef(churn_model)["tenure_months"])) * 100, 1), "%\n")
cat("Each additional unit of monthly charges increases churn odds by approximately",
    round((exp(coef(churn_model)["monthly_charges"]) - 1) * 100, 1), "%\n")
cat("Streaming TV customers have", round(exp(coef(churn_model)["streaming_tvYes"]), 2),
    "times the churn odds of those without\n")


# --------------------------------------------------------------------
# EXAMPLE 6 · CHURN MODEL PERFORMANCE (and why accuracy can mislead)
# --------------------------------------------------------------------
test_predictions <- churn_test |>
  mutate(
    predicted_prob = predict(churn_model, newdata = churn_test, type = "response"),
    predicted_class = factor(ifelse(predicted_prob > 0.5, "Yes", "No"),
                              levels = c("No", "Yes"))
  )

conf_matrix <- test_predictions |>
  conf_mat(truth = churned, estimate = predicted_class)
print(conf_matrix)
summary(conf_matrix, event_level = "second")

accuracy_result    <- test_predictions |> accuracy(truth = churned, estimate = predicted_class)
sensitivity_result <- test_predictions |> sens(truth = churned, estimate = predicted_class, event_level = "second")
specificity_result <- test_predictions |> spec(truth = churned, estimate = predicted_class, event_level = "second")
precision_result   <- test_predictions |> precision(truth = churned, estimate = predicted_class, event_level = "second")
f1_result           <- test_predictions |> f_meas(truth = churned, estimate = predicted_class, event_level = "second")

cat("Accuracy:   ", round(accuracy_result$.estimate, 4), "\n")
cat("Sensitivity:", round(sensitivity_result$.estimate, 4), "\n")
cat("Specificity:", round(specificity_result$.estimate, 4), "\n")
cat("Precision:  ", round(precision_result$.estimate, 4), "\n")
cat("F1-Score:   ", round(f1_result$.estimate, 4), "\n")

# High accuracy and specificity but poor sensitivity means the model is
# conservative: it rarely flags churn, so it misses most actual churners.
# For a retention use case, sensitivity and precision matter far more
# than raw accuracy here.


# --------------------------------------------------------------------
# EXERCISE · YOUR TURN
# --------------------------------------------------------------------
# (a) Add `contract_type` (Month-to-month / One year / Two year) as a
#     third categorical predictor of churn and refit the model. Which
#     contract type is the reference category, and why?
# (b) Try classification thresholds of 0.3 and 0.7 instead of 0.5 on
#     the churn test set. How do sensitivity and precision trade off?
# (c) In this business context, would you prefer a lower or higher
#     threshold than 0.5? Justify your answer using the confusion
#     matrix costs of a missed churner vs a false alarm.
