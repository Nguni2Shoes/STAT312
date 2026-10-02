# =============================================================================
# =============================================================================

#                               Notes:
#                         K-Means Clustering
#                       Chapter 9 Class Notes
#                    Dr Stéfan Janse van Rensburg
#                                2026

# =============================================================================
# =============================================================================

# Contents
# 1 Introduction
# 2 Mathematical Foundation
# 2.1 Objective Function
# 2.2 Cluster Centroids
# 2.3 Distance Metric
# 3 The K-Means Algorithm
# 3.1 Initialisation
# 3.2 Assignment Step
# 3.3 Update Step
# 3.4 Convergence
# 4 Properties and Assumptions
# 4.1 Convergence Guarantees
# 4.2 Implicit Assumptions
# 4.3 Sensitivity to Outliers
# 5 Determining the Number of Clusters
# 5.1 The Elbow Method
# 5.2 Silhouette Analysis
# 5.3 Additional Indices
# 6 Evaluation Metrics
# 6.1 Within-Cluster Sum of Squares
# 6.2 Between-Cluster Sum of Squares
# 6.3 Silhouette Score
# 6.4 Calinski-Harabasz Index (NOT EXAMINABLE)
# 6.5 Davies-Bouldin Index (NOT EXAMINABLE)
# 7 Practical Implementation in R
# 7.1 Data Preparation and Exploration
# 7.2 Feature Standardisation
# 7.3 Determining the Optimal Number of Clusters
# 7.3.1 Elbow Method
# 7.3.2 Silhouette Analysis
# 7.4 Fitting the K-Means Model
# 7.5 Evaluating Cluster Quality
# 7.6 Visualising Clustering Results
# 7.7 Interpreting Cluster Characteristics
# 7.8 Summary
# 8 Limitations and Considerations
# 9 Applications
# 10 Conclusion

# =============================================================================

# 1 Introduction

# Clustering represents a fundamental category of unsupervised learning techniques designed
# to discover natural groupings within data without predefined labels. Unlike supervised
# learning methods such as regression and classification, clustering algorithms explore intrinsic
# data structures to partition observations into meaningful subgroups based solely on feature
# similarities.

# K-means clustering stands as one of the most widely applied partitioning methods due to
# its computational efficiency and intuitive geometric interpretation. The algorithm partitions
# n observations into k distinct clusters such that observations within each cluster exhibit
# greater similarity to one another than to observations in other clusters. This approach proves
# particularly valuable in market segmentation, document classification, image compression,
# and pattern recognition applications.

# Clustering vs Classification
# Classification assigns observations to predefined categories using labelled training data,
# whilst clustering discovers previously unknown groupings from unlabelled observations.
# Clustering serves exploratory purposes, revealing hidden structures that may inform
# subsequent supervised learning tasks.

# =============================================================================

# 2 Mathematical Foundation

# 2.1 Objective Function
# Definition: The k-means clustering objective seeks to minimise the within-cluster sum of
# squared distances between observations and their assigned cluster centroids.

# Given a dataset with n observations {x1, x2, ..., xn} where each xi in R^d represents a d-dimen-
# sional feature vector, k-means partitions these observations into k clusters S = {S1, S2, ..., Sk}.
# The algorithm minimises the within-cluster sum of squares (WCSS):

#   arg min_S sum_(i=1->k) sum_(x in S_i) ||x - mu_i||^2

# where mu_i denotes the centroid (mean vector) of cluster S_i. This objective function quantifies
# cluster compactness by measuring total squared distances between observations and their
# respective cluster centres. Lower WCSS values indicate tighter, more cohesive clusters.

# 2.2 Cluster Centroids
# The centroid of cluster S_i represents the multivariate mean of all observations assigned to that
# cluster:

#   mu_i = (1 / |S_i|) * sum_(x in S_i) x

# where |S_i| denotes the number of observations in cluster S_i. Each centroid serves as the
# prototype or representative point for its cluster. The k-means algorithm iteratively updates
# these centroids to minimise the objective function.

# 2.3 Distance Metric
# K-means employs Euclidean distance as the standard dissimilarity measure between obser-
# vations. For two d-dimensional vectors x and y, the Euclidean distance computes as:

