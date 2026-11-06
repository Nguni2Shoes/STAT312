# ==============================================================================
# STAT312 Semester Test 3 (2026) Theory: Questions and Model Solutions
# Module: Advanced Data Analytics (STAT312)
# Assessment: Semester Test 3 (Theory Section)
# Date: 2 October 2026
# Total Marks: 50 Marks (Section A Written Theory: 25 Marks)
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION A — WRITTEN THEORY [25 MARKS]
# ------------------------------------------------------------------------------

# ==============================================================================
# QUESTION 1: k-Nearest Neighbours Classification & Feature Scaling [7 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# A field station identifies two species of fish, A and B, from two measurements:
# body length and fin length, both recorded in centimetres.
# The table gives five fish whose species is known:
#   Fish 1: Body = 4 cm, Fin = 5 cm, Species = A
#   Fish 2: Body = 7 cm, Fin = 4 cm, Species = B
#   Fish 3: Body = 6 cm, Fin = 6 cm, Species = B
#   Fish 4: Body = 2 cm, Fin = 4 cm, Species = A
#   Fish 5: Body = 9 cm, Fin = 4 cm, Species = A

# ------------------------------------------------------------------------------
# Part (a) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# The squared Euclidean distances from the new fish (body = 5 cm, fin = 4 cm)
# to fish 4 and fish 5 are 9 and 16. Compute the squared distances to fish 1,
# 2 and 3, and hence classify the new fish with k = 1 and k = 3.

# Model Answer:
# New fish coordinates: (5, 4).
# 1. Squared Euclidean distances d_i^2 = (body_i - 5)^2 + (fin_i - 4)^2:
#    - Fish 1 (4, 5): (4 - 5)^2 + (5 - 4)^2 = (-1)^2 + 1^2 = 2
#    - Fish 2 (7, 4): (7 - 5)^2 + (4 - 4)^2 = 2^2 + 0^2 = 4
#    - Fish 3 (6, 6): (6 - 5)^2 + (6 - 4)^2 = 1^2 + 2^2 = 5
#    - Fish 4 (2, 4): (given) = 9
#    - Fish 5 (9, 4): (given) = 16
#
# 2. Classification for k = 1:
#    - Nearest neighbour is Fish 1 (squared distance = 2), which is Species A.
#    - Classification: Species A.
#
# 3. Classification for k = 3:
#    - Three nearest neighbours are Fish 1 (dist^2 = 2, A), Fish 2 (dist^2 = 4, B),
#      and Fish 3 (dist^2 = 5, B).
#    - Majority vote: 2 for Species B vs. 1 for Species A.
#    - Classification: Species B.


# ------------------------------------------------------------------------------
# Part (b) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# The analyst now uses k = 5. Classify the new fish, and explain why the
# classification would be the same for any new fish, whatever its measurements.
# What does this illustrate about choosing k too large?

# Model Answer:
# 1. Classification for k = 5:
#    - When k = 5, all 5 observations in the dataset are included.
#    - The dataset contains 3 Species A (Fish 1, 4, 5) and 2 Species B (Fish 2, 3).
#    - Majority vote is 3 vs. 2 in favour of Species A.
#    - Classification: Species A.
#
# 2. Explanation & Methodological Principle:
#    - Setting k = 5 forces the algorithm to average across the entire sample,
#      making the decision rule independent of feature coordinates. Every query
#      point will be assigned to Species A because it is the global majority class.
#    - This illustrates that setting k too large (or equal to n) causes severe
#      over-smoothing (high bias), ignoring local feature relationships and
#      collapsing the classifier into predicting the prior majority class.


# ------------------------------------------------------------------------------
# Part (c) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# The station's newer recording form gives fin length in millimetres. Every fin
# length in the table, and the new fish's, is therefore multiplied by 10; body
# length is unchanged. Without recomputing any distances, answer in prose:
# 1. Will the nearest neighbour of the new fish necessarily stay the same once
#    fin length is rescaled this way? Explain your reasoning.
# 2. The station instead standardises each measurement before computing distances.
#    Explain why this removes the dependence of the result on the unit of measurement.

# Model Answer:
# 1. No, the nearest neighbour will not necessarily stay the same. Rescaling fin
#    length by a factor of 10 multiplies its contribution to the squared distance
#    by 100 relative to body length. Predictors measured in larger numerical scales
#    dominate Euclidean distance calculations, altering nearest-neighbour rankings
#    by heavily penalizing differences in fin length over body length.
# 2. Standardisation transforms each feature by subtracting its sample mean and
#    dividing by its standard deviation (z = (x - mean) / sd). Scaling a variable
#    by a constant factor c multiplies both the numerator and denominator by c,
#    which cancels out completely. Standardised features are unitless (z-scores),
#    making distance calculations invariant to changes in measurement scale.


