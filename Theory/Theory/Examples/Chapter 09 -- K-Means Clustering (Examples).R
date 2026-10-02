## ============================================================================
## ============================================================================

##                          Worked Examples & Exercises: 
##                    STAT312 Learning Unit 9 - K-Means Clustering
##                    Dr Stéfan Janse van Rensburg
##                Department of Statistics Faculty of Science
##                                 2026

## ============================================================================
## ============================================================================

# How to use these
# • Each example states a problem - try it before the reveal
# • Worked solutions appear in the lecturer copy (the amber boxes)
# • Code is real and runs against USArrests and the customer CLV
#   data

# ============================================================================

# Example 1 · Why we standardise

# Distances before and after scaling
# Compute each variable's standard deviation in USArrests. Which one
# would dominate the Euclidean distance if we did not scale?

data("USArrests")
round(apply(USArrests, 2, sd), 1)

# Murder  Assault UrbanPop     Rape 
#    4.4     83.3     14.5      9.4 

# Answer:
# Assault has by far the largest standard deviation (83.3) compared to the 
# others (4.4 to 14.5). Without scaling, squared differences along the Assault 
# axis would completely dominate the Euclidean distance calculation, rendering 
# variables like Murder and Rape practically negligible in forming clusters.

# ============================================================================

# Example 2 · Choosing k by the elbow

# Plot WCSS against k
# Fit k-means for k = 1, ..., 8 on the scaled data and plot total WCSS.

library(tidyverse)

arrests <- scale(USArrests)
set.seed(2026)
wss <- map_dbl(1:8, \(k) kmeans(arrests, k, nstart = 25)$tot.withinss)

# Figure: Elbow Plot (Total WCSS vs number of clusters k)
# X-axis: number of clusters k (1 to 8)
# Y-axis: total WCSS (drops sharply from ~196 at k = 1 to ~103 at k = 2,
# ~78 at k = 3, ~56 at k = 4, then levels off towards ~35 at k = 8)
# An elbow is observed around k = 3 to 4, indicating diminishing returns in WCSS reduction.

# ============================================================================

# Example 3 · Confirming k with the silhouette

# Average silhouette width by k
# Use cluster::silhouette() to find the best k.

library(cluster)

# asw(): helper function to calculate mean silhouette for a given k
asw <- function(k) {
  km <- kmeans(arrests, centers = k, nstart = 25)
  sil <- silhouette(km$cluster, dist(arrests))
  mean(sil[, 3])
}

set.seed(2026)
sil <- sapply(2:6, asw)
round(setNames(sil, 2:6), 3)

#     2     3     4     5     6 
# 0.408 0.309 0.340 0.303 0.286 

# Answer:
# The average silhouette width is highest at k = 2 (0.408), with a secondary peak 
# at k = 4 (0.340). While k = 2 gives the mathematically cleanest separation, 
# k = 4 is frequently preferred in practice to identify richer multidimensional crime profiles.

# ============================================================================

# Example 4 · Fit and profile

# Fit k-means and read the profiles
# Fit with nstart = 25, then read cluster means on the original scale.

set.seed(2026)
km <- kmeans(arrests, centers = 4, nstart = 25)
prof <- aggregate(USArrests, list(Cluster = km$cluster), mean)
prof

#   Cluster   Murder   Assault UrbanPop     Rape
# 1       1 10.81538 257.38462 76.00000 33.19231
# 2       2  3.60000  78.53846 52.07692 12.17692
# 3       3  5.65625 138.87500 73.87500 18.78125
# 4       4 13.93750 243.62500 53.75000 21.41250

# ============================================================================

# Example 5 · Segmenting customers (CLV)

# Three behavioural features
# Cluster customers on scaled spend, frequency and order value into
# 3 segments.

# Note: Assuming 'clv' data frame is loaded with behavioural columns
# vars <- c("spend", "frequency", "order_value")
# feat <- scale(clv[vars]) # vars = 3 behavioural columns
# set.seed(2026)
# seg <- kmeans(feat, centers = 3, nstart = 25)
# seg_mean <- aggregate(clv["annual_spend"], list(Seg = seg$cluster), mean)
# seg_mean

# ============================================================================

# Your turn

# Exercise
# Using the CLV data, cluster customers on website_visits,
# mobile_sessions and email_opens (scaled) into 4 segments with
# nstart = 25.
# (a) Report the cluster sizes.
# (b) What proportion of total variance lies between clusters, and is
#     that good separation?

# Answer

# Code workflow:
# engagement_vars <- c("website_visits", "mobile_sessions", "email_opens")
# clv_scaled <- scale(clv[engagement_vars])
# set.seed(2026)
# km_clv <- kmeans(clv_scaled, centers = 4, nstart = 25)

# (a) Cluster sizes:
# km_clv$size

# (b) Proportion of total variance between clusters:
# bcss_tss_ratio <- km_clv$betweenss / km_clv$totss
# bcss_tss_ratio
# Interpretation: 
# The ratio (betweenss / totss) measures the fraction of total variance 
# explained by the cluster centroids. Values approaching 0.70 or higher (i.e. ~70%+) 
# generally reflect good cluster separation where between-cluster variance dominates 
# within-cluster dispersion.
```[cite: 173, 174, 176, 178, 180, 182, 184, 185]