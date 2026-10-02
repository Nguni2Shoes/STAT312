# =============================================================================
# =============================================================================

#                               Notes:
#                 k-Nearest Neighbours Classification

# =============================================================================
# =============================================================================

# Contents
# 1 Introduction 
# 2 Mathematical Framework 
# 2.1 Distance Metrics 
# Continuous Features 
# Categorical Features 
# Mixed Data Types (NOT EXAMINABLE) 
# 2.2 Classification Decision Rule 
# 3 Implementation 
# 3.1 Data Preparation 
# 3.2 Data Splitting and Feature Scaling 
# 3.3 k-NN Classification 
# 3.4 Visualisation of Results 
# 3.5 Interpretation and Model Assessment 
# 4 Theoretical Considerations 
# 4.1 Bias-Variance Trade-off 
# 4.2 Computational Characteristics 
# 4.3 Assumptions and Limitations 
# 5 Advanced Extensions (NOT EXAMINABLE) 
# 5.1 Weighted k-NN 
# 5.2 Adaptive k Selection 
# 6 Conclusion 

# ============================================================================

# 1 Introduction

# The k-nearest neighbours (k-NN) algorithm constitutes the most intuitive non-parametric
# classification method, making minimal distributional assumptions about the underlying data
# structure.

# Non-Parametric Methods
# Non-parametric methods, such as k-NN, don't make assumptions about a dataset's
# underlying probability distribution or the mathematical form of the relationship between
# variables. This contrasts with parametric methods, like logistic regression, which esti-
# mate fixed parameters based on pre-defined assumptions. Because non-parametric
# approaches derive predictions directly from the data, they can capture complex, non-
# linear patterns. This flexibility, however, requires larger datasets and more computational
# power.

# Definition: k-Nearest Neighbours Classification is a non-parametric, instance-based learning
# algorithm that classifies observations based on the majority class among the k closest training
# observations in feature space.

# The algorithm's elegance lies in its conceptual simplicity: similar observations should exhibit
# similar class membership. This principle, known as the similarity assumption, forms the theo-
# retical foundation for k-NN's predictive capability.

# ============================================================================

# 2 Mathematical Framework

# 2.1 Distance Metrics
# The k-NN algorithm requires a distance metric to quantify similarity between observations. Let
# xi = (xi1, xi2, ..., xip) and xj = (xj1, xj2, ..., xjp) represent two observations in p-dimensional
# feature space.

# Continuous Features
# Continuous variables require distance metrics that account for the magnitude of differences
# between numerical values across all dimensions.

# Euclidean Distance:
#   d_ij = sqrt(sum_(t=1->p) (x_it - x_jt)^2)

# Manhattan Distance (L1 norm):
#   d_ij = sum_(t=1->p) |x_it - x_jt|

# Categorical Features
# Categorical variables necessitate distance measures that focus on the presence or absence of
# matches rather than numerical differences.

# Hamming Distance:
#   d_ij = sum_(t=1->p) I(x_it != x_jt)

# where I(·) represents the indicator function that equals 1 when the categorical values differ
# and 0 when they match. The Hamming distance simply counts the number of features where
# two observations have different categorical values.

# Mixed Data Types (NOT EXAMINABLE)
# When datasets contain both continuous and categorical features, practitioners typically
# standardise continuous variables and apply weighted combinations of appropriate distance
# measures. For instance, the total distance might combine normalised Euclidean distance for
# continuous features with Hamming distance for categorical features:

#   d_ij = w_c * d_ij^(continuous) + w_h * d_ij^(categorical)

# where w_c and w_h represent weights that balance the contribution of continuous and categor-
# ical components respectively.

# Feature Scaling Considerations
# Distance-based algorithms like k-NN are sensitive to feature scales. Variables measured
# in different units can dominate distance calculations. Standardisation using z = (x - mu) / sigma or
# min-max scaling using x' = (x - min(x)) / (max(x) - min(x)) ensures equitable contribution from all contin-
# uous features. Categorical features require no scaling but may benefit from appropriate
# encoding schemes when multiple categories exist.

# ============================================================================

# 2.2 Classification Decision Rule