#   d(x, y) = sqrt(sum_(j=1->d) (x_j - y_j)^2) = ||x - y||

# This metric assumes that all features contribute equally to dissimilarity calculations. Conse-
# quently, feature scaling becomes essential when variables exhibit different measurement
# units or variances. Standardisation transforms features to have zero mean and unit variance,
# preventing variables with larger scales from dominating distance computations.

# Feature Scaling
# Always standardise your data before applying k-means clustering. Variables measured
# on different scales will dominate the distance calculations. For example, income measured
# in thousands will overwhelm age measured in years, producing misleading clusters based
# primarily on the high-variance variable.

# =============================================================================

# 3 The K-Means Algorithm

# The k-means algorithm employs an iterative refinement strategy to partition observations into
# clusters. The procedure alternates between two fundamental steps: assigning observations
# to their nearest centroids and recalculating centroids based on current cluster memberships.
# This iterative process continues until convergence, defined as the point at which cluster
# assignments stabilise between successive iterations.

# Algorithm: K-Means Clustering
# Input: Data matrix X, number of clusters k. Output: Cluster assignments C, centroids
# mu_1, ..., mu_k
# 1. Initialise k centroids mu_1, ..., mu_k randomly from X.
# 2. Repeat until the centroids no longer change:
#    a. Assignment step - for each observation x_i, assign it to cluster j where j =
#       arg min_l ||x_i - mu_l||^2
#    b. Update step - for each cluster j = 1, ..., k, recalculate mu_j as the mean of all obser-
#       vations assigned to cluster j.
# 3. Return cluster assignments C and centroids mu_1, ..., mu_k.

# 3.1 Initialisation
# The algorithm commences by selecting k initial centroid positions. The simplest approach
# randomly selects k observations from the dataset to serve as starting centroids. However,
# alternative initialisation methods such as k-means++ can improve clustering outcomes by
# strategically spreading initial centroids across the feature space. The k-means++ method
# selects subsequent centroids with probability proportional to their squared distance from
# existing centroids, reducing sensitivity to poor starting configurations. R's kmeans() function
# implements these improved initialisation strategies alongside the basic random approach.

# 3.2 Assignment Step
# During each iteration's assignment phase, the algorithm evaluates the distance from every
# observation to each current centroid. Each observation receives assignment to the cluster
# corresponding to its nearest centroid:

#   C(x_i) = arg min_(j in {1, ..., k}) ||x_i - mu_j||

# where C(x_i) denotes the cluster assignment for observation i. This step creates a Voronoi
# partition of the feature space, dividing it into regions where all points within a region share
# the same nearest centroid.

# Voronoi partitions
# Voronoi partitions divide space into regions around a set of centroids. Each region
# includes all locations closest to its own centroid. In k-means clustering, the assignment
# step creates a Voronoi partition where each region is a cluster, meaning all observations
# within a region are assigned to the same cluster because they share the same nearest
# centroid.

# 3.3 Update Step
# Following assignment, the algorithm recalculates each centroid as the mean of all observations
# currently assigned to that cluster:

#   mu_j^(new) = (1 / |S_j|) * sum_(x_i in S_j) x_i

# This update minimises the within-cluster sum of squares for the current partition. The mean
# represents the point that minimises total squared distances to all cluster members, providing
# the optimal centroid location given fixed cluster assignments.

# 3.4 Convergence
# The algorithm iterates between assignment and update steps until cluster assignments
# stabilise. Convergence occurs when no observations change cluster membership between
# consecutive iterations, or equivalently, when centroid positions cease changing. K-means
# guarantees convergence to a local minimum of the objective function, typically within a modest
# number of iterations for well-structured datasets.

# Local Optima
# K-means converges to a local minimum, not necessarily the global minimum. Different
# initialisations may converge to different solutions with varying quality. Always run k-
# means multiple times with different random starts (use the nstart parameter in R) and
# select the solution with the lowest WCSS.

# =============================================================================

# 4 Properties and Assumptions

# 4.1 Convergence Guarantees
# K-means guarantees monotonic decrease in the objective function across iterations. Each
# assignment step minimises WCSS given fixed centroids, whilst each update step minimises
# WCSS given fixed assignments. This coordinate descent strategy ensures convergence to a
# local minimum in finite time, typically requiring fewer than 50 iterations for moderately sized
# datasets. The algorithm must terminate because the number of possible partitions remains
# finite and WCSS strictly decreases until stabilisation occurs.

