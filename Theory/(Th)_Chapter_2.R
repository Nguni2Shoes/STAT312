# =============================================================================
# =============================================================================

#                               Notes:
#               Resampling Techniques for Model Validation

# =============================================================================
# =============================================================================

# Contents
# 1 Introduction to Model Validation
# 2 The Bias-Variance Decomposition
# 3 The Holdout Method
# 3.1 Theoretical Properties
# 3.2 Optimal Split Proportions
# 4 K-Fold Cross-Validation
# 4.1 Mathematical Formulation
# 4.2 Statistical Properties
# 4.3 Stratified Cross-Validation
# 5 Leave-One-Out Cross-Validation
# 5.1 Theoretical Advantages
# 5.2 Computational Considerations 
# 5.3 When to Use LOOCV
# 6 Advanced Resampling Considerations (NOT EXAMINABLE)
# 6.1 Nested Cross-Validation
# 6.2 Time Series Considerations
# 6.3 Computational Efficiency
# 7 Practical Guidelines for Method Selection
# 7.1 Dataset Size Considerations
# 7.2 Computational Constraints
# 7.3 Model Complexity
# 8 Conclusion

# ============================================================================

# 1 Introduction to Model Validation
# Statistical learning algorithms construct predictive models by approximating unknown func­
# tions from finite training samples. The fundamental challenge lies in estimating how these
# models will perform on future, unseen data, a property known as generalisation ability.
# Without proper validation procedures, models may exhibit excellent performance on training
# data whilst failing catastrophically on new observations, a phenomenon termed overfitting.

# The theoretical foundation for model validation rests on the distinction between empirical risk
# (performance on training data) and expected risk (performance on the true data-generating
# distribution). Consider a loss function 𝐿(𝑦, ̂𝑓(𝑥)) measuring prediction errors, where ̂𝑓 repre­
# sents our estimated model. The empirical risk over training data is:

# ̂𝑅emp( ̂𝑓) = 1/𝑛∑𝐿(𝑦𝑖, ̂𝑓(𝑥𝑖))

# whilst the true expected risk over the population distribution is:

# 𝑅( ̂𝑓) = 𝐸_(𝑋,𝑌)[𝐿(𝑌, ̂𝑓(𝑋))]

# Resampling techniques provide computationally efficient methods for estimating the expected
# risk using only the available sample data, enabling principled model selection and performance
# assessment without requiring additional data collection.

# The Generalisation Paradigm
# Think of model development as learning a language from a textbook. A student who
# memorises every sentence in the textbook (overfitting) may score perfectly on textbook
# exercises but struggle with real conversations. Conversely, a student who understands
# underlying grammar rules (good generalisation) performs well on both textbook exercises
# and novel conversations. Resampling techniques test whether our model has learned
# “grammar rules” or simply memorised the “textbook”.

# ============================================================================

# 2 The Bias-Variance Decomposition
# Resampling techniques address the fundamental bias-variance trade-off in statistical learning.
# For any prediction problem, the expected prediction error can be decomposed as:

# 𝐸[(𝑌−̂𝑓(𝑥))^2] = Bias^2[ ̂𝑓(𝑥)] + Var [ ̂𝑓(𝑥)] + 𝜎^2

# Where:
# • Bias represents systematic errors from model assumptions
# • Variance captures sensitivity to training sample variations
# • Irreducible error (𝜎2) stems from inherent noise
# Resampling provides empirical estimates of this decomposition by repeatedly training models
# on different subsets of available data and evaluating performance on held-out portions.

# Selection Bias in Model Evaluation
# If you use the same data to select a model and test its performance, it creates bias
# and makes the results look too good. Proper validation means using separate data for
# picking the model and for the final check. This requires getting more data or using special
# techniques.


# 3 The Holdout Method
# The holdout method represents the simplest resampling approach, partitioning available data
# into disjoint training and testing subsets. Let 𝒟︀= {(𝑥𝑖, 𝑦𝑖)}𝑖=1 ->𝑛
#  denote our dataset. The holdout
# method creates:
# • Training set: 𝒟︀_train ⊂𝒟︀ with | 𝒟︀_train | = ⌊𝛼_𝑛⌋
# • Test set: 𝒟︀_test, which consists of all observations in 𝒟︀ that are not in 𝒟︀_train
# , with | 𝒟︀test | =𝑛 − ⌊𝛼_𝑛⌋
# where 𝛼∈(0, 1) represents the training proportion, typically chosen as 𝛼∈{0.6, 0.7, 0.8}

