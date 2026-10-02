# =============================================================================
# =============================================================================

#                               Notes:
#                         Density Estimation:
#             From Empirical Distributions to Kernel Smoothing
#                   Chapter 8 Supplement - Class Notes
#                     Dr Stéfan Janse van Rensburg
#                                 2026

# =============================================================================
# =============================================================================

# Contents
# Introduction: What Is Density Estimation?
# Part 1: The Empirical Cumulative Distribution Function
#   What Is the ECDF?
#   Why the ECDF Is Useful
# Part 2: Histograms as Density Estimators
#   How Histograms Work
#   The Connection to the ECDF
#   Choosing the Right Bin Width
# Part 3: Kernel Density Estimation
#   Moving Beyond Histograms
#   The KDE Formula
#   Common Kernel Functions
#   Choosing the Bandwidth
#   How KDE Relates to Histograms
# Practical Considerations
#   Edge Effects
#   Multivariate KDE
#   Bandwidth Selection via Cross-Validation
# Summary and Practical Guidance
#   The Progression of Techniques
#   When to Use Each Method
#   Implementation in R
# Conclusion

# =============================================================================

# Introduction: What Is Density Estimation?

# When we collect data, we often want to understand the underlying pattern or distribution that
# generated our observations. Density estimation helps us answer the question: "What does
# the shape of my data look like?"

# Unlike parametric methods (where we assume data follows a specific distribution like the
# normal distribution), non-parametric density estimation lets the data speak for itself. We
# build up a picture of the distribution directly from the observations without forcing it into a
# predetermined shape.

# Why Density Estimation Matters
# Imagine you're studying exam scores. Instead of assuming scores follow a bell curve,
# density estimation reveals the actual pattern. E.g., perhaps there are two peaks (students
# who studied well and those who didn't), or maybe scores cluster near the pass mark. This
# exploratory approach helps us discover unexpected patterns in our data.

# This chapter progresses through three increasingly sophisticated techniques:
# 1. The Empirical Cumulative Distribution Function (ECDF); our starting point
# 2. Histograms; a familiar visual tool
# 3. Kernel Density Estimation; a smooth, sophisticated method

# =============================================================================

# Part 1: The Empirical Cumulative Distribution Function

# What Is the ECDF?

# Suppose we have n observations: X1, X2, ..., Xn. The ECDF simply counts what fraction of our
# data falls at or below any value x:

#   ^F_n(x) = (Number of observations <= x) / n = (1/n) * sum_(i=1->n) I(Xi <= x)

# Here, I(Xi <= x) is an indicator function that equals 1 when Xi <= x and 0 otherwise.

# Example: Understanding the ECDF with a Simple Example
# Imagine we measure the heights of 5 students: 160, 165, 170, 175, 180 cm.
# • At x = 165: two students (160 and 165) are at or below this height
#   ^F_n(165) = 2/5 = 0.4
# • This means 40% of students are 165 cm or shorter
# The ECDF creates a step function that jumps up by 1/n at each observation.

# Example: ECDF Implementation in R
# We demonstrate ECDF construction using simulated data from a mixture distribution.

library(tidyverse)

# Generate mixed distribution data
set.seed(123)
n <- 500
x_mixture <- c(rnorm(n/2, mean = 0, sd = 1),
               rnorm(n/2, mean = 3, sd = 0.5))

# Compute and plot ECDF
ecdf_data <- tibble(x = x_mixture) |>
  arrange(x) |>
  mutate(cdf = row_number() / n)

ggplot(ecdf_data, aes(x = x, y = cdf)) +
  geom_step() +
  labs(
    title = "Empirical Cumulative Distribution Function",
    x = "Observed Values",
    y = "Cumulative Probability"
  ) +
  theme_minimal()

# Figure: Empirical Cumulative Distribution Function
# Step function plot of Observed Values (x: ~ -2 to 4) vs Cumulative Probability (y: 0.00 to 1.00)
# Shows an initial steep rise near 0, flattening slightly around 1.5 - 2, then rising steeply again near 3.
# The step function clearly reveals the bimodal structure of the underlying mixture distribution.

# Why the ECDF Is Useful
# The ECDF has excellent statistical properties:
# • It's unbiased: On average, ^F_n(x) equals the true cumulative probability F(x)
# • It's consistent: As we collect more data (n -> Inf), ^F_n(x) gets closer to the true F(x)
# • It follows a normal distribution (for large samples): This makes it useful for hypothesis
#   testing