# Monotonic Decrease
# A sequence exhibits monotonic decrease when each successive value is less than or equal
# to the previous value, never increasing. In k-means clustering, the WCSS either decreases
# or remains constant at each iteration but never increases, guaranteeing progression
# towards a local minimum.

# 4.2 Implicit Assumptions
# K-means makes several implicit assumptions about cluster structure that may not hold for
# all datasets. The algorithm assumes clusters exhibit roughly spherical shapes in the feature
# space. This assumption arises from the Euclidean distance metric, which defines circular (in
# 2D) or spherical (in higher dimensions) decision boundaries around centroids.

# The method further assumes relatively equal cluster sizes and densities. The algorithm strug-
# gles when clusters exhibit substantially different sizes or variances. Large, diffuse clusters may
# fragment into multiple smaller clusters, whilst small, compact clusters may merge with larger
# neighbours. These biases stem from k-means' reliance on squared Euclidean distances, which
# penalise large deviations more severely than small ones.

# K-means performs poorly for clusters with non-convex shapes. The algorithm cannot capture
# elongated, curved, or irregularly shaped groupings effectively. Alternative methods such as
# Density-Based Spatial Clustering of Applications with Noise (DBSCAN) or hierarchical clus-
# tering better accommodate non-spherical cluster geometries.

# Convex vs Non-Convex Shapes
# Convex shapes are those where a straight line between any two interior points stays
# entirely inside the shape (like a circle or rectangle). Non-convex (or concave) shapes have
# indentations, meaning a line segment between two interior points might go outside the
# boundary (like a crescent).

# 4.3 Sensitivity to Outliers
# Outlying observations exert disproportionate influence on k-means results due to squared
# distances in the objective function. A single extreme outlier can substantially distort centroid
# positions, potentially creating spurious clusters or fragmenting natural groupings. Preliminary
# outlier detection and removal often improves clustering quality for contaminated datasets.

# =============================================================================

# 5 Determining the Number of Clusters

# Selecting an appropriate number of clusters k represents the most challenging aspect of
# k-means clustering. Unlike supervised learning where performance metrics guide model
# selection, clustering lacks an obvious "ground truth" for validation. Several heuristic methods
# assist practitioners in choosing k, though no universally optimal approach exists.

# Ground Truth
# The ground truth is the actual, correct cluster labels for a dataset. In supervised learning,
# the ground truth is known, allowing direct performance evaluation. However, in cluster-
# ing, the ground truth is usually unknown. We don't know the "correct" number of clusters
# or their true membership.

# 5.1 The Elbow Method
# The elbow method plots total WCSS against the number of clusters k. WCSS decreases
# monotonically as k increases, since adding clusters always provides more degrees of freedom
# to fit the data. The plot typically exhibits a characteristic "elbow" shape, with rapid WCSS
# decreases for small k values followed by diminishing returns for larger k.

# Definition: The elbow point represents the k value beyond which additional clusters yield
# only marginal reductions in WCSS. This point suggests a reasonable balance between model
# complexity (number of clusters) and data fit (WCSS).

# Identifying the elbow involves subjective judgement, as the transition from steep to gradual
# WCSS decline rarely occurs at a single sharp point. Different analysts may reasonably select
# different k values from the same elbow plot. Despite this subjectivity, the elbow method
# provides useful guidance and remains widely employed in practice.

# library(factoextra)
# Elbow method using factoextra
# fviz_nbclust(scaled_data, kmeans, method = "wss",
#              nstart = 25, k.max = 10) +
#   labs(title = "Elbow Method for Optimal k",
#        x = "Number of Clusters (k)",
#        y = "Total Within-Cluster Sum of Squares") +
#   theme_minimal()

# 5.2 Silhouette Analysis
# Silhouette analysis evaluates clustering quality by measuring how well each observation
# fits within its assigned cluster compared to neighbouring clusters. This method produces a
# silhouette coefficient for each individual observation, with the average across all observations
# providing an overall quality assessment.

# For observation i in cluster C_i the silhouette coefficient (also called silhouette width) computes
# as:

