## ============================================================================
## ============================================================================

##                          Worked Examples & Exercises: 
##                    STAT312 Learning Unit 7 - k-Nearest Neighbours
##                    Dr Stéfan Janse van Rensburg
##                Department of Statistics Faculty of Science
##                                 2026

## ============================================================================
## ============================================================================

# How to use these
# • Each example states a problem - try it before the reveal
# • Worked solutions appear in the lecturer copy (the amber boxes)
# • Code is real and runs against the clinical dataset (3 risk classes)

# ============================================================================

# Example 1 · Load and split

# Load and set the 3-class factor
library(tidyverse)
library(rsample)
library(class)
library(yardstick)

lev <- c("Low_Risk", "Moderate_Risk", "High_Risk")
clinical <- read_csv("../Class Notes 2026/clinical_data.csv") |>
  mutate(outcome = factor(outcome, levels = lev))

count(clinical, outcome) |> deframe()

# Low_Risk Moderate_Risk     High_Risk 
#      126            42            32 

# ----------------------------------------------------------------------------

# Stratified 75/25 split
set.seed(123)
split <- initial_split(clinical, prop = 0.75, strata = outcome)
train <- training(split)
test  <- testing(split)

count(train, outcome) |> deframe()

# Low_Risk Moderate_Risk     High_Risk 
#       94            31            24 

# ============================================================================

# Example 2 · Scale on TRAIN only

# Avoid data leakage
# Standardise the four vitals using training parameters, then apply the
# same mean and sd to the test set.

feat <- c("systolic_bp", "diastolic_bp", "heart_rate", "age")
sc   <- scale(train[, feat])          # fit on TRAIN
ctr  <- attr(sc, "scaled:center")     # training means
scl  <- attr(sc, "scaled:scale")      # training sds

trX  <- as.matrix(sc)
teX  <- scale(test[, feat], center = ctr, scale = scl) |>
  as.matrix()

# ============================================================================

# Example 3 · Run k-NN, k = 5

# Predict and score
pred <- knn(train = trX, test = teX, cl = train$outcome, k = 5)
res  <- test |> mutate(predicted = pred)
accuracy(res, truth = outcome, estimate = predicted)

# # A tibble: 1 × 3
#   .metric  .estimator .estimate
#   <chr>    <chr>          <dbl>
# 1 accuracy multiclass     0.608

# ============================================================================

# Example 4 · Confusion matrix

# Tabulate truth vs prediction
cm <- conf_mat(res, truth = outcome, estimate = predicted)
cm

#                Truth
# Prediction      Low_Risk Moderate_Risk High_Risk
#   Low_Risk            27             6         7
#   Moderate_Risk        3             3         0
#   High_Risk            2             2         1

# ----------------------------------------------------------------------------

# Figure: Confusion Matrix Heatmap
# Tile visualization of Prediction vs Truth:
# - Low_Risk / Low_Risk: 27 (dark green)
# - Low_Risk / Moderate_Risk: 6 (light green)
# - Low_Risk / High_Risk: 7 (light green)
# - Moderate_Risk / Low_Risk: 3 (very pale green)
# - Moderate_Risk / Moderate_Risk: 3 (very pale green)
# - Moderate_Risk / High_Risk: 0 (white)
# - High_Risk / Low_Risk: 2 (very pale green)
# - High_Risk / Moderate_Risk: 2 (very pale green)
# - High_Risk / High_Risk: 1 (very pale green)
# Darker cells = more patients; the heavy diagonal is correct classifications.

# ============================================================================

# Example 5 · Choose k by cross-validation

# Sweep k on the training set
# Use knn.cv (leave-one-out on the training data) to pick k - never
# the test set.

ks <- seq(1, 25, by = 2)
acc <- map_dbl(ks, \(k)
               mean(knn.cv(trX, cl = train$outcome, k = k) == train$outcome))

best_k <- ks[which.max(acc)]

# Figure: LOO-CV accuracy vs k (neighbours)
# X-axis: k (neighbours) from 1 to 25
# Y-axis: LOO-CV accuracy (starts at ~0.39 for k = 1, climbs to ~0.54 at k = 5,
# reaches ~0.60 at k = 9, and peaks around k = 17 at ~0.63, marked with a dashed vertical line)

# ============================================================================

# Your turn

# Exercise
# (a) Refit k-NN with the CV-chosen best_k; report its test accuracy.
# (b) A colleague scales all 200 rows together before splitting - why
# is the reported accuracy untrustworthy, and what is the fix?

# Answer

# (a) Refit with best_k:
# pred_best <- knn(train = trX, test = teX, cl = train$outcome, k = best_k)
# res_best  <- test |> mutate(predicted = pred_best)
# accuracy(res_best, truth = outcome, estimate = predicted)

# (b) Data leakage explanation:
# Scaling all 200 rows together before partitioning allows information from the 
# test set (specifically the test set means and standard deviations) to bleed into 
# the training feature representation. This causes data leakage, leading to artificially 
# optimistic (untrustworthy) performance estimates.
# The fix: Standardise using parameters (mean and standard deviation) calculated 
# exclusively from the training set, then transform the test set using those training 
# parameters (using center = ctr, scale = scl).
```[cite: 139, 140, 142, 143, 145, 147, 149, 150, 152, 153, 154]