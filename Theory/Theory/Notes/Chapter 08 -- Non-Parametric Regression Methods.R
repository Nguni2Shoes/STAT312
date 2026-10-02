# =============================================================================
# =============================================================================

#                               Notes:
#                  Non-Parametric Regression Methods
#                       Chapter 8 Class Notes
#                    Dr Stéfan Janse van Rensburg
#                                2026

# =============================================================================
# =============================================================================

# Contents
# Introduction
# Required Packages
# 1 k-Nearest Neighbours Regression
# 1.1 Conceptual Framework
# 1.2 Mathematical Formulation
# 1.3 Parameter Selection
# 1.4 Implementation in R
# 1.5 Optimal k Selection
# 2 Kernel Functions
# 2.1 Definition and Purpose
# 2.2 Common Kernel Functions
# 3 Kernel Density Estimation
# 3.1 Theoretical Foundation
# 3.2 Bandwidth Selection
# 4 Nadaraya-Watson Regression
# 4.1 Theoretical Development
# 4.1.1 Connection to Kernel Density Estimation
# 4.1.2 Mathematical Derivation
# 4.1.3 Final Nadaraya-Watson Estimator
# 4.2 Implementation in R
# 4.3 Bandwidth Selection Using Cross-Validation
# 5 Comparative Analysis
# 5.1 Method Characteristics
# 5.2 Performance Considerations
# 5.3 Model Comparison Example
# Summary

# =============================================================================

# Introduction

# This chapter explores non-parametric regression methods that make minimal assumptions
# about the underlying functional relationship between predictor and response variables. Unlike
# parametric approaches that assume specific functional forms, non-parametric methods derive
# predictions directly from the data structure.

# The fundamental goal of regression analysis remains estimating the conditional expectation
# E[Y|X=x] = f(x), where f(·) represents an unknown function. Whilst parametric meth-
# ods assume f follows a predetermined structure (linear, polynomial, etc.), non-parametric
# approaches allow f to assume any form supported by the data.

# These methods prove particularly valuable when the true relationship between variables
# exhibits complex patterns that resist parametric characterisation. However, this flexibility
# requires larger sample sizes and increased computational resources compared to parametric
# alternatives.

# Key non-parametric regression approaches include:
# • k-Nearest Neighbours (k-NN) regression: Predictions based on averaging response values
#   from the k most similar observations
# • Nadaraya-Watson regression: Kernel-weighted local averaging that provides smooth func-
#   tion estimates

# Mathematical Prerequisites
# This chapter assumes familiarity with probability theory, basic calculus, and statistical
# estimation concepts. Students should understand conditional expectations, probability
# density functions, and integration techniques.

# =============================================================================

# Required Packages

library(tidyverse) # Data manipulation and visualisation
library(caret)     # For knnreg() function
library(rsample)   # Modern resampling and cross-validation
library(yardstick) # Model performance metrics
library(knitr)     # Table formatting

# =============================================================================

# 1 k-Nearest Neighbours Regression

# 1.1 Conceptual Framework
# Definition: k-Nearest Neighbours regression predicts response values by identifying the k
# training observations with predictor values most similar to the target observation, then aver-
# aging their corresponding response values.

# The method embodies the principle that observations with similar predictor characteristics
# should exhibit similar response values. This assumption, known as local smoothness, underlies
# most non-parametric approaches.

# 1.2 Mathematical Formulation
# Let (x_i, y_i) for i = 1, 2, ..., n represent the training dataset. For a new observation with predictor
# value x_0, the k-NN regression prediction follows:

#   ^f(x_0) = (1/k) * sum_(i in N_k(x_0)) y_i

# where N_k(x_0) denotes the set of indices corresponding to the k nearest neighbours of x_0 based
# on distance metric d(x_i, x_0).

# For continuous predictors, Euclidean distance provides the standard metric:

#   d(x_i, x_0) = sqrt(sum_(j=1->p) (x_ij - x_0j)^2)

# 1.3 Parameter Selection
# The choice of k critically influences model performance through the bias-variance trade-off:
# • Small k values (k = 1, 2, 3): Low bias but high variance, potentially overfitting to training data
# • Large k values: Higher bias but lower variance, potentially undersmoothing the relationship

# Optimal k selection typically employs cross-validation procedures that minimise prediction
# error on validation datasets.

# =============================================================================

# 1.4 Implementation in R

# Generate example dataset for demonstration
set.seed(2025)
n <- 100
x <- runif(n, 0, 10)
y <- 2 * sin(x) + rnorm(n, 0, 0.5)
example_data <- data.frame(x = x, y = y)