# Given a test observation x0, the k-NN algorithm:
# 1. Calculates distances between x0 and all training observations
# 2. Identifies the k nearest neighbours: N_k(x0)
# 3. Assigns the majority class among these neighbours:
#   ^y_0 = mode{y_i : i in N_k(x0)}

# For tie-breaking when k is even, common strategies include reducing k by 1 or employing
# weighted voting based on inverse distances.

# ============================================================================

# 3 Implementation

# 3.1 Data Preparation

# We demonstrate k-NN classification using a clinical dataset examining patient risk assessment
# based on physiological measurements. The dataset contains standardised measurements for
# systolic blood pressure, diastolic blood pressure, heart rate, and patient age, with outcomes
# classified into three risk categories.

library(tidyverse)
library(class)
library(rsample)
library(yardstick)

# Import clinical dataset
clinical_data <- read_csv("clinical_data.csv") |>
  mutate(
    outcome = factor(
      outcome, levels = c(
        "Low_Risk", "Moderate_Risk", "High_Risk"
      )
    )
  )

# Examine data structure
str(clinical_data)

# (S3: tbl_df/tbl/data.frame)
# tibble [200 × 6]
# $ patient_id : num [1:200] 1 2 3 4 5 6 7 8 9 10 ...
# $ systolic_bp: num [1:200] 157 119 137 143 138 ...
# $ diastolic_bp: num [1:200] 61 89 99.1 109.7 68.5 ...
# $ heart_rate : num [1:200] 95 62 75.8 75.7 66.3 ...
# $ age        : num [1:200] 58 62 58 72 54 49 54 33 61 41 ...
# $ outcome    : Factor w/ 3 levels "Low_Risk","Moderate_Risk",..: 2 1 3 1 1 1 2 3 1 1 ...

# Display outcome distribution
clinical_data |>
  count(outcome) |>
  mutate(proportion = n / sum(n)) |>
  knitr::kable(
    caption = "Risk Category Distribution",
    col.names = c("Risk Category", "Count", "Proportion"),
    digits = 3
  )

# Table: Risk Category Distribution
# Risk Category   Count   Proportion
# Low_Risk        126     0.63
# Moderate_Risk   42      0.21
# High_Risk       32      0.16

# ============================================================================

# 3.2 Data Splitting and Feature Scaling

# We partition the data into training and testing sets using stratified sampling to maintain
# outcome proportions. Feature standardisation prevents variables measured on different scales
# from dominating distance calculations.

# Create stratified train-test split
set.seed(123)
data_split <- initial_split(
  clinical_data, prop = 0.75,
  strata = outcome)
train_data <- training(data_split)
test_data <- testing(data_split)

# Note: In practice, we would thoroughly compare
# training and testing distributions here to
# ensure representative splits

# Standardise features to prevent data leakage
feature_cols <- c(
  "systolic_bp", "diastolic_bp",
  "heart_rate", "age"
)

# Calculate scaling parameters from training data only
train_features_scaled <- scale(train_data[, feature_cols])

# Extract scaling parameters
center_vals <- attr(train_features_scaled, "scaled:center")
scale_vals <- attr(train_features_scaled, "scaled:scale")

# Apply identical scaling to test data using training
# parameters
test_features_scaled <- scale(test_data[, feature_cols],
                              center = center_vals, scale = scale_vals)

# Convert to matrices for knn() function
train_matrix <- as.matrix(train_features_scaled)
test_matrix <- as.matrix(test_features_scaled)
train_labels <- train_data$outcome

# The attr Function in R
# The attr() function in R is used to retrieve attributes from an object. For example, when
# you use scale() to standardise data, it saves the calculated means and standard devia-
# tions as attributes. You can access these values using attr() with the attribute names
# "scaled:center" and "scaled:scale", respectively. This is useful for applying the exact same
# scaling transformation to new data, such as a test set, which ensures consistency and
# prevents data leakage.

# Data Leakage
# Data leakage occurs when information from the test set inadvertently influences the
# model training process, leading to overly optimistic performance estimates. This conta-
# mination compromises the fundamental principle that test data should remain completely
# separate from all training procedures. Common sources include using statistics calculated
# from the entire dataset for preprocessing (such as scaling parameters), applying feature
# selection based on full dataset characteristics, or using future information to predict past
# events.