# ============================================================================

# 3.1 Theoretical Properties
# The holdout estimator of test error is:
#   ̂𝑅holdout =( 1 / | 𝒟︀test | ) *  ∑_ (𝑥𝑖,𝑦𝑖)∈𝒟︀_test  [𝐿(𝑦𝑖, ̂𝑓train(𝑥𝑖)) ]


# This estimator exhibits:
#   • Unbiasedness: 𝐸[ ̂𝑅_holdout] = 𝑅( ̂𝑓) under random partitioning
#   • High variance: Performance depends critically on the specific train/test split
#   • Computational efficiency: Requires training only one model

# Example: Holdout Method Implementation
# We demonstrate the holdout method using a simulated regression dataset:

# Generate synthetic data for demonstration
set.seed(2024)
n <- 1000
x1 <- rnorm(n, 0, 1)
x2 <- rnorm(n, 0, 1)
y <- 2 + 3*x1 - 1.5*x2 + rnorm(n, 0, 0.5)
synthetic_data <- tibble(x1 = x1, x2 = x2,
                         y = y, observation_id = 1:n)
# Modern holdout split using rsample
set.seed(2024)
data_split <- initial_split(synthetic_data, prop = 0.8,
                            strata = NULL)
training_data <- training(data_split)
testing_data <- testing(data_split)
# Display split characteristics
cat("Training observations:", nrow(training_data), "\n")

# Training observations: 800

cat("Testing observations:", nrow(testing_data), "\n")

# Testing observations: 200

cat("Training proportion:", round(
  nrow(training_data) / nrow(synthetic_data), 3), "\n")

# Training proportion: 0.8

# Train model on training set
model_holdout <- lm(y ~ x1 + x2, data = training_data)
# Evaluate on test set
test_predictions <- predict(model_holdout,
                            newdata = testing_data)
test_mse <- mean((testing_data$y - test_predictions)^2)
cat("Test MSE:", round(test_mse, 4), "\n")

# Test MSE: 0.2323

# ============================================================================

# 3.2 Optimal Split Proportions
# The choice of training proportion 𝛼 involves a fundamental trade-off:

# • Large 𝛼: More training data improves model quality but reduces test set size, increasing
#             variance of performance estimates
# • Small 𝛼: Larger test sets provide more precise performance estimates but models trained
#             on less data may not reflect final model quality

# Theoretical analysis suggests optimal proportions depend on the sample size 𝑛 and model
# complexity. For large datasets, 𝛼= 0.8 often provides reasonable balance, whilst smaller
# datasets may benefit from cross-validation approaches.

# ============================================================================

# 4 K-Fold Cross-Validation

#               Fold_1    Fold_2    Fold_3    Fold_4    Fold_5

# Iteration_1   1_test    2_train   3_train   4_train   5_train
# Iteration_2   1_train   2_test    3_train   4_train   5_train   ↓ Average performance across folds
# Iteration_3   1_train   2_train   3_test    4_train   5_train   
# Iteration_4   1_train   2_train   3_train   4_test    5_train
# Iteration_5   1_train   2_train   3_train   4_train   5_test

# Figure 1: Illustration of K-fold cross-validation with K=5. The original dataset is partitioned
# into five equal folds. In each iteration, one fold serves as the test set (blue) whilst the remaining
# four folds form the training set (green). The process repeats for each fold, and the model’s
# overall performance is computed as the average across all five iterations.

# K-fold cross-validation addresses the high variance limitation of holdout validation by aver­
# aging performance estimates across multiple train/test partitions. The procedure, divides data
# into 𝐾 approximately equal folds, then iteratively uses each fold as a test set whilst training on
# the remaining 𝐾−1 folds. The figure above illustrates the K-fold cross-validation procedure
# for 𝐾= 5.

# ============================================================================

# 4.1 Mathematical Formulation
# Let 𝒟︀_𝑘 denote the 𝑘-th fold for 𝑘= 1, …, 𝐾. The cross-validation procedure:

# 1. Partition: 𝒟︀ = ⋃_(𝑘=1->𝐾)𝒟︀_𝑘 with 𝒟︀𝑖∩𝒟︀𝑗= ∅ for 𝑖≠𝑗
# 2. Iterate: For each 𝑘, train on 𝒟︀_-𝑘= 𝒟︀\ 𝒟︀_𝑘 and test on 𝒟︀_𝑘
# 3. Average: Compute ̂𝑅_CV =( 1/𝐾) * ∑_(𝑘=1-> 𝐾) ̂𝑅_𝑘
# where ̂𝑅_𝑘 represents the test error on fold 𝑘.

# ============================================================================

# 4.2 Statistical Properties
# The K-fold CV estimator exhibits:
# • Reduced variance: Averaging across 𝐾 estimates decreases overall variance
# • Bias-variance trade-off: Choice of 𝐾 affects both bias and variance of the estimator
# • Computational cost: Requires training 𝐾 models instead of one

# For the bias-variance decomposition:
# Var [ ̂𝑅_CV] ≈ (1/𝐾)*Var [ ̂𝑅_holdout]

# Common choices include 𝐾∈{5, 10}, with 𝐾= 10 providing good bias-variance balance for
# most applications.

# Example: K-Fold Cross-Validation Implementation

# Create 5-fold cross-validation splits using rsample
set.seed(2024)
cv_folds <- vfold_cv(synthetic_data, v = 5, strata = NULL)
# Function to fit model and compute MSE for each fold
compute_fold_mse <- function(split) {
  # Extract training and testing data for this fold
  train_data <- analysis(split)
  test_data <- assessment(split)
  # Fit model on training data
  model <- lm(y ~ x1 + x2, data = train_data)
  # Predict on test data
  predictions <- predict(model, newdata = test_data)
  # Compute MSE
  mean((test_data$y - predictions)^2)
}
# Apply function to all folds using base R
cv_results <- data.frame(
  id = cv_folds$id,
  mse = sapply(cv_folds$splits, compute_fold_mse)
)

# Example: K-Fold Cross-Validation Implementation

# Display results in a nice table
knitr::kable(cv_results, col.names = c("Fold", "MSE"), digits = 4)

# Fold    MSE
# Fold1   0.2353
# Fold2   0.2174
# Fold3   0.2338
# Fold4   0.2585
# Fold5   0.2624

# Compute overall CV estimate
cv_mse <- mean(cv_results$mse)
cv_se <- sd(cv_results$mse) / sqrt(nrow(cv_results))
cat("Cross-validation MSE:", round(cv_mse, 4), "\n")

# Cross-validation MSE: 0.2415

cat("Standard error:", round(cv_se, 4), "\n")

# Standard error: 0.0084

cat("95% CI:",
    round(cv_mse - 1.96*cv_se, 4), "to",
    round(cv_mse + 1.96*cv_se, 4), "\n")

# 95% CI: 0.2251 to 0.2579

# ============================================================================

# 4.3 Stratified Cross-Validation
# For classification problems or regression with heterogeneous target distributions, stratified
# cross-validation ensures each fold maintains similar target variable distributions. This
# approach:
# 1. Sorts observations by target variable
# 2. Assigns observations to folds in round-robin fashion
# 3. Preserves class proportions (classification) or quantile distributions (regression)
# Stratification reduces variance in performance estimates, particularly for imbalanced datasets
# or skewed target distributions.

# Choosing the Number of Folds
# The choice of 𝐾 represents a bias-variance trade-off. Small 𝐾 (e.g., 𝐾= 5) provides
# higher bias but lower variance estimates, whilst large 𝐾 (e.g., 𝐾= 20) yields lower bias
# but higher variance. The choice depends on dataset size: larger datasets can accommo­
# date higher 𝐾 values, whilst smaller datasets benefit from lower 𝐾 to ensure adequate
# training set sizes.

# ============================================================================

# 5 Leave-One-Out Cross-Validation
# Leave-One-Out Cross-Validation (LOOCV) represents the extreme case where 𝐾= 𝑛, using
# each observation exactly once as a single-point test set. This exhaustive approach provides:

# 𝑅LOOCV = (1/𝑛)*∑_(𝑖=1->𝑛)𝐿(𝑦𝑖, ̂𝑓_−𝑖(𝑥𝑖))