# From CDF to Density
# The true probability density function f(x) is the derivative of the CDF, f(x) = F'(x). So
# to get a density from our ECDF, we need to differentiate it.
# 
# The problem: The ECDF is a step function with jumps. Its derivative consists of spikes
# (called Dirac delta functions) at each data point and is zero everywhere else. This isn't
# helpful for visualising or understanding our data's distribution!
# 
# The solution: We need smoothing techniques. Enter histograms and kernel density esti-
# mation.

# =============================================================================

# Part 2: Histograms as Density Estimators

# How Histograms Work

# A histogram divides the range of your data into equal-width bins and counts how many
# observations fall into each bin. To convert this into a density estimate, we use:

#   ^f_n(x) = (Count in bin containing x) / (n * h)

# where h is the bin width and n is the total number of observations.

# Why Divide by n * h?
# We divide by n to convert counts to proportions, and by h (bin width) to ensure the total
# area under the histogram equals 1 - a requirement for all probability densities.

# The Connection to the ECDF
# Within each bin, the histogram height represents a discretised version of the derivative:

#   ^f_n(x) = (^F_n(upper bin edge) - ^F_n(lower bin edge)) / h  ≈  ^F'_n(x)

# This is a "finite difference" approximation; it estimates the rate of change of the CDF using the
# difference between two nearby points.

# Histogram as Finite Difference Approximation
# For a bin (a, b] with width h = b - a, we substitute the ECDF expression directly:
#   ^F_n(b) - ^F_n(a) = (1/n) * sum_(i=1->n) I(Xi <= b) - (1/n) * sum_(i=1->n) I(Xi <= a)
#                     = (1/n) * sum_(i=1->n) [I(Xi <= b) - I(Xi <= a)]
#                     = (1/n) * sum_(i=1->n) I(a < Xi <= b) = n_bin / n
# where n_bin denotes the count of observations in (a, b]. The histogram density within this
# bin becomes:
#   ^f_n(x) = n_bin / (n * h) = (n_bin / n) / h = (^F_n(b) - ^F_n(a)) / h
# This demonstrates that the histogram implements a finite difference approximation to
# the derivative of the ECDF, with h serving as the discretisation step size.

# Choosing the Right Bin Width
# The bin width h controls the bias-variance trade-off:
# • Too few bins (large h): The histogram is overly smooth and misses important features (high
#   bias, low variance)
# • Too many bins (small h): The histogram is jagged and shows random noise rather than
#   genuine patterns (low bias, high variance)

# Practical Bin Selection
# Freedman's Rule-of-Thumb provides a reasonable starting point:
#   h ≈ 2 * ^sigma * n^(-1/3)
# where ^sigma is the standard deviation of your data. This balances smoothness and detail.
# In R, functions like geom_histogram() use automated algorithms (like Sheather-Jones) that
# can adapt the bin width to your data's characteristics.

# Example: Histogram Construction in R
# We construct histograms for varying bin widths to illustrate smoothing effects.

library(gridExtra)

# Create histograms with different bin counts
p1 <- ggplot(tibble(x = x_mixture), aes(x = x)) +
  geom_histogram(
    bins = 10, fill = "steelblue",
    alpha = 0.7, colour = "black") +
  labs(
    title = "10 Bins (Under-smoothed)",
    x = "x", y = "Density") +
  theme_minimal()

p2 <- ggplot(tibble(x = x_mixture), aes(x = x)) +
  geom_histogram(
    bins = 30, fill = "steelblue",
    alpha = 0.7, colour = "black") +
  labs(
    title = "30 Bins (Well-smoothed)",
    x = "x", y = "Density") +
  theme_minimal()

p3 <- ggplot(tibble(x = x_mixture), aes(x = x)) +
  geom_histogram(
    bins = 100, fill = "steelblue",
    alpha = 0.7, colour = "black") +
  labs(
    title = "100 Bins (Over-smoothed)",
    x = "x", y = "Density") +
  theme_minimal()

# Display multiple plots
grid.arrange(p1, p2, p3, nrow = 1)

# Optimal binning reveals the mixture components clearly, avoiding both jagged artefacts
# and excessive smoothing.

# Figure 1: Histograms of a bimodal mixture distribution using 10 (under-smoothed), 30
# (optimal), and 100 (over-smoothed) bins, demonstrating the bias-variance trade-off in density
# estimation.

# =============================================================================

# Part 3: Kernel Density Estimation

# Moving Beyond Histograms
# Histograms have two limitations:
# 1. They're blocky: Sharp edges don't reflect smooth underlying distributions
# 2. Bin placement matters: Shifting bin boundaries changes the appearance
# Kernel Density Estimation (KDE) addresses both issues by creating a smooth, continuous
# density estimate.

