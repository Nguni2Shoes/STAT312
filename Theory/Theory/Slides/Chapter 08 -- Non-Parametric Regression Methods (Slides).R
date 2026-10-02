## ============================================================================
## ============================================================================

##                                Slides: 
##                  Non-Parametric Regression Methods
##                       STAT312 Learning Unit 8
##                    Dr Stéfan Janse van Rensburg
##                Department of Statistics Faculty of Science
##                                 2026

## ============================================================================
## ============================================================================

# Today's objectives
# By the end of this unit you should be able to:
# • Say why non-parametric regression relaxes a fixed form for f
# • Write the k-NN regression estimator as a local average
# • State the four kernel properties and name common kernels
# • Read the Nadaraya-Watson estimator as a kernel-weighted average
# • Tune the smoothing parameter (k or bandwidth h) by cross-validation

# ============================================================================

# Why Go Non-Parametric

# When linearity fails
# Parametric regression fixes the shape, e.g. f(x) = beta_0 + beta_1 * x. When
# the truth is curved or periodic, that assumption bakes in bias.
# Non-parametric regression lets the data speak - its only
# assumption is local smoothness: nearby x should give similar y.
# • The goal is unchanged: estimate E[Y|X=x] = f(x)
# • f may take any shape the data support
# • We pay for flexibility with larger samples and more compute

# Figure: Non-Parametric Model Comparison on Simulated Sine Wave Data
# Predictor x (0.0 to 10.0) vs Response y (-2 to 3) with scatter points (grey dots):
# - k-NN (k = 5): step-like red line following the periodic trend
# - Nadaraya-Watson (h = 0.5): smooth green curve tracking the periodic trend
# The k-NN fit is step-like; Nadaraya-Watson is smooth - same data, same idea.

# ============================================================================

# k-NN Regression

# A prediction is a local average
# For a target x0, average the responses of its k nearest training points:
#
#   ^f(x_0) = (1/k) * sum_(i in N_k(x_0)) y_i
#
# where N_k(x_0) indexes the k neighbours under a distance metric. For
# continuous predictors the standard choice is the Euclidean distance:
#
#   d(x_i, x_0) = sqrt(sum_(j=1->p) (x_ij - x_0j)^2)

# ----------------------------------------------------------------------------

# Choosing k: the smoothing lever
# • Small k (1-3): low bias, high variance - risk of overfitting
# • Large k: higher bias, lower variance - risk of oversmoothing
# • Pick k by cross-validation - the k that minimises validation error

# ----------------------------------------------------------------------------

# k-NN in R
library(caret)
library(rsample)

split <- initial_split(example_data, prop = 0.8)
train <- training(split)
test  <- testing(split)

knn_fit <- knnreg(y ~ x, data = train, k = 5)
preds   <- predict(knn_fit, newdata = test)
sqrt(mean((test$y - preds)^2)) # test RMSE

# [1] 0.5853467

# Figure: k-NN CV RMSE curve vs k (neighbourhood size)
# X-axis: k (neighbourhood size) from 1 to 20
# Y-axis: CV RMSE (ranging from ~0.53 to ~0.81)
# Dashed vertical line marks the minimum at k = 3
# The CV curve dips then rises; here the minimum sits at k = 3.

# ============================================================================

# Kernels

# What a kernel must satisfy
# A kernel K(u) weights points by scaled distance, obeying four properties:
#
# #   Property                  Meaning
# 1   K(u) >= 0                 non-negative weights
# 2   integral K(u) du = 1      integrates to one
# 3   K(u) = K(-u)              symmetric (direction ignored)
# 4   integral u * K(u) du = 0  zero first moment

# ----------------------------------------------------------------------------

# Figure: Comparison of Common Kernel Functions
# X-axis: u (scaled distance) from -3 to 3
# Y-axis: K(u)
# - Gaussian (dark line): peak at ~0.40, bell-shaped, tails extend indefinitely
# - Tricube (green curve): peak at ~0.86, compact support on [-1, 1]
# - Uniform (orange box): flat height 0.50 on [-1, 1], zero elsewhere
# Gaussian never reaches zero; Uniform and Tricube have compact support.

# ----------------------------------------------------------------------------

# Kernel density estimation
# KDE estimates a density by placing a scaled kernel on each point:
#
#   ^f(x) = (1 / (n * h)) * sum_(i=1->n) K((x - x_i) / h)
#
# The bandwidth h > 0 controls smoothness:
# • Small h -> low bias, high variance (undersmoothing)
# • Large h -> higher bias, low variance (oversmoothing)
# Gaussian rule-of-thumb: h = 1.06 * ^sigma * n^(-1/5).

# ============================================================================

# Nadaraya-Watson

# A kernel-weighted average
# Putting KDEs into the conditional mean gives a weighted average -
# every point contributes, but close ones dominate:
#
#   ^f(x) = (sum_i K((x - X_i) / h) * Y_i) / (sum_j K((x - X_j) / h)) = sum_i w_i * Y_i
#   where sum_i w_i = 1

# ----------------------------------------------------------------------------

# Bandwidth: the k of kernel methods
# • Small h: low bias, high variance - rough fit
# • Large h: high bias, low variance - flat fit
# • Choose h by cross-validation, exactly as for k

# ----------------------------------------------------------------------------

# Nadaraya-Watson in R
# nadaraya_watson(x_tr, y_tr, x_pred, h): Gaussian-weighted local mean
nw_preds <- nadaraya_watson(train$x, train$y, test$x, h = 0.5)
sqrt(mean((test$y - nw_preds)^2)) # test RMSE

# [1] 0.5642183

# Figure: Nadaraya-Watson CV RMSE vs bandwidth h
# X-axis: bandwidth h (0.1 to 2.0)
# Y-axis: CV RMSE (ranging from ~0.53 to ~1.22)
# Dashed vertical line marks the minimum at h = 0.2
# The smooth U-shape selects h = 0.2 here - too small wiggles, too large flattens.

# ============================================================================

# Comparing the Methods

# k-NN vs Nadaraya-Watson
#
# Aspect        k-NN regression             Nadaraya-Watson
# Weighting     k neighbours, equal         all points, kernel-weighted
# Fitted curve  step-like                   smooth
# Tuning knob   k (integer)                 bandwidth h > 0
# Weakness      jumpy at gaps               boundary & sparse bias
# Best for      small, discrete data        smooth, theory-backed fits

# ----------------------------------------------------------------------------

# Performance on the test set
tibble(
  Method = c("k-NN", "Nadaraya-Watson"),
  RMSE = c(rmse(predict(final_knn, test)),
           rmse(final_nw))
) |>
  knitr::kable()

# Method              RMSE
# k-NN                0.615
# Nadaraya-Watson     0.536

# Both track the signal closely; the smoother fit edges ahead here.

# ============================================================================

# Summary

# Key takeaways
# 1. Non-parametric regression estimates E[Y|X=x] without fixing f's shape
# 2. k-NN averages the k nearest responses - one knob, k
# 3. A valid kernel is a symmetric density: smooth, normalised distance weights
# 4. Nadaraya-Watson is the kernel-weighted average from KDE in the conditional mean
# 5. Bandwidth h and neighbourhood k are smoothing parameters tuned by CV
```[cite: 89, 90, 91, 92, 94, 95, 96, 97, 99, 100, 101, 103, 104, 105, 106, 108, 109, 111]