# where ̂𝑓_−𝑖 denotes the model trained on all observations except the 𝑖-th.

# ============================================================================

# 5.1 Theoretical Advantages

# LOOCV offers several theoretical benefits:
# • Deterministic: Results remain identical across repetitions (no randomness in fold assignment)
# • Minimal bias: Training sets contain 𝑛−1 observations, closely approximating the full dataset
# • Exact: No approximation errors from random partitioning

# ============================================================================

# 5.2 Computational Considerations

# Despite theoretical appeal, LOOCV presents significant computational challenges:
# • Training cost: Requires fitting 𝑛 separate models
# • High variance: Individual predictions exhibit high correlation, reducing averaging benefits
# For linear models, efficient LOOCV computation exploits the closed-form solution:

# ^𝑅_LOOCV = (1/𝑛) * ∑_(𝑖=1->n)(𝑦_i −̂𝑦_i /   1 − ℎ_ii)^2

# where ℎ_ii represents the 𝑖-th diagonal element of the hat matrix 𝐇= 𝐗(𝐗′𝐗)^−1𝐗′.

# Example: LOOCV Implementation and Comparison

# LOOCV using rsample
loocv_splits <- loo_cv(synthetic_data)
# Compute LOOCV MSE (showing first 100 folds for brevity)
demo_indices <- 1:100 # Use subset for demonstration
loocv_results <- data.frame(
  id = loocv_splits$id[demo_indices],
  mse = sapply(loocv_splits$splits[demo_indices], compute_fold_mse)
)
loocv_mse_subset <- mean(loocv_results$mse)
# For linear models, use efficient analytical formula
model_full <- lm(y ~ x1 + x2, data = synthetic_data)
hat_values <- hatvalues(model_full)
residuals <- residuals(model_full)
# Analytical LOOCV for linear models
loocv_analytical <- mean((residuals / (1 - hat_values))^2)
# Comparison of methods
comparison_results <- tibble(
  Method = c("Holdout", "5-Fold CV", "LOOCV (Analytical)"),
  MSE = c(test_mse, cv_mse, loocv_analytical),
  `Std Error` = c(NA, cv_se, NA)
)
# Display results in a nice table
comparison_results |>
  knitr::kable(digits = 4)

# Method              MSE               Std Error
# Holdout             0.2323            NA
# 5-Fold CV           0.2415            0.0084
# LOOCV(Analytical)   0.2421            NA

# ============================================================================

# 5.3 When to Use LOOCV
# LOOCV proves most valuable when:
# • Small datasets: Limited data makes holdout/k-fold validation unreliable
# • Stable models: Low-complexity models reduce overfitting concerns
# • Analytical solutions: Efficient computation available (e.g., linear models)
# For large datasets or complex models, 10-fold cross-validation typically provides better bias-
#   variance trade-offs whilst requiring substantially less computation.

# LOOCV Variance Considerations
# Whilst LOOCV minimises bias, it often exhibits higher variance than k-fold CV due to
# the high correlation between models trained on nearly identical datasets. This correlation
# means that averaging across 𝑛 highly similar estimates provides less variance reduction
# than averaging across 𝐾 more diverse estimates in k-fold CV.

# ============================================================================

# 6 Advanced Resampling Considerations (NOT EXAMINABLE)

# 6.1 Nested Cross-Validation
# When hyperparameter tuning accompanies model selection, nested cross-validation prevents
# optimistic bias by maintaining strict separation between model selection and performance
# evaluation:
# 1. Outer loop: K-fold CV for performance estimation
# 2. Inner loop: Cross-validation within each training fold for hyperparameter selection
# This procedure provides unbiased estimates of final model performance whilst 
# accommodating complex model selection pipelines.

# 6.2 Time Series Considerations
# Standard cross-validation assumes exchangeable observations, making it inappropriate for
# time series data where temporal ordering matters. Time series cross-validation addresses
# this through:
# • Forward chaining: Train on historical data, test on future observations
# • Expanding windows: Progressively increase training set size
# • Rolling windows: Maintain fixed training set size whilst advancing through time

# 6.3 Computational Efficiency
# Modern resampling implementations leverage parallel computing for efficiency. The rsample
# package integrates with parallel processing frameworks:

library(parallel)
# Parallel cross-validation using base R's parallel package
mse_parallel <- unlist(mclapply(cv_folds$splits, compute_fold_mse,
                                mc.cores = 4))