# Preventing Data Leakage in Feature Scaling
# Scaling parameters (mean and standard deviation) must be calculated exclusively from
# training data. Applying the same parameters to test data ensures that no information
# from the test set influences the training process, maintaining the integrity of performance
# evaluation.

# ============================================================================

# 3.3 k-NN Classification

# We implement k-NN classification using k = 5 neighbours and evaluate performance on the
# test set. The algorithm assigns each test observation to the majority class among its five
# nearest training neighbours.

# Apply k-NN with k = 5
k_value <- 5
knn_predictions <- knn(
  train = train_matrix,
  test = test_matrix,
  cl = train_labels,
  k = k_value
)

# Calculate classification accuracy using yardstick
test_results <- test_data |>
  mutate(predicted = knn_predictions)
accuracy_result <- test_results |>
  accuracy(truth = outcome, estimate = predicted)
print(accuracy_result)

# A tibble: 1 × 3
#   .metric  .estimator .estimate
#   <chr>    <chr>          <dbl>
# 1 accuracy multiclass     0.608

# Display confusion matrix
confusion_matrix <- test_results |>
  conf_mat(truth = outcome, estimate = predicted)
print(confusion_matrix)

#                Truth
# Prediction      Low_Risk Moderate_Risk High_Risk
#   Low_Risk            27             6         7
#   Moderate_Risk        3             3         0
#   High_Risk            2             2         1

# ============================================================================

# 3.4 Visualisation of Results

# We visualise the classification results using a two-dimensional projection of the feature space,
# showing actual classes and predicted outcomes.

