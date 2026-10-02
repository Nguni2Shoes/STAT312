## ============================================================================
## ============================================================================

##                                Slides: 
##                           K-Means Clustering
##                       STAT312 Learning Unit 9
##                    Dr Stéfan Janse van Rensburg
##                Department of Statistics Faculty of Science
##                                 2026

## ============================================================================
## ============================================================================

# Today's objectives
# By the end of this unit you should be able to:
# • Recognise clustering as an unsupervised partitioning task
# • State the within-cluster sum-of-squares (WCSS) objective
# • Run the assignment and update steps of the algorithm
# • Name the assumptions that make k-means succeed or fail
# • Choose k with the elbow and silhouette methods

# ============================================================================

# Idea & Objective

# Clustering finds groups without labels
# • Clustering discovers natural groupings using feature similarity alone
# • No response Y - it is unsupervised and exploratory
# • K-means is the most widely used partitioning method

# Clustering vs classification
# Classification sorts points into predefined labelled classes.
# Clustering uncovers previously unknown groups - there is no
# single "correct" answer.

# ----------------------------------------------------------------------------

# The objective: compact clusters
# Partition n points x_i in R^d into k clusters, then minimise the within-
# cluster sum of squares about each centroid mu_i (the cluster mean):
#
#   WCSS = sum_(i=1->k) sum_(x in S_i) ||x - mu_i||^2
#   (lower = tighter)

# ----------------------------------------------------------------------------

# Distance and the scaling trap
# Dissimilarity is Euclidean distance, which weights every feature equally:
#
#   d(x, y) = sqrt(sum_(j=1->d) (x_j - y_j)^2) = ||x - y||
#
# • Variables on larger scales dominate - income (thousands) swamps age (years)
# • Standardise to zero mean, unit variance before clustering

# ============================================================================

# The Algorithm

# Two steps, repeated to convergence
# K-means alternates two steps until assignments stop changing:
# 1. Assignment - put each point with its nearest centroid
# 2. Update - move each centroid to the mean of its members
# It is guaranteed to reach a local minimum of WCSS.

# ----------------------------------------------------------------------------

# Visualisation of the Iterative Steps:
# Step 1: Assign to nearest centroid (*)
#   Points in 2D space are colored based on their closest starting centroid (*).
# Step 2: Update: move each * to its mean
#   Each centroid moves along a vector line to the geometric center (mean) of its assigned members.
# Each point joins its nearest centre; centres then slide to their means. Repeat.

# ----------------------------------------------------------------------------

# The two steps, formally

# Assignment:
#   C(x_i) = arg min_j ||x_i - mu_j||^2
# Carves the space into a Voronoi partition - boundaries are
# perpendicular bisectors, so clusters come out convex.

# Update:
#   mu_j^(new) = (1 / |S_j|) * sum_(x_i in S_j) x_i
# The mean is the point minimising total squared distance - the
# optimal centre for a fixed set of members.

# ----------------------------------------------------------------------------

# Random starts beat unlucky starts
# • K-means reaches a local minimum, not the global one
# • Different initial centres give solutions of different quality
# • Fix: run from many random starts and keep the lowest-WCSS result

# In R:
# Set nstart = 25 so kmeans() runs 25 times and returns the best.
# k-means++ initialisation spreads the starting centres apart.

# ============================================================================

# Assumptions & Limits

# What k-means quietly assumes
# K-means works best when clusters are:
#
# Assumption    Why                     Fails on
# Spherical     round Euclidean balls   rings, crescents
# Similar size  squared distance        a big diffuse cluster
# Convex        linear boundaries       curved shapes
# Few outliers  squares magnify them    one far-off point
#
# These are properties of the objective, not bugs.

# ----------------------------------------------------------------------------

# When to reach for something else
# • Non-spherical (rings, crescents) -> DBSCAN, hierarchical clustering
# • Robustness to outliers -> k-medoids (PAM)
# • Unknown k -> DBSCAN, Gaussian mixtures with BIC

# ============================================================================