cv_results_parallel <- data.frame(id = cv_folds$id, mse = mse_parallel)

# ============================================================================

# 7 Practical Guidelines for Method Selection

# The choice among resampling techniques depends on several factors:

# 7.1 Dataset Size Considerations
# • Large datasets (n > 10,000): Holdout method often sufficient
# • Medium datasets (1,000 < n < 10,000): 10-fold CV recommended
# • Small datasets (n < 1,000): LOOCV or bootstrap methods

# 7.2 Computational Constraints
# • Limited computation: Holdout or 5-fold CV
# • Moderate resources: 10-fold CV
# • Abundant resources: Repeated CV or bootstrap

# 7.3 Model Complexity
# • Simple models: LOOCV acceptable due to limited overfitting risk
# • Complex models: k-fold CV provides better bias-variance balance
# • Hyperparameter tuning: Nested CV essential for unbiased evaluation

# Key Recommendation
# For most practical applications, 10-fold cross-validation provides the optimal balance
# between computational efficiency, bias reduction, and variance control. This approach
# has become the de facto standard in machine learning and statistical practice for good
# reason: it works reliably across diverse problem domains and dataset characteristics.

# ============================================================================

# 8 Conclusion
# Resampling techniques provide essential tools for honest model evaluation and selection in
# statistical learning. The choice among holdout validation, k-fold cross-validation, and leave-
#   one-out cross-validation involves fundamental trade-offs between computational efficiency,
# bias, and variance.
# Understanding these trade-offs enables principled methodology selection appropriate to
# specific analytical contexts. Modern implementations through packages like rsample facilitate
# reproducible, efficient resampling workflows that integrate seamlessly with contemporary
# data science pipelines.
# The progression from simple holdout methods to sophisticated nested cross-validation 
# procedures reflects the evolution of statistical learning towards increasingly rigorous evaluation
# standards. As model complexity continues to grow, proper validation methodology becomes
# ever more critical for reliable scientific inference and practical decision-making.

## ============================================================================
## ============================================================================

##                                Slides: 

## ============================================================================
## ============================================================================

# Today’s objectives
# By the end of this unit you should be able to:
# • Explain why empirical risk is an optimistic guide to future error
# • Apply the holdout method and state its weakness
# • Run K-fold cross-validation and read its standard error
# • Recognise LOOCV as the 𝐾= 𝑛 limit, plus its linear-model shortcut
# • Match a resampling strategy to dataset size and compute budget

# Empirical risk is optimistic
# A model is fit to a finite sample, but we care about error on future
# data.
# How good is a fitted rule ̂𝑓? Average its loss 𝐿(𝑦, ̂𝑓(𝑥)) over the
# training data — the empirical risk:

# 𝑅_emp( ̂𝑓) =(1/n)*∑_(i=1->n)𝐿(𝑦𝑖, ̂𝑓(𝑥𝑖))

# This is always computable, but biased downward: the model has
# already seen these points. What we want is the expected risk on
# new (𝑋, 𝑌).

# ============================================================================

# Selection bias: the trap

# Test once, on data the model has never seen:
# Using the same data to choose a model and to report its accuracy
# makes the estimate optimistic — the model effectively learns the
# test set. It looks excellent in validation, then fails on deployment.

# The fix is to keep selection and final evaluation on separate data.
# Resampling embeds that separation inside a single sample.

# Resampling measures this trade-off: refit on different subsets,
# watch how ̂𝑓 wobbles (variance) and how far its average sits from
# truth (bias).

# ============================================================================

# One split: train here, test there

# Partition 𝒟︀= {(𝑥𝑖, 𝑦𝑖)}𝑖=1 -> into two disjoint sets, with training
# proportion 𝛼 (typically 0.6–0.8):

# ̂𝑅holdout =( 1 / | 𝒟︀test | ) *  ∑_ (𝑥𝑖,𝑦𝑖)∈𝒟︀_test  [𝐿(𝑦𝑖, ̂𝑓train(𝑥𝑖))

# • Unbiased for 𝑅( ̂𝑓) under a random split
# • High variance — the estimate hinges on which points landed in
# the test set
# • Cheap — only one model is trained

# Figure

