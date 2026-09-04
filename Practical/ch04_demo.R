# Regularised Regression: Ridge, LASSO and Elastic Net
# STAT312: Chapter 4 (in-class demonstration)
#
# This script walks through the five worked examples from the Chapter 4
# slides, plus the elastic-net exercise at the end. It uses the customer
# lifetime value (CLV) dataset that ships with the module: 20 predictors
# and n = 100 customers. The CSV lives in ./data/ next to this script, so
# it runs with no path edits. Work through it top to bottom, running each
# block in the console.

# Load required packages
library(tidyverse)   # data handling and plotting
library(glmnet)      # glmnet(), cv.glmnet() for ridge / LASSO / elastic net
library(rsample)     # initial_split(), training(), testing()
library(broom)       # tidy() for coefficient tables
library(knitr)       # kable() for neat tables

# The CLV data is committed alongside this script in ./data/. read_csv()
# keeps numeric columns numeric and leaves nothing to guesswork.
clv <- read_csv("data/customer_clv_data.csv", show_col_types = FALSE)

glimpse(clv)
# Note: 21 columns = response (clv) + 20 predictors. n = 100 rows.


# --------------------------------------------------------------------
# PREP: TRAIN / TEST SPLIT + DESIGN MATRICES
# --------------------------------------------------------------------
# glmnet needs the predictors as a numeric MATRIX and the response as a
# VECTOR. model.matrix() expands any factors into dummy columns and
# drops the intercept column (glmnet adds its own). We hold out 30% as
# an honest test set so Example 5 has unseen data to score against.
set.seed(312)
sp <- initial_split(clv, prop = 0.7)
tr <- training(sp); te <- testing(sp)

x_tr <- model.matrix(clv ~ ., tr)[, -1]; y_tr <- tr$clv
x_te <- model.matrix(clv ~ ., te)[, -1]; y_te <- te$clv

cat("Training rows:", nrow(x_tr),
    " Test rows:", nrow(x_te), "\n")


# --------------------------------------------------------------------
# EXAMPLE 1 · WHY REGULARISE?  (Plain OLS on 20 predictors)
# --------------------------------------------------------------------
# Fit ordinary least squares and count how many terms clear p < 0.05.
# With n = 100 and p = 20 — and several correlated spend predictors —
# OLS variances are inflated and most terms look insignificant even
# though the model keeps ALL of them. This is the setting shrinkage is
# built for.
ols <- lm(clv ~ ., data = tr)

# How many coefficients are "significant" at the 5% level?
n_sig <- sum(
  summary(ols)$coefficients[, 4] < 0.05)
cat("Significant terms (p < 0.05):", n_sig,
    "of", length(coef(ols)), "\n")

# Coefficient table for reference. tidy() from broom gives a clean tibble
# that kable() renders nicely.
tidy(ols) |>
  select(term, estimate, std.error, p.value) |>
  kable(digits = 3)


# --------------------------------------------------------------------
# EXAMPLE 2 · RIDGE REGRESSION WITH glmnet
# --------------------------------------------------------------------
# alpha = 0 -> pure L2 (ridge). cv.glmnet() picks lambda by 10-fold CV.
# Ridge shrinks every coefficient towards zero but NEVER to exactly zero,
# so all 20 predictors stay in the model.
set.seed(312)
cv_ridge <- cv.glmnet(x_tr, y_tr, alpha = 0, nfolds = 10)

cat("Ridge lambda.min:", round(cv_ridge$lambda.min, 1), "\n")

# CV curve: MSE dips then rises. lambda.min sits at the bottom.
plot(cv_ridge)
title("Ridge CV", line = 3.4)

# Inspect the shrunk coefficients at lambda.min. None are exactly zero.
ridge_cf <- coef(cv_ridge, s = "lambda.min")
data.frame(term = rownames(ridge_cf),
           estimate = as.vector(ridge_cf)) |>
  filter(term != "(Intercept)") |>
  kable(digits = 3)


# --------------------------------------------------------------------
# EXAMPLE 3 · LASSO FOR VARIABLE SELECTION
# --------------------------------------------------------------------
# alpha = 1 -> pure L1 (LASSO). The L1 penalty drives weak coefficients
# to EXACTLY zero, so LASSO doubles as automatic feature selection.
set.seed(312)
cv_lasso <- cv.glmnet(x_tr, y_tr, alpha = 1, nfolds = 10)