# Create training-test split using rsample
data_split <- initial_split(example_data, prop = 0.8)
training_set <- training(data_split)
test_set <- testing(data_split)

# Fit k-NN model with k = 5
knn_model <- knnreg(y ~ x, data = training_set, k = 5)

# Generate predictions
predictions <- predict(knn_model, newdata = test_set)

# Calculate test MSE
test_mse <- mean((test_set$y - predictions)^2)
print(paste("Test MSE:", round(test_mse, 4)))

# [1] "Test MSE: 0.3426"

# =============================================================================

# 1.5 Optimal k Selection

# Create cross-validation folds
cv_folds <- vfold_cv(training_set, v = 5)

# Define k values to evaluate
k_values <- 1:20

# Function to fit kNN and calculate RMSE
evaluate_knn <- function(k_val, splits) {
  # Extract training and assessment sets
  train_data <- analysis(splits)
  assess_data <- assessment(splits)
  
  # Fit model
  model <- knnreg(y ~ x, data = train_data, k = k_val)
  
  # Make predictions
  preds <- predict(model, newdata = assess_data)
  
  # Calculate RMSE
  rmse_val <- sqrt(mean((assess_data$y - preds)^2))
  return(rmse_val)
}

# Perform cross-validation for each k
cv_results <- do.call(rbind, lapply(k_values, function(k) {
  rmse_scores <- sapply(
    cv_folds$splits, function(split) evaluate_knn(k, split))
  data.frame(
    k = k,
    mean_rmse = mean(rmse_scores),
    se_rmse = sd(rmse_scores) / sqrt(length(rmse_scores))
  )
}))

# Visualise results
ggplot(cv_results, aes(x = k, y = mean_rmse)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_rmse - se_rmse,
                    ymax = mean_rmse + se_rmse),
                width = 0.2) +
  theme_bw() +
  labs(title = "k-NN Cross-Validation Results",
       x = "Number of Neighbours (k)",
       y = "Mean RMSE") +
  scale_x_continuous(breaks = seq(1, 20, by = 2))

# Figure: k-NN Cross-Validation Results
# Line plot with error bars showing Mean RMSE vs Number of Neighbours (k).
# The curve dips to its lowest point at k = 3 (~0.53) before steadily climbing upward as k reaches 20 (~0.81).

# Identify optimal k
optimal_k <- cv_results$k[which.min(cv_results$mean_rmse)]
print(paste("Optimal k:", optimal_k))

# [1] "Optimal k: 3"

# =============================================================================

# 2 Kernel Functions

# 2.1 Definition and Purpose
# Kernel functions provide systematic weighting schemes for observations based on their
# distance from target points. These functions enable smooth transitions between nearby
# and distant observations, forming the mathematical foundation for kernel-based estimation
# methods.

# Formal Definition: A kernel function K(u) satisfies:
# 1. K(u) >= 0 for all u (non-negativity)
# 2. integral_(-Inf->Inf) K(u) du = 1 (integration to unity)
# 3. K(u) = K(-u) (symmetry)
# 4. integral_(-Inf->Inf) u * K(u) du = 0 (zero first moment)

# 2.2 Common Kernel Functions

# Gaussian (Normal) Kernel:
#   K(u) = (1 / sqrt(2 * pi)) * exp(-u^2 / 2)
# The Gaussian kernel provides smooth, bell-shaped weights that decrease exponentially with
# distance.

# Uniform (Rectangular) Kernel:
#   K(u) = 1/2 if |u| <= 1, 0 otherwise

# Tricube Kernel:
#   K(u) = (70/81) * (1 - |u|^3)^3 if |u| <= 1, 0 otherwise

# Create visualisation of kernel functions
x <- seq(-3, 3, by = 0.01)

# Define kernel functions
gaussian_kernel <- function(u) dnorm(u)
uniform_kernel <- function(u) ifelse(abs(u) <= 1, 0.5, 0)
tricube_kernel <- function(u) ifelse(abs(u) <= 1, (70/81) * (1 - abs(u)^3)^3, 0)

# Create comparison dataset
kernel_data <- tibble(
  u = rep(x, 3),
  K_u = c(gaussian_kernel(x), uniform_kernel(x), tricube_kernel(x)),
  Kernel = rep(c("Gaussian", "Uniform", "Tricube"), each = length(x))
)

# Generate plot
ggplot(kernel_data, aes(x = u, y = K_u, colour = Kernel)) +
  geom_line(linewidth = 2) +
  theme_bw() +
  labs(title = "Kernel Function Comparison",
       x = "u", y = "K(u)") +
  theme(legend.position = "bottom") +
  scale_colour_manual(values = c(
    "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3",
    "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3"))