#   s(i) = (b(i) - a(i)) / max{a(i), b(i)}

# where a(i) represents the average distance from observation i to all other observations in its
# own cluster, and b(i) represents the average distance from observation i to observations in
# the nearest neighbouring cluster.

# Figure 1: Silhouette coefficient components for observation i. The coefficient s(i) = (b(i) -
# a(i)) / max{a(i), b(i)} measures how well i fits within its assigned cluster.
# Illustration showing Cluster 1 containing observation i (red) with distances to points in the same
# cluster representing a(i), and dashed lines connecting to points in Cluster 2 representing b(i).

# Individual silhouette coefficients range from -1 to +1. Values near +1 indicate excellent cluster
# assignment, with the observation lying far from neighbouring clusters. Values near 0 suggest
# the observation lies on the boundary between clusters. Negative values indicate potential
# misclassification, with the observation possibly belonging to a neighbouring cluster.

# Whilst individual coefficients diagnose specific observations, the average silhouette width
# summarises overall clustering quality by computing the mean coefficient across all observa-
# tions. Higher average silhouette widths indicate better-defined clusters. Plotting average
# silhouette width against k helps identify the number of clusters that maximises cluster sepa-
# ration and cohesion.

# Silhouette analysis using factoextra
# fviz_nbclust(scaled_data, kmeans, method = "silhouette",
#              nstart = 25, k.max = 10) +
#   labs(title = "Silhouette Analysis for Optimal k",
#        x = "Number of Clusters (k)",
#        y = "Average Silhouette Width") +
#   theme_minimal()

# 5.3 Additional Indices
# The Davies-Bouldin index and Calinski-Harabasz index (discussed in the next section) can also
# assist in selecting the optimal number of clusters. Plot these indices across different values of
# k, selecting the k that minimises the Davies-Bouldin index or maximises the Calinski-Harabasz
# index. These indices provide alternative perspectives on cluster quality, and examining multi-
# ple criteria often yields more robust k selection than relying on any single method.

# =============================================================================

# 6 Evaluation Metrics

# Assessing clustering quality proves challenging without external validation labels. Internal
# validation indices evaluate cluster quality based solely on the clustered data. This section
# presents the most commonly used metrics for evaluating k-means clustering results.

# 6.1 Within-Cluster Sum of Squares
# The WCSS serves as k-means' objective function and provides the most direct quality
# measure:

#   WCSS = sum_(i=1->k) sum_(x in S_i) ||x - mu_i||^2

# Lower WCSS indicates more compact, homogeneous clusters. However, WCSS decreases
# monotonically with increasing k, precluding its use as a standalone criterion for selecting the
# optimal number of clusters. The elbow method addresses this limitation by seeking dimin-
# ishing returns in WCSS reduction.

# 6.2 Between-Cluster Sum of Squares
# Complementing WCSS, the between-cluster sum of squares (BCSS) quantifies separation
# between cluster centroids:

#   BCSS = sum_(i=1->k) |S_i| * ||mu_i - mu||^2

# where mu denotes the grand mean across all observations. Higher BCSS values indicate
# greater separation between clusters. The total sum of squares satisfies TSS = WCSS + BCSS,
# establishing that minimising within-cluster variation equivalently maximises between-cluster
# variation.

# 6.3 Silhouette Score
# The silhouette coefficient, introduced earlier, evaluates individual observation clustering qual-
# ity. The average silhouette width provides an overall assessment ranging from -1 to +1, with
# values above 0.5 generally indicating reasonable cluster structure. Silhouette plots visualise
# the distribution of silhouette coefficients across observations, revealing potential misclassifi-
# cations and cluster quality heterogeneity.

# 6.4 Calinski-Harabasz Index (NOT EXAMINABLE)
# The Calinski-Harabasz index (also called the variance ratio criterion) computes the ratio of
# between-cluster to within-cluster dispersion, adjusted for degrees of freedom:

#   CH(k) = (BCSS / (k - 1)) / (WCSS / (n - k))

# where n represents the total number of observations. Higher CH values indicate better-
# defined clusters with greater between-cluster separation relative to within-cluster variation.
# This index proves particularly useful when comparing clusterings with different k values.