# ==============================================================================
# QUESTION 2: Nadaraya-Watson Kernel Regression Derivation [9 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# Let (X_i, Y_i), i = 1,...,n, be a sample, K a kernel function and h > 0 a bandwidth.
# The Nadaraya-Watson estimator of the regression function f(x) = E[Y | X = x] is:
#   f_hat(x) = sum_{i=1}^n w_i * Y_i,  where w_i = K((x - X_i)/h) / sum_{j=1}^n K((x - X_j)/h)

# ------------------------------------------------------------------------------
# Part (a) [6 Marks]
# ------------------------------------------------------------------------------
# Question:
# Derive this result from the fundamental regression relationship:
#   E[Y | X = x] = integral y * p(y | x) dy.

# Model Answer:
# Step 1: Express conditional expectation in terms of joint and marginal densities:
#   E[Y | X = x] = integral y * [p(x, y) / p(x)] dy = [integral y * p(x, y) dy] / p(x)
#
# Step 2: Replace unknown densities p(x, y) and p(x) with Kernel Density Estimates (KDE):
#   p_hat(x, y) = (1 / (n * h_x * h_y)) * sum_{i=1}^n K_x((x - X_i)/h_x) * K_y((y - Y_i)/h_y)
#   p_hat(x)    = (1 / (n * h_x)) * sum_{j=1}^n K_x((x - X_j)/h_x)
#
# Step 3: Evaluate the numerator integral integral y * p_hat(x, y) dy:
#   integral y * p_hat(x, y) dy = (1 / (n * h_x * h_y)) * sum_{i=1}^n K_x((x - X_i)/h_x) * integral y * K_y((y - Y_i)/h_y) dy
#   Using change of variable u = (y - Y_i)/h_y  =>  y = Y_i + h_y * u, dy = h_y * du:
#   integral y * K_y((y - Y_i)/h_y) dy = h_y * integral (Y_i + h_y * u) * K_y(u) du
#   Since K_y is a symmetric probability kernel (integral K_y(u) du = 1 and integral u * K_y(u) du = 0):
#   = h_y * Y_i * (1) + h_y^2 * (0) = h_y * Y_i
#   Substituting back into numerator yields: (1 / (n * h_x)) * sum_{i=1}^n K_x((x - X_i)/h_x) * Y_i
#
# Step 4: Combine numerator and denominator to form the estimator f_hat(x):
#   f_hat(x) = [(1 / (n * h)) * sum_{i=1}^n K((x - X_i)/h) * Y_i] / [(1 / (n * h)) * sum_{j=1}^n K((x - X_j)/h)]
#   Cancelling (1 / (n * h)) gives:
#   f_hat(x) = sum_{i=1}^n [ K((x - X_i)/h) / sum_{j=1}^n K((x - X_j)/h) ] * Y_i = sum_{i=1}^n w_i * Y_i. Q.E.D.


# ------------------------------------------------------------------------------
# Part (b) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# Using the weights w_i, explain what happens to the estimate f_hat(x) when the
# bandwidth h is made (i) very large and (ii) very small. In each case, state
# whether the estimate then suffers from high bias or high variance.

# Model Answer:
# (i) Very Large Bandwidth (h -> infinity):
#     - As h becomes very large, (x - X_i)/h approaches 0 for all i, causing
#       K((x - X_i)/h) -> K(0) (a constant value) for every observation.
#     - The weights become equal: w_i -> 1 / n for all i.
#     - f_hat(x) reduces to the simple global average of all response values, y_bar.
#     - Performance Impact: Severe over-smoothing resulting in HIGH BIAS (low variance).
#
# (ii) Very Small Bandwidth (h -> 0):
#      - As h approaches 0, K((x - X_i)/h) drops to 0 for all observations except
#        the single training point X_i closest to x.
#      - The weight w_i for the nearest neighbour approaches 1, while all other
#        weights approach 0.
#      - f_hat(x) approaches the exact response value of the nearest training point.
#      - Performance Impact: Highly sensitive to sample noise resulting in HIGH VARIANCE (low bias).


# ==============================================================================
# QUESTION 3: K-Means Clustering Hand Calculations & Properties [5 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# A courier company places two depots to serve six drop-off points:
#   P1: (1, 1), P2: (3, 1), P3: (1, 3), P4: (6, 5), P5: (7, 7), P6: (6, 7)
# K-means clustering is run with k = 2 and squared Euclidean distance,
# starting from initial centroids mu_1 = (1, 1) and mu_2 = (3, 1).

# ------------------------------------------------------------------------------
# Part (a) [1 Mark]
# ------------------------------------------------------------------------------
# Question:
# Given the squared distance table, perform the assignment step and state the
# cluster each point is assigned to.
# Distance Table:
#   To mu_1 = (1,1): P1=0,  P2=4, P3=4, P4=41, P5=72, P6=61
#   To mu_2 = (3,1): P1=4,  P2=0, P3=8, P4=25, P5=52, P6=45