# Which terms survive at the 1-SE lambda? (Intercept is included.)
cf_1se <- coef(cv_lasso, s = "lambda.1se")
selected <- rownames(cf_1se)[as.vector(cf_1se) != 0]
cat("LASSO-selected terms (lambda.1se):\n")
print(selected)

# The survivors are the interpretable drivers of CLV; the noise
# predictors are dropped automatically.

# LASSO coefficient path: how each term enters as lambda relaxes.
plot(cv_lasso)
title("LASSO CV", line = 3.4)


# --------------------------------------------------------------------
# EXAMPLE 4 · THE 1-SE RULE IN ACTION
# --------------------------------------------------------------------
# lambda.min  : the lambda with the lowest CV MSE.
# lambda.1se  : the LARGEST lambda whose CV MSE is within one SE of the
#               minimum -> a simpler model at a statistically
#               indistinguishable error.
n_min <- sum(coef(cv_lasso, s = "lambda.min") != 0)
n_1se <- sum(coef(cv_lasso, s = "lambda.1se") != 0)

data.frame(rule = c("lambda.min", "lambda.1se"),
           nonzero_terms = c(n_min, n_1se)) |>
  kable(align = "lr")

# On the CV plot the two dashed vertical lines are lambda.min (right,
# weaker penalty, more terms) and lambda.1se (left, stronger penalty,
# fewer terms). The top axis counts the nonzero coefficients.

# Side-by-side coefficient sparsity at the two rules.
lasso_compare <- tibble(
  term   = rownames(coef(cv_lasso)),
  min    = as.vector(coef(cv_lasso, s = "lambda.min")),
  one_se = as.vector(coef(cv_lasso, s = "lambda.1se"))
) |>
  filter(term != "(Intercept)")
lasso_compare |>
  kable(digits = 3)


# --------------------------------------------------------------------
# EXAMPLE 5 · HONEST TEST-SET COMPARISON (Ridge vs LASSO)
# --------------------------------------------------------------------
# Score both models on the held-out 30% test set. The fair comparison is
# out-of-sample RMSE, never the training fit.
rmse <- function(pred, actual) sqrt(mean((actual - pred)^2))

pr_r <- predict(cv_ridge, x_te, s = "lambda.min")
pr_l <- predict(cv_lasso, x_te, s = "lambda.1se")

test_results <- tibble(
  model  = c("ridge", "lasso"),
  rmse   = c(rmse(pr_r, y_te), rmse(pr_l, y_te)),
  n_terms = c(sum(coef(cv_ridge, s = "lambda.min") != 0),
              sum(coef(cv_lasso, s = "lambda.1se") != 0))
)
test_results |>
  mutate(rmse = round(rmse, 1)) |>
  kable(align = "lrr")

# The two are usually close on RMSE, but LASSO reaches it with a fraction
# of the predictors -> it wins on interpretability. On genuinely sparse
# problems LASSO also tends to predict better.


# --------------------------------------------------------------------
# EXERCISE · ELASTIC NET (alpha = 0.5)
# --------------------------------------------------------------------
# alpha between 0 and 1 blends L2 and L1 penalties. The L2 part lets
# correlated predictors (spend / orders / basket) enter as a group,
# while the L1 part still prunes the noise. This is the "your turn"
# exercise from the slides:
#   (a) Fit an elastic net with alpha = 0.5 via cv.glmnet.
#   (b) How many predictors does it keep at lambda.1se vs pure LASSO?
#   (c) Which method would you report to a marketing team, and why?
set.seed(312)
cv_en <- cv.glmnet(x_tr, y_tr, alpha = 0.5, nfolds = 10)

n_en   <- sum(coef(cv_en, s = "lambda.1se") != 0)

cat("Elastic net (lambda.1se) terms:", n_en, "\n")
cat("LASSO      (lambda.1se) terms:", n_1se, "\n")

# Elastic net typically keeps a FEW MORE than LASSO because correlated
# predictors slip in together rather than one being dropped.

# (c) For a marketing team, report the SPARSEST model whose test RMSE is
# within one SE of the best (usually LASSO or elastic net at lambda.1se):
# a short, interpretable driver list is actionable. Confirm on test data:
pr_en <- predict(cv_en, x_te, s = "lambda.1se")
tibble(
  model  = c("ridge", "lasso", "elastic_net"),
  rmse   = c(rmse(pr_r, y_te), rmse(pr_l, y_te), rmse(pr_en, y_te)),
  n_terms = c(sum(coef(cv_ridge, s = "lambda.min") != 0),
              n_1se, n_en)
) |>
  mutate(rmse = round(rmse, 1)) |>
  kable(align = "lrr")