# Figure: Kernel Function Comparison
# Comparison plot showing K(u) vs u (-3 to 3):
# - Gaussian: Broad smooth bell curve peaking at ~0.40
# - Tricube: Steeper bell curve with finite support on [-1, 1], peaking at ~0.86
# - Uniform: Flat box curve with height 0.50 on [-1, 1] and 0 elsewhere

# =============================================================================

# 3 Kernel Density Estimation

# 3.1 Theoretical Foundation
# Kernel Density Estimation (KDE) provides non-parametric probability density function esti-
# mation. Given observations x_1, x_2, ..., x_n the KDE estimator approximates the underlying
# density f(x) through:

#   ^f(x) = (1 / (n * h)) * sum_(i=1->n) K((x - x_i) / h)

# where h > 0 represents the bandwidth parameter controlling estimation smoothness.

# 3.2 Bandwidth Selection
# The bandwidth h governs the bias-variance trade-off in density estimation:
# • Small bandwidth: Low bias but high variance (undersmoothing)
# • Large bandwidth: Higher bias but lower variance (oversmoothing)

# Rule-of-thumb bandwidth for Gaussian kernels:
#   h = 1.06 * sigma * n^(-1/5)
# where sigma denotes the sample standard deviation.

# =============================================================================

# 4 Nadaraya-Watson Regression

# 4.1 Theoretical Development
# The Nadaraya-Watson estimator represents a sophisticated kernel-weighted regression ap-
# proach that provides smooth function estimates. Unlike k-NN regression's discrete neighbour
# selection, this method assigns continuous weights to all observations based on their proximity
# to the target point.

# 4.1.1 Connection to Kernel Density Estimation
# The derivation begins with the fundamental regression relationship:

#   E[Y|X=x] = (integral_(-Inf->Inf) y * p_(X,Y)(x, y) dy) / p_X(x)

# Using kernel density estimation to approximate the joint and marginal densities:

#   ^p_(X,Y)(x, y) = (1 / (n * h^2)) * sum_(i=1->n) K((x - X_i) / h) * K((y - Y_i) / h)
#   ^p_X(x) = (1 / (n * h)) * sum_(i=1->n) K((x - X_i) / h)

# 4.1.2 Mathematical Derivation
# The conditional expectation becomes:

#   E[Y|X=x] ≈ (integral_(-Inf->Inf) y * ^p_(X,Y)(x, y) dy) / ^p_X(x)

# Substituting the kernel density estimates:

#   E[Y|X=x] ≈ (sum_(i=1->n) K((x - X_i) / h) * integral_(-Inf->Inf) y * K((y - Y_i) / h) dy / h) /
#              (sum_(j=1->n) K((x - X_j) / h))

# Key integral evaluation:
#   integral_(-Inf->Inf) y * K((y - Y_i) / h) dy = h * Y_i

# This follows from the substitution u = h^(-1) * (y - Y_i) and the kernel properties:
#   integral_(-Inf->Inf) (h * u + Y_i) * K(u) * h du = h^2 * integral_(-Inf->Inf) u * K(u) du + h * Y_i * integral_(-Inf->Inf) K(u) du = h * Y_i
# since integral_(-Inf->Inf) u * K(u) du = 0 and integral_(-Inf->Inf) K(u) du = 1.

# 4.1.3 Final Nadaraya-Watson Estimator
#   ^f(x) = (sum_(i=1->n) K((x - X_i) / h) * Y_i) / (sum_(j=1->n) K((x - X_j) / h)) = sum_(i=1->n) w_i * Y_i

# where the weights are:
#   w_i = K((x - X_i) / h) / sum_(j=1->n) K((x - X_j) / h)

# Note that sum_(i=1->n) w_i = 1, ensuring the estimator represents a weighted average.

# =============================================================================

# 4.2 Implementation in R

# Nadaraya-Watson regression function
# Note: Reusing kernel functions defined in the kernel
# visualisation section
nadaraya_watson <- function(x_train, y_train, x_pred, bandwidth,
                            kernel = "gaussian") {
  # Reuse previously defined kernel functions for consistency
  K <- switch(kernel,
              "gaussian" = gaussian_kernel,
              "uniform" = uniform_kernel,
              "tricube" = tricube_kernel
  )
  
  predictions <- numeric(length(x_pred))
  
  for (j in seq_along(x_pred)) {
    # Calculate standardised distances
    distances <- (x_pred[j] - x_train) / bandwidth
    weights <- K(distances)
    
    # Nadaraya-Watson estimate
    if (sum(weights) > 0) {
      predictions[j] <- sum(weights * y_train) / sum(weights)
    } else {
      predictions[j] <- mean(y_train) # Fallback for zero weights
    }
  }
  return(predictions)
}