# Create scatter plot showing predictions vs actual
# outcomes
test_results |>
  ggplot(aes(x = systolic_bp, y = diastolic_bp)) +
  geom_point(aes(colour = outcome, shape = predicted),
             size = 3, alpha = 0.7) +
  scale_colour_manual(
    name = "Actual Class",
    values = c("Low_Risk" = "#2E8B57",
               "Moderate_Risk" = "#FF8C00",
               "High_Risk" = "#DC143C")
  ) +
  scale_shape_manual(
    name = "Predicted Class",
    values = c("Low_Risk" = 16,
               "Moderate_Risk" = 17,
               "High_Risk" = 15)
  ) +
  labs(
    title = sprintf(
      "k-NN Classification Results (k = %d)",
      k_value),
    x = "Systolic Blood Pressure",
    y = "Diastolic Blood Pressure"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# Figure: k-NN Classification Results (k = 5)
# Scatter plot of Systolic Blood Pressure (x) vs Diastolic Blood Pressure (y)
# Actual classes represented by colours (Low_Risk: green, Moderate_Risk: orange, High_Risk: red)
# Predicted classes represented by shapes (Low_Risk: circle, Moderate_Risk: triangle, High_Risk: square)
# Observations distributed across Systolic BP range (~75 to 175) and Diastolic BP range (~50 to 115)

# ============================================================================

# 3.5 Interpretation and Model Assessment

# The k-NN algorithm achieved an accuracy of 0.608 on the test dataset. This performance
# demonstrates the algorithm's ability to identify meaningful patterns in the physiological
# measurements for risk assessment.

# Key Observations:
# • The confusion matrix reveals the algorithm's performance across different risk categories
# • Misclassifications typically occur between adjacent risk levels (Low-Moderate or Moderate-
# High)
# • The choice of k = 5 represents a balance between model flexibility and stability

# Model Limitations:
# • Performance depends critically on the choice of k value
# • Feature scaling significantly influences results due to distance-based calculations
# • Computational complexity increases linearly with training set size

# Recommended Extensions:
# 1. Optimal k Selection: Apply cross-validation to the training set and systematically evaluate
# different k values to select the optimal parameter
# 2. Feature Engineering: Investigate polynomial features or interaction terms to capture non-
# linear relationships
# 3. Distance Metrics: Compare Euclidean and Manhattan distances to identify the most appro-
# priate metric for this domain
# 4. Class-Specific Analysis: Calculate precision, recall, and F1-scores for each risk category to
# understand performance variations

# ============================================================================

# 4 Theoretical Considerations

# 4.1 Bias-Variance Trade-off

# The choice of k fundamentally controls the bias-variance trade-off in k-NN classification:
# • Small k (k = 1): Low bias, high variance. The model closely follows training data but may
# overfit to noise.
# • Large k: Higher bias, lower variance. The model becomes more stable but may underfit
# complex patterns.

# Optimal k Selection: Cross-validation provides an empirical approach to balance this trade-
# off by estimating generalisation performance across different k values.

# ============================================================================

# 4.2 Computational Characteristics

# k-NN exhibits unique computational properties that distinguish it from parametric classifica-
# tion methods and influence practical implementation decisions.

# Training and Prediction Phases: k-NN requires no computational effort during training, as the
# algorithm simply stores the complete training dataset. However, prediction demands intensive
# computation. Each new observation requires distance calculations to every training point,
# followed by identification of the k nearest neighbours. When classifying multiple observations,
# these calculations repeat for each prediction.

# Resource Requirements: The algorithm's computational demands scale directly with dataset
# characteristics. Larger training sets require more distance calculations per prediction, whilst
# additional features increase the computation needed for each distance measure. Memory
# requirements also grow proportionally, as k-NN must retain the entire training dataset during
# both training and prediction phases.

# Practical Implications: These characteristics create distinct advantages and limitations. Small
# datasets enable rapid predictions with minimal computational overhead. Large datasets,
# particularly those with numerous features, may produce prohibitively slow prediction times
# and excessive memory consumption. Real-time applications often find k-NN unsuitable due
# to these computational demands.

# Efficiency Strategies: Several approaches can improve k-NN performance. Feature selection
# reduces dimensionality and accelerates distance calculations. Strategic sampling of large
# training datasets can maintain classification accuracy whilst reducing computational burden.
# Efficient data preprocessing and storage structures also contribute to improved performance.

# Understanding these computational characteristics enables practitioners to make informed
# decisions about k-NN's appropriateness for specific statistical applications, particularly
# when considering dataset size, prediction speed requirements, and available computational
# resources.

# Curse of Dimensionality
# k-NN performance degrades in high-dimensional spaces due to the curse of dimension-
# ality. As dimensions increase, distance measures become less discriminative, and the
# concept of "nearest neighbours" loses meaning. Dimensionality reduction techniques
# may be necessary for high-dimensional datasets.

# ============================================================================

# 4.3 Assumptions and Limitations

# Key Assumptions:
# 1. Local Similarity: Similar observations should have similar class labels
# 2. Adequate Sample Density: Sufficient training observations in each region of feature space
# 3. Relevant Features: All features contribute meaningful information for classification

# Primary Limitations:
# 1. Computational Inefficiency: Requires distance calculations to entire training set
# 2. Storage Requirements: Must retain complete training dataset
# 3. Feature Scaling Sensitivity: Requires careful preprocessing
# 4. Categorical Feature Handling: Distance metrics may not be appropriate for mixed data
# types

# ============================================================================

# 5 Advanced Extensions (NOT EXAMINABLE)

# 5.1 Weighted k-NN

# Distance-weighted voting can improve classification by giving closer neighbours more influ-
# ence:
#   w_i = 1 / (d_i + epsilon)

# where d_i is the distance to neighbour i and epsilon prevents division by zero.

# ============================================================================

# 5.2 Adaptive k Selection

# Rather than using fixed k, adaptive methods select k based on local data density or cross-
# validation within local neighbourhoods.

# ============================================================================

# 6 Conclusion

# k-Nearest Neighbours classification provides an intuitive, non-parametric approach to clas-
# sification problems. Its simplicity enables easy interpretation and implementation, while its
# flexibility allows application across diverse domains. However, practitioners must carefully
# consider computational requirements, feature scaling, and the curse of dimensionality when
# applying k-NN to real-world problems.

# The algorithm's performance depends critically on appropriate distance metrics, optimal k se-
# lection through cross-validation, and careful data preprocessing. When these considerations
# are properly addressed, k-NN can provide competitive performance for many classification
# tasks, particularly when local patterns in the data are more important than global statistical
# relationships.
```[cite: 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]