# Holdout (80/20) = 80% training 20% testing
# 5-fold CV = 5 folds & 5 iterations. Each iteration 1 fold = test, 4 other folds = train
# LOOCV(K=n) = n folds, still 1 fold is for test and the reset is for train

# ============================================================================

# K-Fold Cross-Validation

# Average over K rotating folds
# Split 𝒟︀ into 𝐾 equal folds. For each 𝑘, train on the other 𝐾−1 folds
# and test on fold 𝑘; then average:

# 𝑅_CV = (1/K) * ∑_(k=1->K)̂𝑅_𝑘

# Every observation is tested exactly once
# • Averaging cuts the variance: Var [ ̂𝑅_CV] ≈ Var [ ̂𝑅_holdout]/𝐾
# • Common choices 𝐾∈{5, 10}; cost is 𝐾 fits

# K-fold in R

set.seed(2024) # cars: mpg ~ wt + hp
folds <- vfold_cv(cars, v = 5)
cv <- map_dbl(folds$splits, fold_mse)
c(CV_MSE = mean(cv), SE = sd(cv) / sqrt(length(cv))) |> round(3)

# CV_MSE  SE
# 8.039   1.783

# The SE tells you how trustworthy the single CV number is.

# Stratified folds

# For classification (or skewed regression targets), build folds that
# preserve the target distribution — vfold_cv(data, v = 5, strata = outcome)

# Why stratify
# Without it, a rare class can be absent from a test fold, giving an
# undefined or wildly unstable ̂𝑅𝑘. Stratification makes every fold a
# representative slice, so the folds measure the same thing and
# their average is meaningful.

# ============================================================================

# Leave-One-Out CV

# The K = n limit

# Each observation is its own test set; train on the other 𝑛−1:
# 𝑅LOOCV = (1/𝑛)*∑_(𝑖=1->𝑛)𝐿(𝑦𝑖, ̂𝑓_−𝑖(𝑥𝑖))

# • Deterministic — no random fold assignment
# • Low bias — each training set is nearly the full data
# • But costly (𝑛 fits) and often high variance (overlapping training sets)

# The linear-model shortcut
# For a linear model, LOOCV needs only one fit — no refitting:
# ^𝑅_LOOCV = (1/𝑛) * ∑_(𝑖=1->n)(𝑦_i −̂𝑦_i /   1 − ℎ_ii)^2

# where ℎ_ii represents the 𝑖-th diagonal element of the hat matrix 𝐇= 𝐗(𝐗′𝐗)^−1𝐗′.

# LOOCV in R (one fit)
fit <- lm(mpg ~ wt + hp, data = cars)
h <- hatvalues(fit)
r <- residuals(fit)
loocv_mse <- mean((r / (1 - h))^2)
round(loocv_mse, 3)

# [1] 7.703
# One model, 𝑛 leverage-corrected residuals — exact LOOCV with no loop.

# ============================================================================

# Choosing a Method

# Three estimators side by side

# Property              Holdout       K-Fold(K=10)      LOOCV
# Models trained        1             K                 n(or 1 for linear)
# Bias of estimate      low           low-moderate      lowest
# Variance of estimate  high          moderate          often high
# Randomness            yes           yes               none
# Best when             n very large  the default       small n, stable model

# Practical guidelines

# Dataset size          Recommended method
# Large(n>10,000)       Holdout often sufficient
# Medium(1,000-10,000)  10-fold CV
# Small(n<1,000)        LOOCV or bootstrap

# The de facto standard
# 10-fold cross-validation balances bias, variance and compute,
# and works reliably across most problems. Reach for it unless data
# are huge (holdout) or tiny (LOOCV).

# ============================================================================

# Summary

# Key takeaways
# 1. Empirical risk is optimistic — validation estimates future error
# 2. Holdout is cheap but high-variance (one lucky/unlucky split)
# 3. K-fold averages 𝐾 rotating folds; variance falls roughly like 1/𝐾
# 4. LOOCV is the 𝐾= 𝑛 limit — low bias, costly, with a linear-model shortcut
# 5. Match the method to size and compute; default to 10-fold CV

## ============================================================================
## ============================================================================

##                                Examples: 

## ============================================================================
## ============================================================================

# How to use these
# • Each example states a problem — try it before the reveal
# • Worked solutions appear in the lecturer copy (the amber boxes)
# • All code runs against car_data (𝑛= 32), modelling mpg ~ wt + hp