# 6.5 Davies-Bouldin Index (NOT EXAMINABLE)
# The Davies-Bouldin index assesses clustering quality by measuring the average similarity ratio
# between each cluster and its most similar cluster:

#   DB = (1 / k) * sum_(i=1->k) max_(j != i) ((d_bar_i + d_bar_j) / d_ij)

# where d_bar_i denotes average within-cluster distance for cluster i, and d_ij represents the distance
# between centroids mu_i and mu_j. Lower DB values indicate better clustering, with well-sepa-
# rated clusters exhibiting small within-cluster distances and large between-cluster centroid
# distances.

# =============================================================================

# 7 Practical Implementation in R

# This section demonstrates k-means clustering on a real dataset, illustrating the complete
# analytical workflow from data preparation through interpretation. We employ the USArrests
# dataset, which contains crime statistics for 50 US states across four variables: murder rate,
# assault rate, urban population percentage, and rape rate. This dataset provides a substantive
# example for exploring how states cluster based on crime patterns.

library(tidyverse)
library(factoextra)
library(cluster)

# 7.1 Data Preparation and Exploration
# We commence by loading and examining the dataset structure. The USArrests data frame
# contains 50 observations (states) and 4 numerical variables suitable for clustering analysis.

# Load the dataset
data("USArrests")

# Examine structure
str(USArrests)

# 'data.frame': 50 obs. of  4 variables:
#  $ Murder  : num  13.2 10 8.1 8.8 9 7.9 3.3 5.9 15.4 17.4 ...
#  $ Assault : int  236 263 294 190 276 204 110 238 335 211 ...
#  $ UrbanPop: int  58 48 80 50 91 78 77 72 80 60 ...
#  $ Rape    : num  21.2 44.5 31 19.5 40.6 38.7 11.1 15.8 31.9 25.8 ...

# Summary statistics
summary(USArrests)

#      Murder          Assault         UrbanPop          Rape      
#  Min.   : 0.800   Min.   : 45.0   Min.   :32.00   Min.   : 7.30  
#  1st Qu.: 4.075   1st Qu.:109.0   1st Qu.:54.50   1st Qu.:15.07  
#  Median : 7.250   Median :159.0   Median :66.00   Median :20.10  
#  Mean   : 7.788   Mean   :170.8   Mean   :65.54   Mean   :21.23  
#  3rd Qu.:11.250   3rd Qu.:249.0   3rd Qu.:77.75   3rd Qu.:26.18  
#  Max.   :17.400   Max.   :337.0   Max.   :91.00   Max.   :46.00  

# Initial exploration reveals that variables exhibit substantially different scales. Murder and rape
# rates range from single digits to low double digits, whilst assault rates extend into hundreds.
# Urban population percentages span 30 to 90. These scale differences necessitate standardi-
# sation before clustering.

# Check for missing values
sum(is.na(USArrests))
# [1] 0

# Examine variable scales
apply(USArrests, 2, sd)
#    Murder   Assault  UrbanPop      Rape 
#  4.355510 83.337661 14.474763  9.366385 

# =============================================================================

# 7.2 Feature Standardisation
# We standardise all variables to have zero mean and unit variance, ensuring equal contribution
# to distance calculations.

# Standardise the data
arrests_scaled <- scale(USArrests)

# Verify standardisation
colMeans(arrests_scaled) # Should be approximately zero
#        Murder       Assault      UrbanPop          Rape 
# -7.667478e-17  1.111611e-16 -4.332645e-16  8.938163e-17 

apply(arrests_scaled, 2, sd) # Should be one
#   Murder  Assault UrbanPop     Rape 
#        1        1        1        1 

# Convert to data frame for convenience
arrests_scaled <- as.data.frame(arrests_scaled)

# =============================================================================

# 7.3 Determining the Optimal Number of Clusters
# We employ both the elbow method and silhouette analysis to identify the optimal number of
# clusters. These complementary approaches provide robust guidance for selecting k.

# 7.3.1 Elbow Method
# The elbow method plots total within-cluster sum of squares against the number of clusters,
# seeking the point where additional clusters yield diminishing returns.

# Set seed for reproducibility
set.seed(20251006)