# The KDE Formula
#   ^f_n(x) = (1 / (n * h)) * sum_(i=1->n) K((x - Xi) / h)

# What does this mean?
# • At each data point Xi, we place a small "bump" (the kernel function K)
# • We sum all these bumps together
# • The bandwidth h controls how wide each bump is
# • We divide by nh to ensure the total area equals 1

# Intuitive Understanding of KDE
# Think of each data point as a small pile of sand. The kernel function determines the shape
# of each pile. When we sum all the piles together, we create a smooth landscape that
# represents our data's density. Where data points cluster together, the piles overlap and
# create peaks. Where data is sparse, the landscape is flat.

# Common Kernel Functions
# Different kernel shapes create different smoothing effects:

# 1. Gaussian kernel:
#   K(u) = (1 / sqrt(2 * pi)) * exp(-u^2 / 2)
#   • Creates smooth, bell-shaped bumps
#   • Most commonly used
#   • Has infinite support (tails extend forever, though they become tiny)

# 2. Epanechnikov kernel:
#   K(u) = (3/4) * (1 - u^2) * I(|u| <= 1)
#   • Has finite support (zero outside [-1, 1])
#   • Theoretically optimal (minimises integrated squared error)
#   • Creates parabola-shaped bumps

# 3. Uniform (rectangular) kernel:
#   K(u) = (1/2) * I(|u| <= 1)
#   • Just like a histogram!
#   • Flat-topped bumps

# Kernel Choice in Practice
# The choice of kernel function has minimal impact on the final density estimate. The
# bandwidth h is far more important. Most practitioners use the Gaussian kernel for its
# mathematical convenience and smooth appearance.

# Example: KDE is a Convolution of Data and Kernel
# Convolution is a mathematical operation that "blends" two functions together. In KDE,
# we're blending our data (represented by the ECDF) with our kernel function.
# 
# Mathematically:
#   ^f_n(x) = integral_(-Inf->Inf) K_h(x - u) d^F_n(u)
# 
# This says: "At each point x, we weight nearby data points using the kernel function and
# sum them up." Points closer to x get more weight; distant points contribute less.
# 
# Why it matters: Convolution transforms our spiky ECDF derivative into a smooth curve.
# The kernel acts as a "smoothing window" that spreads probability mass from each data
# point across a continuous range.

# Choosing the Bandwidth
# Just like histogram bin width, bandwidth h controls smoothing:
# • Small h: The density follows data points closely (wiggly, may show noise)
# • Large h: The density is very smooth (may miss real features)

# Silverman's rule-of-thumb for Gaussian kernels:
#   h ≈ 0.9 * ^sigma * n^(-1/5)
# where ^sigma is the standard deviation of your data.

# Automatic Bandwidth Selection
# Modern software uses sophisticated methods like cross-validation that automatically find
# the bandwidth minimising prediction error. In R's geom_density(), the default bandwidth
# selection usually works well, but you can adjust it manually if needed using the bw
# parameter.

# Example: Kernel Density Estimation in R
# We compare histograms and KDEs for the mixture data.

# Compute KDE with Gaussian kernel
kde_data <- tibble(x = x_mixture) |>
  ggplot(aes(x = x)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 30, alpha = 0.5, fill = "grey",
                 colour = "black") +
  geom_density(fill = "steelblue", alpha = 0.4, colour = "blue") +
  labs(
    title = "Histogram vs. Kernel Density Estimate",
    x = "Observed Values",
    y = "Density"
  ) +
  theme_minimal()

print(kde_data)

# Figure: Histogram vs. Kernel Density Estimate
# Grey-filled histogram with overlaid blue-outlined, steelblue semi-transparent smooth density curve.
# Shows bimodal density profile with peaks near x = 0 (density ~ 0.25) and x = 3 (density ~ 0.45).
# The KDE provides a smooth, continuous representation that faithfully captures the
# bimodal structure without histogram artefacts.

# How KDE Relates to Histograms
# A histogram is actually a special case of KDE using the uniform (rectangular) kernel! The
# difference:
# • Histogram: Each data point contributes only to its own bin (rectangular kernel with width h)
# • KDE: Each data point influences a wider region, with contributions weighted by the kernel
#   shape

# =============================================================================

# Practical Considerations

# Edge Effects

# Boundary Bias
# KDE can produce strange results near the edges of your data range. The kernel tries to
# place bumps centred on edge points, but half the bump extends beyond the data support
# into impossible regions.
# 
# Example: If you're estimating age distribution and have no one younger than 18, the
# kernel at 18 might create density below 18, which is meaningless.
# 
# Solutions:
# • Use boundary correction methods
# • Apply reflection (mirror the data at the boundary)
# • Use specialised boundary kernels that adjust shape near edges