# Example implementation
x_train <- training_set$x
y_train <- training_set$y
x_test <- test_set$x

# Fit with Gaussian kernel and bandwidth = 0.5
nw_predictions <- nadaraya_watson(
  x_train, y_train, x_test,
  bandwidth = 0.5, kernel = "gaussian")

# Calculate test MSE
nw_mse <- mean((test_set$y - nw_predictions)^2)
print(paste("Nadaraya-Watson MSE:", round(nw_mse, 4)))

# [1] "Nadaraya-Watson MSE: 0.3183"

# =============================================================================

# 4.3 Bandwidth Selection Using Cross-Validation

# Function to evaluate Nadaraya-Watson with specific bandwidth
evaluate_nw <- function(bandwidth, splits) {
  train_data <- analysis(splits)
  assess_data <- assessment(splits)
  
  predictions <- nadaraya_watson(
    x_train = train_data$x,
    y_train = train_data$y,
    x_pred = assess_data$x,
    bandwidth = bandwidth,
    kernel = "gaussian"
  )
  
  rmse_val <- sqrt(mean((assess_data$y - predictions)^2))
  return(rmse_val)
}

# Define bandwidth range
bandwidths <- seq(0.1, 2.0, by = 0.1)

# Perform cross-validation
nw_cv_results <- do.call(rbind, lapply(bandwidths, function(h) {
  rmse_scores <- sapply(cv_folds$splits, function(split) evaluate_nw(h, split))
  data.frame(
    bandwidth = h,
    mean_rmse = mean(rmse_scores),
    se_rmse = sd(rmse_scores) / sqrt(length(rmse_scores))
  )
}))

# Find optimal bandwidth
optimal_h <- nw_cv_results$bandwidth[
  which.min(nw_cv_results$mean_rmse)
]

# Visualise bandwidth selection
ggplot(nw_cv_results, aes(x = bandwidth, y = mean_rmse)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_rmse - se_rmse,
                    ymax = mean_rmse + se_rmse),
                width = 0.05) +
  geom_vline(
    xintercept = optimal_h,
    linetype = "dashed",
    colour = "red") +
  theme_bw() +
  labs(
    title = "Nadaraya-Watson Cross-Validation Results",
    x = "Bandwidth (h)",
    y = "Mean RMSE") +
  annotate(
    "text", x = optimal_h + 0.3,
    y = max(nw_cv_results$mean_rmse) * 0.95,
    label = paste("Optimal h =", round(optimal_h, 2)))

# Figure: Nadaraya-Watson Cross-Validation Results
# Plot showing Mean RMSE vs Bandwidth (h) with error bars.
# Optimal dashed vertical line at h = 0.2 (Mean RMSE ~ 0.53); RMSE sharply increases as bandwidth expands to 2.0 (~1.22).

print(paste("Optimal bandwidth:", round(optimal_h, 3)))

# [1] "Optimal bandwidth: 0.2"

# =============================================================================

# 5 Comparative Analysis

# 5.1 Method Characteristics

# The following table summarises key characteristics of non-parametric regression methods:

# k-NN Regression
# • Advantages: Simple implementation; No distributional assumptions; Effective for discrete
#   patterns
# • Disadvantages: Sensitive to k selection; Non-smooth predictions; Computationally intensive
#   for large datasets

# Nadaraya-Watson Regression
# • Advantages: Smooth function estimates; Flexible kernel choices; Sound theoretical founda-
#   tion
# • Disadvantages: Critical bandwidth selection; Boundary effects; Requires larger sample sizes

# 5.2 Performance Considerations

# Computational Efficiency
# k-NN regression becomes substantially slower with larger datasets because the algorithm
# calculates distances to every training observation for each prediction. Nadaraya-Watson
# regression processes observations more efficiently, making it preferable for large datasets or
# frequent predictions.

# Sample Size Requirements
# Both methods require larger samples than parametric approaches. Nadaraya-Watson regres-
# sion proves particularly sensitive to sparse data regions where kernel weights become
# negligible.

# Implementation Guidelines
# Select k-NN regression for smaller datasets with discrete relationships. Apply Nadaraya-Wat-
# son regression when smooth function estimates are essential and computational efficiency
# matters. Consider dataset size and available computational resources when choosing between
# methods.