# Elbow method
fviz_nbclust(arrests_scaled, kmeans, method = "wss",
             nstart = 25, k.max = 10) +
  labs(title = "Elbow Method for USArrests Data",
       x = "Number of Clusters (k)",
       y = "Total Within-Cluster Sum of Squares") +
  theme_minimal()

# Figure: Elbow Method for USArrests Data
# Line plot of Number of Clusters (k = 1 to 10) vs Total Within-Cluster Sum of Squares (WCSS).
# Drops sharply from ~196 at k = 1 to ~103 at k = 2, then ~78 at k = 3, ~56 at k = 4, flattening out towards k = 10 (~26).
# The elbow plot suggests k = 3 or k = 4 as reasonable choices, with diminishing WCSS reduc-
# tions beyond these values.

# 7.3.2 Silhouette Analysis
# Silhouette analysis evaluates cluster quality by measuring how well observations fit within
# their assigned clusters compared to neighbouring clusters.

# Silhouette method
fviz_nbclust(arrests_scaled, kmeans, method = "silhouette",
             nstart = 25, k.max = 10) +
  labs(title = "Silhouette Analysis for USArrests Data",
       x = "Number of Clusters (k)",
       y = "Average Silhouette Width") +
  theme_minimal()

# Figure: Silhouette Analysis for USArrests Data
# Plot of Number of Clusters (k = 1 to 10) vs Average Silhouette Width.
# Distinct peak at k = 2 (width ~ 0.41 marked with vertical dashed line), followed by a secondary peak at k = 4 (~ 0.34).
# The silhouette analysis indicates maximum average silhouette width at k = 2, though k = 3
# also demonstrates reasonable cluster separation. Given the elbow method's suggestion and
# the desire for meaningful state groupings, we proceed with k = 4 to capture greater detail in
# crime patterns.

# =============================================================================

# 7.4 Fitting the K-Means Model
# We fit the k-means algorithm with k = 4 clusters, employing 25 random initialisations to
# mitigate sensitivity to starting positions. The nstart parameter ensures we obtain a high-
# quality solution by selecting the best result across multiple runs.

# Set seed for reproducibility
set.seed(20251006)

# Fit k-means with k = 4
kmeans_arrests <- kmeans(arrests_scaled, centers = 4, nstart = 25)

# Examine cluster sizes
kmeans_arrests$size
# [1] 13 13 16  8

# View cluster centres (standardised scale)
kmeans_arrests$centers

#       Murder    Assault   UrbanPop        Rape
# 1  0.6950701  1.0394414  0.7226370  1.27693964
# 2 -0.9615407 -1.1066010 -0.9301069 -0.96676331
# 3 -0.4894375 -0.3826001  0.5758298 -0.26165379
# 4  1.4118898  0.8743346 -0.8145211  0.01927104

# The cluster centres reveal distinct crime profiles.
# • Cluster 1: High violent crime rates combined with high urbanisation
# • Cluster 2: Low violent crime rates with low urbanisation
# • Cluster 3: Low violent crime rates with moderate-to-high urbanisation
# • Cluster 4: High violent crime rates despite low urbanisation
# Cluster sizes range from 8 to 16 states, indicating relatively balanced partitions.

# =============================================================================

# 7.5 Evaluating Cluster Quality
# We assess clustering quality using multiple metrics introduced in Section 6, providing com-
# prehensive evaluation of the partition quality.

# Within-cluster sum of squares
kmeans_arrests$tot.withinss
# [1] 56.40317

# Between-cluster sum of squares
kmeans_arrests$betweenss
# [1] 139.5968

# Ratio of between-cluster to total sum of squares
kmeans_arrests$betweenss / kmeans_arrests$totss
# [1] 0.7122287

# The between-cluster to total sum of squares ratio indicates that approximately 71% of total
# variance resides between clusters, suggesting reasonable cluster separation. We can further
# evaluate quality using silhouette scores for individual observations.

# Compute silhouette scores
sil <- silhouette(kmeans_arrests$cluster, dist(arrests_scaled))

# Average silhouette width
mean(sil[, 3])
# [1] 0.3396889

# Visualise silhouette plot
fviz_silhouette(sil) +
  theme_minimal()

#   cluster size ave.sil.width
# 1       1   13          0.27
# 2       2   13          0.37
# 3       3   16          0.34
# 4       4    8          0.39