# Multivariate KDE
# Kernel density estimation extends from single variables to multiple dimensions. In the multi-
# variate case, each observation consists of p measurements rather than just one value.
# 
# Notation: Let x = (x1, x2, ..., xp) represent a point in p-dimensional space where we want to
# estimate the density. For example, if p = 2, we might have x = (height, weight). Our dataset
# contains n observations X1, X2, ..., Xn where each Xi is a vector of p measurements from the
# i-th individual.
# 
# The multivariate KDE formula mirrors the univariate case:
#   ^f_n(x) = (1 / (n * h^p)) * sum_(i=1->n) K((x - Xi) / h)
# 
# This formula works exactly like the one-dimensional version. We place a kernel at each obser-
# vation Xi and sum their contributions at the point x. The bandwidth h controls smoothing in all
# directions equally. The division (x - Xi) / h means we divide each component of the difference vector
# by h. We divide by h^p instead of h because volume scales differently in higher dimensions; a
# sphere of radius h in p dimensions has volume proportional to h^p.
# 
# The most common choice for the multivariate kernel is the product of Gaussian kernels,
# defined as:
#   K(u) = prod_(j=1->p) (1 / sqrt(2 * pi)) * exp(-u_j^2 / 2) = (1 / (2 * pi)^(p/2)) * exp(-||u|| / 2)
# where u = (u1, u2, ..., up) and ||u|| = u1^2 + u2^2 + ... + up^2 represents the squared Euclidean dis-
# tance. This formulation places a bell-shaped bump at each data point, with the density
# decreasing according to the squared distance from the centre. The product structure ensures
# that the kernel depends only on the distance from each observation, creating circular contours
# in two dimensions and spherical contours in three dimensions. This symmetry simplifies
# computation whilst providing reasonable smoothing behaviour across all directions.

# The Curse of Dimensionality
# Multivariate KDE works well in two or three dimensions but deteriorates rapidly beyond
# this. The problem stems from data sparsity: as dimensions increase, observations spread
# further apart in space. To maintain the same estimation quality, you need exponentially
# more data as you add dimensions. For high-dimensional problems (beyond 3-4 dimen-
# sions), parametric methods or dimensionality reduction techniques provide more reliable
# results.

# Bandwidth Selection via Cross-Validation
# Cross-validation finds the bandwidth that best predicts held-out data:
# 1. For each observation Xi, compute the density estimate ^f_-i(Xi) using all observations
#    except Xi
# 2. Choose the bandwidth h that maximises sum_(i=1->n) log(^f_-i(Xi))
# This ensures your density estimate generalises well to new data.

# =============================================================================

# Summary and Practical Guidance

# The Progression of Techniques
# 1. ECDF: Shows cumulative probabilities but is a step function
# 2. Histogram: Provides density estimate but creates artificial boundaries
# 3. KDE: Offers smooth, continuous density estimation
# Each method builds on the previous, adding sophistication while maintaining the core idea of
# estimating density from data.

# When to Use Each Method
# • ECDF: Useful for hypothesis testing, comparing distributions, or when you need exact
#   cumulative probabilities
# • Histograms: Good for initial exploratory analysis, presentations to non-technical audiences,
#   or when you have limited data
# • KDE: Best for publication-quality visualisations, identifying fine structure in data, or when
#   smoothness matters

# Implementation in R

# ECDF
# ggplot(data, aes(x = variable)) +
#   stat_ecdf()

# Histogram
# ggplot(data, aes(x = variable)) +
#   geom_histogram(bins = 30) # adjust bins as needed

# KDE
# ggplot(data, aes(x = variable)) +
#   geom_density(bw = "SJ") # SJ = Sheather-Jones bandwidth

# =============================================================================

# Conclusion

# Density estimation transforms raw data into interpretable visual representations of underlying
# probability distributions. By understanding the progression from ECDF through histograms to
# kernel density estimation, you gain intuition about the bias-variance trade-off that underlies
# all statistical smoothing.

# The key insight: all these methods balance fidelity to observed data against the need for
# generalisation. Too little smoothing shows noise; too much smoothing hides real features.
# Cross-validation and rule-of-thumb methods help find the sweet spot.

# In subsequent applications, you'll use these tools for exploratory data analysis, model diag-
# nostics, anomaly detection, and as building blocks within more complex machine learning
# frameworks.
```[cite: 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36]