# Sparse Data Regions
# Sparse data regions refer to areas within the predictor variable range where few or no
# training observations exist. For example, if most training data clusters around x-values
# of 2-4 and 8-10, the region between 5-7 represents a sparse area. In Nadaraya-
# Watson regression, predictions in sparse regions become unreliable because nearby
# kernel weights approach zero, forcing the algorithm to rely on distant observations that
# contribute minimal information. This creates unstable estimates with high uncertainty,
# particularly problematic near data boundaries or gaps in the training set.

# =============================================================================

# 5.3 Model Comparison Example

# Compare both methods on test set
final_knn <- knnreg(y ~ x, data = training_set, k = optimal_k)
knn_test_preds <- predict(final_knn, newdata = test_set)

nw_test_preds <- nadaraya_watson(
  x_train = training_set$x,
  y_train = training_set$y,
  x_pred = test_set$x,
  bandwidth = optimal_h,
  kernel = "gaussian"
)

# Calculate performance metrics
comparison_results <- tibble(
  Method = c("k-NN", "Nadaraya-Watson"),
  RMSE = c(
    sqrt(mean((test_set$y - knn_test_preds)^2)),
    sqrt(mean((test_set$y - nw_test_preds)^2))
  ),
  MAE = c(
    mean(abs(test_set$y - knn_test_preds)),
    mean(abs(test_set$y - nw_test_preds))
  )
)

knitr::kable(comparison_results,
             caption = "Performance Comparison on Test Set",
             digits = 3)

# Table: Performance Comparison on Test Set
# Method              RMSE    MAE
# k-NN                0.615   0.527
# Nadaraya-Watson     0.536   0.422

# Visualising Smooth Function Estimates

# Create dense prediction grid for smooth visualisation
x_grid <- seq(min(example_data$x), max(example_data$x),
              length.out = 200)

# Generate predictions using optimal parameters
final_knn <- knnreg(y ~ x, data = training_set, k = optimal_k)
knn_smooth <- predict(final_knn, newdata = data.frame(x = x_grid))

nw_smooth <- nadaraya_watson(
  x_train = training_set$x,
  y_train = training_set$y,
  x_pred = x_grid,
  bandwidth = optimal_h,
  kernel = "gaussian"
)

# True underlying function for comparison
true_function <- 2 * sin(x_grid)

# Create comprehensive comparison plot
plot_data <- tibble(
  x = rep(x_grid, 3),
  y = c(knn_smooth, nw_smooth, true_function),
  Method = rep(c("k-NN", "Nadaraya-Watson", "True Function"),
               each = length(x_grid))
)

ggplot() +
  # Plot training data
  geom_point(
    data = training_set, aes(x = x, y = y),
    alpha = 0.6, size = 1.5) +
  # Plot smooth estimates
  geom_line(
    data = plot_data, aes(
      x = x, y = y, colour = Method,
      linetype = Method),
    linewidth = 1.2) +
  theme_bw() +
  labs(
    title = "Non-Parametric Regression Function Estimates",
    subtitle = paste(
      "k-NN ( k =", optimal_k, ") vs Nadaraya-Watson ( h =",
      round(optimal_h, 2), " )"),
    x = "Predictor (x)", y = "Response (y)"
  ) +
  theme(legend.position = "bottom") +
  scale_colour_manual(values = c(
    "#66C2A5", "#FC8D62",
    "#8DA0CB", "#E78AC3",
    "#A6D854", "#FFD92F",
    "#E5C494", "#B3B3B3"))

# Figure: Non-Parametric Regression Function Estimates
# Plot showing actual training points along with:
# - True Function (smooth dashed sinusoid)
# - Nadaraya-Watson (h = 0.2, closely tracks the curve with continuous smooth transitions)
# - k-NN (k = 3, displays distinctive step-wise/piecewise constant jumps)

# =============================================================================

# Summary

# Non-parametric regression methods provide powerful alternatives to parametric approaches
# when functional relationships resist predetermined specification. k-Nearest neighbours
# regression offers computational simplicity with robust performance across diverse applica-
# tions, whilst Nadaraya-Watson regression delivers smooth, theoretically grounded estimates
# through sophisticated kernel weighting schemes.

# Success with these methods depends critically on appropriate parameter selection through
# rigorous cross-validation procedures. The choice between methods should consider compu-
# tational constraints, desired smoothness characteristics, and underlying data structure. These
# approaches prove particularly valuable in exploratory data analysis and situations where
# predictive accuracy takes precedence over model interpretability. However, practitioners must
# remain cognisant of increased data requirements and computational demands compared to
# parametric alternatives.

# The integration of modern resampling techniques through the rsample package provides
# robust frameworks for parameter optimisation and performance assessment, ensuring reliable
# implementation of these sophisticated statistical methods.
```[cite: 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]