# ============================================================================

# Example 1 - A single holdout split

# Estimate test MSE once
# Split car_data 75/25, fit mpg ~ wt + hp on the training rows, and
# report the test MSE. What weakness does a single split have here?

set.seed(312)
sp <- initial_split(cars, prop = 0.75)
fit <- lm(mpg ~ wt + hp, data = training(sp))
pred <- predict(fit, newdata = testing(sp))
round(mean((testing(sp)$mpg - pred)^2), 3)

# [1] 8.598

# Answer

# Test MSE: 8.598.
# Weakness: A single split is a "lottery" because the error estimate depends 
# heavily on which specific observations happen to fall into the test set, 
# resulting in high variance

# ============================================================================

# Example 2 - Average over 5 folds (5-Fold Cross-Validation)

# Run 5-fold CV for the same model. Report the mean fold MSE and
# its standard error.

set.seed(312)
folds <- vfold_cv(cars, v = 5)
fold_mse <- function(s) {
  m <- lm(mpg ~ wt + hp, data = analysis(s))
  mean((assessment(s)$mpg - predict(m, assessment(s)))^2)
}
cv <- map_dbl(folds$splits, fold_mse)
c(CV_MSE = mean(cv), SE = sd(cv) / sqrt(length(cv))) |> round(3)

# CV_MSE    SE
# 7.932     1.961

# Answer

# - Mean Fold MSE (CV_MSE): 7.932.
# - Standard Error (SE): 1.961.
# - Insight: The SE tells you how trustworthy the single CV number is by 
#   measuring the spread of error across the folds

# ============================================================================

# Example 3 · LOOCV the easy way

# One fit, exact LOOCV
# For a linear model LOOCV needs no loop. Use the hat-matrix
# formula to get the LOOCV MSE from a single fit on all 32 cars.

fit_full <- lm(mpg ~ wt + hp, data = cars)
h <- hatvalues(fit_full); r <- residuals(fit_full)
loocv <- mean((r / (1 - h))^2)
round(loocv, 3)

# [1] 7.703

# LOOCV MSE: 7.703.
# Method: This was calculated using the hat-matrix shortcut, 
# which allows for an exact leave-one-out cross-validation estimate from a 
# single model fit on all 32 cars

# ============================================================================

# Example 4 · Putting the three together

# Which numbers agree?
# Compare the holdout, 5-fold and LOOCV estimates in one table.
# Which two should be closest, and why?

# Method            MSE
# Holdout (75/25)   8.598
# 5-fold CV         7.932
# LOOCV             7.703

# Answer

# Comparison: The 5-fold CV and LOOCV estimates are closer to each 
# other than to the single holdout split. 
# This is because averaging across multiple folds tames the "lottery" effect of a single random split

# ============================================================================

# Example 5 · How much does the split matter?

# Repeat the holdout 200 times
# Re-run the 75/25 holdout over many seeds and plot the spread of
# test MSE. One split is a lottery — the LOOCV line sits mid-spread;
# averaging (CV) tames it.

# Answer

# Observation: Plotting 200 random holdout splits shows a wide spread of MSE values. 
# The LOOCV estimate typically sits in the middle of this spread, 
# demonstrating that cross-validation provides a more stable and 
# representative estimate of true performance

# ============================================================================

# Exercise
# Using car_data and the model mpg ~ wt + hp + qsec:
# (a) Compute the LOOCV MSE with the hat-matrix shortcut.
# (b) Does adding qsec lower LOOCV MSE versus the mpg ~ wt + hp
# model from Example 3? What would you conclude?

# Answer

# Exercise: Model comparison with LOOCV
# Using the car_data and the expanded model (mpg ~ wt + hp + qsec):

# Exercise Results:
# a) LOOCV MSE with qsec Using the hat-matrix shortcut for the model mpg ~ wt + hp + qsec, 
#    the calculated LOOCV MSE is 7.502.
# b) Conclusion Adding qsec lowers the LOOCV MSE (7.502) compared to the simpler mpg ~ wt + hp 
#    model from Example 3 (7.703). You would conclude that qsec provides additional 
#    predictive information that outweighs the increase in model complexity, resulting in a 
#    model that generalises better to unseen data.






























