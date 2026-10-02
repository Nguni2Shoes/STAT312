## ============================================================================
## ============================================================================

##                                Slides: 
##                  k-Nearest Neighbours Classification
##                       STAT312 Learning Unit 7
##                    Dr Stéfan Janse van Rensburg
##                Department of Statistics Faculty of Science
##                                 2026

## ============================================================================
## ============================================================================

# Today's objectives
# By the end of this unit you should be able to:
# • Describe k-NN as a non-parametric, instance-based classifier
# • Choose a distance metric suited to the feature type
# • Apply the majority-vote decision rule
# • Explain why scaling matters and avoid the data-leakage trap
# • Read k off the bias-variance trade-off, and weigh the cost

# ============================================================================

# The Idea

# Classify by your neighbours
# • Similarity assumption: nearby points share a class
# • Pick the k closest training points
# • Let them vote; the majority class wins
# • No model is fitted - the data is the model
# • Captures non-linear boundaries

# Figure: 2D feature grid showing training points (green and red dots) and a query point (*)
# Points closest to the query determine its predicted class.

# ----------------------------------------------------------------------------

# What kind of learner is this?

# Property        k-NN                        Parametric (e.g. logistic)
# Assumptions     minimal (similarity)        functional form + distribution
# Training        store the data (lazy)       estimate parameters
# Flexibility     high, local, non-linear     fixed by the model form
# Cost lives at   prediction time             training time
# Needs           many points, few features   fewer points tolerable

# A concept that is local and example-driven, rather than a fitted equation.

# ============================================================================

# Distance Metrics

# Measuring similarity in feature space
# For two observations xi, xj in p dimensions, k-NN needs a distance d(xi, xj).
# Match the metric to the feature type:

# Metric            Formula                             Feature type
# Euclidean         sqrt(sum_(t=1->p) (xit - xjt)^2)    continuous
# Manhattan (L1)    sum_(t=1->p) |xit - xjt|            continuous
# Hamming           sum_(t=1->p) I(xit != xjt)          categorical

# I(·) is the indicator: 1 when the values differ, 0 when they match.

# ============================================================================

# The Decision Rule

# Majority vote
# Given a query x0, k-NN:
# 1. computes d(x0, xi) to every training point,
# 2. keeps the k nearest - the set N_k(x0),
# 3. assigns the most common class among them:
#
#   ^y_0 = arg max_c sum_(i in N_k(x0)) I(yi = c)

# ----------------------------------------------------------------------------

# Example: Majority voting visualisation
# class: A (green), B (red)
# k = 5: 3 A, 2 B -> predict A

# Figure: Decision Circle
# The circle encloses the k nearest points around query x0 (3 green class A, 2 red class B);
# faded points outside the circle are outvoted.

# ============================================================================

# Scaling & Data Leakage

# Distances are scale-sensitive
# A feature on a large numeric scale dominates every distance, drowning out the rest.
# Put all features on a common footing first:

# Scaling               Transform                       Effect
# Standardise (z-score) z = (x - mu) / sigma            mean 0, sd 1
# Min-max               x' = (x - min) / (max - min)    range [0, 1]

# Categorical features need encoding, not scaling.

# ----------------------------------------------------------------------------

# Fit the scaler on TRAIN only

# Data leakage:
# Compute the scaling mean and sd from the training set alone, then apply those same
# numbers to the test set. Scaling on the full data leaks test information into training
# and inflates the accuracy you report.

# Fit on TRAIN
sc <- scale(train[, feat])

# Keep its mean
ctr <- attr(sc, "scaled:center")

# Keep its sd
scl <- attr(sc, "scaled:scale")

# Apply to TEST
test_sc <- scale(test[, feat], center = ctr, scale = scl)

# ============================================================================

# Bias, Variance & Cost

# Choosing k
# The single knob k sets the bias-variance balance:

# Figure: Bias-Variance Trade-off Curve
# X-axis: k (number of neighbours ->) from 0 to 40
# Y-axis: error
# - Bias^2 (green line): increases steadily as k increases (large k -> underfit)
# - Variance (orange line): starts high for small k and decreases as k increases (small k -> overfit)
# - Total error (dark blue curve): U-shaped curve showing the "sweet spot" dip around k ≈ 15

# Small k chases noise; large k over-smooths. Cross-validate to find the dip.

# ----------------------------------------------------------------------------

# The price of being lazy
# • Training: none - just store the data
# • Prediction: distance to every point, cost proportional to n * p
# • Must keep the whole training set in memory
# • Often too slow for real-time use

# Curse of dimensionality
# In high p, all points sit at nearly equal distances - "nearest" stops meaning anything.
# Select features or reduce dimensions first.

# Mitigate with feature selection, sampling, or spatial indexing (e.g. k-d trees).

# ============================================================================

# Summary

# Key takeaways
# 1. k-NN is non-parametric and lazy - all work happens at prediction time
# 2. Pick the distance metric to match the feature type
# 3. The rule is a majority vote over N_k(x0)
# 4. Scale on the training set only - anything else leaks
# 5. k trades variance for bias; choose it by cross-validation
```[cite: 68, 69, 70, 71, 72, 73, 75, 76, 77, 78, 80, 81, 82, 84, 85, 87]