# Choosing k

# No labels, so we use heuristics
# • There is no ground truth to validate against
# • Internal indices measure cohesion and separation
# • Domain knowledge should always inform the final k

# The two workhorses:
# • Elbow - find where WCSS stops dropping sharply
# • Silhouette - maximise the average silhouette width

# ----------------------------------------------------------------------------

# The Elbow Method

# Figure: Elbow Plot (Total WCSS vs Number of Clusters k)
# X-axis: number of clusters k (1 to 8)
# Y-axis: total WCSS (drops sharply from ~196 at k=1, to ~103 at k=2, ~78 at k=3, ~56 at k=4)
# Dashed vertical line indicates the elbow at k = 4.
# WCSS always falls as k grows; the elbow marks diminishing returns - here k = 3-4.
# It is a judgement, not an optimisation.

# ----------------------------------------------------------------------------

# Silhouette analysis
# For point i, with a(i) = mean distance to its own cluster and b(i) =
# mean distance to the nearest other cluster:
#
#   s(i) = (b(i) - a(i)) / max{a(i), b(i)} in [-1, 1]
#
# • s(i) ≈ +1 - well inside its cluster
# • s(i) ≈ 0  - on a boundary; s(i) < 0 - likely in the wrong cluster
# Pick the k that maximises the average silhouette width (>0.5 is good).

# ----------------------------------------------------------------------------

# Within vs between variation
# The total spread splits cleanly in two:
#
#   TSS/total = WCSS/within + BCSS/between
#
#   BCSS = sum_(i=1->k) |S_i| * ||mu_i - mu||^2
#
# Minimising within-cluster variation is the same as maximising
# between-cluster separation. A high BCSS/TSS ratio signals well-
# separated clusters.

# ============================================================================

# Worked Example: USArrests

# The full workflow
# 50 US states; four variables: Murder, Assault, UrbanPop, Rape.
# 1. Explore the data and check scales
# 2. Standardise with scale()
# 3. Choose k via elbow + silhouette
# 4. Fit with kmeans(..., nstart = 25)
# 5. Evaluate with the BCSS/TSS ratio
# 6. Interpret profiles on the original scale

# ----------------------------------------------------------------------------

# Standardise, then fit
arrests <- scale(USArrests) # zero mean, unit sd
set.seed(2026)
km <- kmeans(arrests, centers = 4, nstart = 25)
km$size # cluster sizes

# [1] 13 13 16  8

# Four clusters of 13, 13, 16 and 8 states. Next: how well separated are they?

# ----------------------------------------------------------------------------

# Figure: 2D Principal Component Projection (PC1 vs PC2)
# X-axis: PC1 (-2 to 4)
# Y-axis: PC2 (-2 to 2)
# Shows ellipses encircling the 4 clusters:
# - Grey ellipse (top left)
# - Red/pink ellipse (bottom left)
# - Orange ellipse (top middle)
# - Green ellipse (right)
# About 71% of variance is between clusters. Points are projected
# onto the first two principal components (Unit 10); the four profiles
# separate clearly.

# ----------------------------------------------------------------------------

# Profiling on the original scale
round(aggregate(USArrests, list(Cl = km$cluster), mean))

#   Cl Murder Assault UrbanPop Rape
# 1  1     11     257       76   33
# 2  2      4      79       52   12
# 3  3      6     139       74   19
# 4  4     14     244       54   21

# Note cluster 4: a distinct high-crime, low-urban group.

# ============================================================================

# Summary

# Key takeaways
# 1. K-means minimises WCSS - squared distance to cluster centres
# 2. It alternates assignment (nearest centre) and update (cluster mean)
# 3. It reaches a local optimum - use nstart = 25
# 4. It assumes spherical, similar-sized clusters -> scale first
# 5. Choose k with the elbow and silhouette, guided by domain knowledge
```[cite: 113, 114, 116, 117, 118, 120, 122, 123, 125, 126, 128, 129, 130, 131, 133, 134, 135, 136, 137]