# Figure: Clusters silhouette plot
# Average silhouette width: 0.34 (marked with horizontal dashed line).
# Silhouette bars displayed across clusters 1 to 4:
# Cluster 1 (red, size 13, ave 0.27; has a couple of slight negative bars at the right edge)
# Cluster 2 (green, size 13, ave 0.37)
# Cluster 3 (cyan, size 16, ave 0.34)
# Cluster 4 (purple, size 8, ave 0.39)
# The average silhouette width of approximately 0.34 indicates fair cluster structure. The
# silhouette plot reveals some observations with negative coefficients, suggesting potential
# misclassifications, though most observations demonstrate positive values indicating appro-
# priate cluster assignment.

# =============================================================================

# 7.6 Visualising Clustering Results
# Visualisation provides intuitive understanding of cluster structure and relationships. The
# factoextra package facilitates comprehensive visualisation of clustering results.

# Cluster visualisation
fviz_cluster(
  kmeans_arrests, data = arrests_scaled,
  geom = "point", ellipse.type = "convex",
  palette = "jco", ggtheme = theme_minimal(),
  main = "K-Means Clustering of US States by Crime Rates")

# Figure: K-Means Clustering of US States by Crime Rates
# PCA projection of the 4 clusters across Dim1 (62%) and Dim2 (24.7%):
# Cluster 1 (blue circles, convex hull on upper left)
# Cluster 2 (yellow triangles, convex hull on middle/lower right)
# Cluster 3 (grey squares, convex hull on upper center/right)
# Cluster 4 (pink crosses, convex hull on lower center)
# The cluster plot employs principal component analysis (PCA) for dimensionality reduction,
# which we will discuss in the next chapter. Clusters exhibit reasonable separation, which is
# consistent with the moderate silhouette scores observed previously.

# =============================================================================

# 7.7 Interpreting Cluster Characteristics
# Understanding cluster composition requires examining the original (unstandardised) variable
# means for each cluster. This interpretation connects statistical groupings to substantive crime
# patterns.

# Add cluster assignments to original data
arrests_with_clusters <- USArrests |>
  mutate(Cluster = factor(kmeans_arrests$cluster),
         State = rownames(USArrests))

# Compute cluster means on original scale
cluster_profiles <- arrests_with_clusters |>
  group_by(Cluster) |>
  summarise(
    n_states = n(),
    Murder = mean(Murder),
    Assault = mean(Assault),
    UrbanPop = mean(UrbanPop),
    Rape = mean(Rape)
  )
cluster_profiles

# # A tibble: 4 × 6
#   Cluster n_states Murder Assault UrbanPop  Rape
#   <fct>      <int>  <dbl>   <dbl>    <dbl> <dbl>
# 1 1             13  10.8    257.      76    33.2
# 2 2             13   3.6     78.5     52.1  12.2
# 3 3             16   5.66   139.      73.9  18.8
# 4 4              8  13.9    244.      53.8  21.4

# The cluster profiles reveal distinct crime patterns characterised by varying combinations of
# violent crime rates and urbanisation levels:
# • Cluster 1 (13 states): High violent crime across all categories (murder: 10.8, assault: 257,
#   rape: 33.2) combined with high urbanisation (76%). This cluster represents highly urbanised
#   states with elevated crime rates across multiple dimensions.
# • Cluster 2 (13 states): Low crime rates across all categories (murder: 3.6, assault: 78.5,
#   rape: 12.2) with moderate-to-low urbanisation (52%). These states exhibit the safest crime
#   profiles with consistently low violent crime indicators.
# • Cluster 3 (16 states): Moderate crime rates (murder: 5.7, assault: 139, rape: 18.8) with
#   high urbanisation (74%). These states demonstrate moderate violent crime levels despite
#   substantial urban populations, suggesting effective crime management relative to urbani-
#   sation levels.
# • Cluster 4 (8 states): Very high violent crime rates (murder: 13.9, assault: 244, rape: 21.4)
#   despite low urbanisation (54%). This cluster identifies predominantly rural states experi-
#   encing disproportionately high violent crime, representing a concerning pattern where low
#   urbanisation does not correspond with reduced crime.