# Model Answer:
# Compare squared distance to mu_1 vs mu_2 for each point:
#   - P1: 0 vs 4   => Assign to Cluster 1
#   - P2: 4 vs 0   => Assign to Cluster 2
#   - P3: 4 vs 8   => Assign to Cluster 1
#   - P4: 41 vs 25 => Assign to Cluster 2
#   - P5: 72 vs 52 => Assign to Cluster 2
#   - P6: 61 vs 45 => Assign to Cluster 2
#
# Cluster Assignments:
#   Cluster 1 = { P1, P3 }
#   Cluster 2 = { P2, P4, P5, P6 }


# ------------------------------------------------------------------------------
# Part (b) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# Perform the update step: compute the new centroids.

# Model Answer:
# 1. New Centroid mu_1 (Mean of Cluster 1 = {P1(1,1), P3(1,3)}):
#    - East  = (1 + 1) / 2 = 1.0
#    - North = (1 + 3) / 2 = 2.0
#    - mu_1 = (1.0, 2.0)
#
# 2. New Centroid mu_2 (Mean of Cluster 2 = {P2(3,1), P4(6,5), P5(7,7), P6(6,7)}):
#    - East  = (3 + 6 + 7 + 6) / 4 = 22 / 4 = 5.5
#    - North = (1 + 5 + 7 + 7) / 4 = 20 / 4 = 5.0
#    - mu_2 = (5.5, 5.0)


# ------------------------------------------------------------------------------
# Part (c) [1 Mark]
# ------------------------------------------------------------------------------
# Question:
# Without computing it, explain in one or two sentences why the total within-cluster
# sum of squares of the clustering after the update in (b) cannot be larger than it
# was for the clustering formed in (a).

# Model Answer:
# Recomputing each centroid as the arithmetic mean of its assigned observations
# mathematically minimizes the sum of squared distances for that partition. Because
# both the assignment and update steps non-incrementally minimize the objective,
# the Total Within-Cluster Sum of Squares (WCSS) is non-increasing at every step.


# ------------------------------------------------------------------------------
# Part (d) [1 Mark]
# ------------------------------------------------------------------------------
# Question:
# Suppose the update step gives centroids mu_1 = (1, 2) and mu_2 = (5.5, 5.0).
# State, with a reason, whether the algorithm has converged.

# Model Answer:
# The algorithm has NOT converged. Evaluating point P2(3,1) under the new centroids:
#   - Squared distance to mu_1(1,2): (3 - 1)^2 + (1 - 2)^2 = 4 + 1 = 5
#   - Squared distance to mu_2(5.5,5): (3 - 5.5)^2 + (1 - 5)^2 = 6.25 + 16 = 22.25
# Because P2 is now closer to mu_1 than to mu_2 (5 < 22.25), it reassigns from
# Cluster 2 to Cluster 1. Since cluster assignments change upon reassignment,
# convergence has not been reached.


# ==============================================================================
# QUESTION 4: Silhouette Analysis & Cluster Validation [4 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# A retailer clustered customers by k-means:
#   - Customer P: a_P = 0.8 (mean dist to own cluster), b_P = 2.4 (mean dist to nearest cluster)
#   - Customer Q: a_Q = 1.5 (mean dist to own cluster), b_Q = 1.0 (mean dist to nearest cluster)

# ------------------------------------------------------------------------------
# Part (a) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# Compute the silhouette coefficient of each customer.
# Formula: s_i = (b_i - a_i) / max(a_i, b_i)

# Model Answer:
# 1. Customer P:
#    s_P = (2.4 - 0.8) / max(0.8, 2.4) = 1.6 / 2.4 = 2 / 3 ≈ 0.6667 (or 0.67)
#
# 2. Customer Q:
#    s_Q = (1.0 - 1.5) / max(1.5, 1.0) = -0.5 / 1.5 = -1 / 3 ≈ -0.3333 (or -0.33)


# ------------------------------------------------------------------------------
# Part (b) [1 Mark]
# ------------------------------------------------------------------------------
# Question:
# In one sentence, interpret Customer Q's silhouette coefficient.

# Model Answer:
# Customer Q has a negative silhouette coefficient (s_Q ≈ -0.3333), which indicates
# that on average it is closer to points in a neighbouring cluster than to points
# in its assigned cluster, meaning Customer Q is likely misclassified/misclustered.


# ------------------------------------------------------------------------------
# Part (c) [1 Mark]
# ------------------------------------------------------------------------------
# Question:
# To choose k, the retailer plots total within-cluster sum of squares against k
# and looks for the elbow. In one sentence, state what the elbow point represents.

# Model Answer:
# The elbow point represents the optimal number of clusters k where adding further
# clusters provides diminishing returns in reducing within-cluster variance (WCSS),
# balancing model fit against clustering parsimony.
