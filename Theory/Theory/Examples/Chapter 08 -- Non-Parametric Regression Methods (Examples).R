## ============================================================================
## ============================================================================

##                          Worked Examples & Exercises: 
##                 STAT312 Learning Unit 8 - Non-Parametric Regression
##                    Dr Stéfan Janse van Rensburg
##                Department of Statistics Faculty of Science
##                                 2026

## ============================================================================
## ============================================================================

# How to use these
# • Each example states a problem - try it before the reveal
# • Worked solutions appear in the lecturer copy (the amber boxes)
# • Code is real and runs against the course datasets

# ============================================================================

# Example 1 · Fit k-NN regression

# A wavy signal
# tr/te split y = 2 * sin(x) + epsilon (80/20). Fit k-NN, report test RMSE.
library(caret)
library(rsample)
library(tidyverse)

fit <- knnreg(y ~ x, data = tr, k = 5)
preds <- predict(fit, newdata = te)
sqrt(mean((te$y - preds)^2)) # test RMSE

# [1] 0.5853467

# ============================================================================

# Example 2 · Tune k by cross-validation

# Search the grid
# cv_knn(k, split) returns one fold's RMSE. Average over folds and
# pick the best k:
res <- map_dfr(1:20, \(k)
               tibble(k = k, rmse = mean(map_dbl(folds$splits, cv_knn, k = k))))

res$k[which.min(res$rmse)] # optimal k

# [1] 3

# ----------------------------------------------------------------------------

# The CV curve
# The validation RMSE traces a U in k:

# Figure: k-NN CV RMSE curve vs k
# X-axis: k from 1 to 20
# Y-axis: CV RMSE (ranging from ~0.53 to ~0.81)
# Dashed vertical line marks the minimum at k = 3

# ============================================================================

# Example 3 · Nadaraya-Watson smoother

# Smooth instead of step
# Fit the N-W smoother (h = 0.5); report test RMSE.
nw_preds <- nadaraya_watson(tr$x, tr$y, te$x, h = 0.5)
sqrt(mean((te$y - nw_preds)^2)) # test RMSE

# [1] 0.5642183

# ============================================================================

# Example 4 · Tune the bandwidth h

# Grid-search h
# nw_cv(h, split) mirrors cv_knn for the smoother. Search h in [0.1, 2.0]:
bw <- map_dfr(seq(0.1, 2, 0.1),
              \(h) tibble(h = h, rmse = mean(map_dbl(folds$splits, nw_cv, h = h))))

bw$h[which.min(bw$rmse)] # optimal h

# [1] 0.2

# ----------------------------------------------------------------------------

# k-NN vs N-W head to head
# Method                  RMSE
# k-NN (CV k)             0.615
# Nadaraya-Watson (CV h)  0.536

# ============================================================================

# Example 5 · Real data: car_data

# Smoothing mpg on weight
# Fit a Nadaraya-Watson smoother of mpg on wt and overlay it on the scatter.
cars <- readr::read_csv("../Class Notes 2026/car_data.csv",
                        show_col_types = FALSE)

g <- seq(min(cars$wt), max(cars$wt), length.out = 200)
cars_smooth <- tibble(
  wt  = g,
  mpg = nadaraya_watson(cars$wt, cars$mpg, g, h = 0.5)
)

# Figure: Scatter plot of wt vs mpg with Nadaraya-Watson smooth line
# X-axis: weight (1000 lbs) from ~1.5 to ~5.5
# Y-axis: mpg from 10 to 35
# Shows negative, non-linear downward trend captured by a smooth curve (red line)

# ============================================================================

# Your turn

# Exercise
# Using car_data, model mpg as a function of horsepower (hp).
# (a) Fit k-NN regression with k = 5 and report the training RMSE.
# (b) Why is training RMSE an optimistic estimate of test error for k-
#     NN, and what would you do instead?

# Answer

# (a) Code to fit k-NN on training data and compute training RMSE:
# fit_hp <- knnreg(mpg ~ hp, data = cars, k = 5)
# preds_train <- predict(fit_hp, newdata = cars)
# train_rmse <- sqrt(mean((cars$mpg - preds_train)^2))
# train_rmse

# (b) Why training RMSE is overly optimistic:
# For k-NN regression, each training point's prediction includes itself 
# (or its nearest identical/close neighbours in the training set), which artificially 
# suppresses residual error and ignores generalization error to unseen observations. 
# For very small k (especially k = 1), the training RMSE approaches 0.
# Instead, evaluate using a held-out test set or k-fold cross-validation 
# (e.g. using rsample::vfold_cv) to obtain an honest estimate of prediction error.
```[cite: 156, 157, 159, 161, 162, 164, 166, 167, 169, 170, 171]