# We examine which states belong to each cluster to validate these interpretations and assess
# substantive meaningfulness.

# Urban states in high-crime cluster (Cluster 1)
arrests_with_clusters |>
  filter(Cluster == 1) |>
  select(State, Murder, Assault, Rape) |>
  arrange(desc(Murder))

# State          Murder Assault  Rape
# Florida          15.4     335  31.9
# Texas            12.7     201  25.5
# Nevada           12.2     252  46.0
# Michigan         12.1     255  35.1
# New Mexico       11.4     285  32.1
# Maryland         11.3     300  27.8
# New York         11.1     254  26.1
# Illinois         10.4     249  24.0
# Alaska           10.0     263  44.5
# California        9.0     276  40.6
# Missouri          9.0     178  28.2
# Arizona           8.1     294  31.0
# Colorado          7.9     204  38.7

# Rural states in high-crime cluster (Cluster 4)
arrests_with_clusters |>
  filter(Cluster == 4) |>
  select(State, Murder, Assault, Rape) |>
  arrange(desc(Murder))

# State          Murder Assault  Rape
# Georgia          17.4     211  25.8
# Mississippi      16.1     259  17.1
# Louisiana        15.4     249  22.2
# South Carolina   14.4     279  22.5
# Alabama          13.2     236  21.2
# Tennessee        13.2     188  26.9
# North Carolina   13.0     337  16.1
# Arkansas          8.8     190  19.5

# Cluster 1 contains states such as Florida, Nevada, and California; large, highly urbanised states
# historically associated with elevated crime rates. Cluster 4 includes states with high violent
# crime despite lower urbanisation, representing a distinct crime pattern. This substantive
# validation supports the clustering's ability to identify meaningful state groupings based on
# multidimensional crime characteristics beyond simple urban-rural distinctions.

# =============================================================================

# 7.8 Summary
# This practical demonstration illustrated the complete k-means clustering workflow using real
# crime data. Key steps included feature standardisation to address scale differences, employing
# multiple methods (elbow and silhouette) to determine optimal cluster number, fitting the
# model with multiple random starts, evaluating cluster quality through various metrics, and
# interpreting results in the original data context. The analysis revealed four distinct state
# groupings based on crime patterns, demonstrating k-means clustering's utility for exploratory
# data analysis and pattern discovery in multivariate datasets.

# =============================================================================

# 8 Limitations and Considerations

# K-means clustering exhibits several important limitations discussed throughout this chapter.
# The algorithm assumes spherical clusters of similar sizes and densities, struggles with outliers
# due to squared distances in the objective function, requires specifying k in advance without
# universally optimal selection methods, and converges only to local rather than global optima.
# Alternative methods such as DBSCAN or hierarchical clustering may prove more suitable for
# datasets with non-spherical geometries, extreme outliers, or highly variable cluster densities.
# Understanding these constraints guides appropriate method selection for specific data char-
# acteristics.

# =============================================================================

# 9 Applications

# K-means clustering finds application across diverse domains. Market segmentation partitions
# customers based on purchasing behaviour and demographic characteristics, enabling targeted
# marketing strategies. Image compression reduces colour palettes by clustering similar colours
# and replacing each pixel with its nearest cluster centroid, substantially reducing storage
# requirements whilst preserving visual quality. Document classification groups similar texts by
# topic, sentiment, or theme without requiring manual labelling. Anomaly detection identifies
# unusual observations far from all cluster centroids, supporting fraud detection, quality control,
# and network security monitoring. Genomic data analysis clusters genes with similar expres-
# sion patterns, revealing co-regulated biological processes and disease subtypes with distinct
# molecular characteristics.

# =============================================================================

# 10 Conclusion

# K-means clustering provides a computationally efficient approach to unsupervised learning,
# revealing natural groupings within unlabelled data. The algorithm's simplicity, interpretability,
# and scalability explain its enduring popularity across numerous domains. However, successful
# application requires awareness of the method's assumptions about cluster geometry, careful
# preprocessing including feature scaling and outlier handling, and consideration of multiple
# evaluation criteria when selecting the number of clusters. Understanding both strengths and
# limitations enables practitioners to select appropriate methods for specific analytical objec-
# tives.
```[cite: 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67]