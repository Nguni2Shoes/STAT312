# =============================================================================
# =============================================================================

#                               Practical 6
#                       STAT312 Class Practical
#                    Dr Stéfan Janse van Rensburg
#                                2026

# =============================================================================
# =============================================================================

# Question 1
# Correct
# Mark 4.00 out of 4.00

# A k-NN classifier for patients uses three measurements: systolic blood pressure (mmHg / 10),
# resting heart rate (beats per minute / 10) and age (years / 10). The measurements have already
# been put on comparable scales, so no further scaling is needed. A new observation x and three
# candidate neighbours from the training set are:

#               Measurement 1   Measurement 2   Measurement 3
# X (new)                   6               7               7
# Candidate A               4              10               6
# Candidate B               6               3               8
# Candidate C               6               3              10

# Use the definitions from the notes. For two observations xi and xj with p measurements:
# Euclidean distance: d_ij = sqrt(sum_(t=1->p) (x_it - x_jt)^2)
# Manhattan distance: d_ij = sum_(t=1->p) |x_it - x_jt|
# Hamming distance:   d_ij = sum_(t=1->p) I(x_it != x_jt), the number of fields on which the two observations differ.

# Round every answer to four decimal places; whole numbers need no decimals.

# (a) The Euclidean distance between x0 and candidate A:
# 3.7417

# (b) The Manhattan distance between x0 and candidate A:
# 6

# (c) Separately, two insurance claims are compared on four categorical fields:
# Field             Record 1        Record 2
# vehicle type      Sedan           Sedan
# province          Gauteng         Eastern Cape
# cover level       Full            Full
# payment method    Debit order     Debit order

# The Hamming distance between the two records:
# 1

# (d) Using Manhattan distance, which candidate is the nearest neighbour of x0?
# Candidate B
# Candidate C
# Candidate A

# Mark 1.00 out of 1.00
# The correct answer is: Candidate B

# Differences between x0 and A on the three measurements: (2, -3, 1)
# (a) Euclidean: sqrt(4 + 9 + 1) = sqrt(14) = 3.7417.
# (b) Manhattan: 2 + 3 + 1 = 6.
# (c) The records differ on 1 of the four fields, so the Hamming distance is 1. Fields that match contribute 0; fields
# that differ contribute 1 each, however different the values are.
# (d) Manhattan distances: A = 6, B = 5, C = 7 so the nearest neighbour is B. Under Euclidean distance (A
# = 3.7417, B = 4.1231, C = 5) the nearest neighbour is A instead: the two metrics can rank neighbours differently,
# because Euclidean distance squares each difference and so is more affected by one large difference than by several
# small ones.

# Incorrect. Candidate A
# Correct. Candidate B
# Incorrect. Candidate C

# R Verification / Computation:
x0 <- c(6, 7, 7)
candA <- c(4, 10, 6)
candB <- c(6, 3, 8)
candC <- c(6, 3, 10)

# (a) Euclidean distance to A
sqrt(sum((x0 - candA)^2)) # 3.7417

# (b) Manhattan distance to A
sum(abs(x0 - candA))      # 6

# (c) Hamming distance
rec1 <- c("Sedan", "Gauteng", "Full", "Debit order")
rec2 <- c("Sedan", "Eastern Cape", "Full", "Debit order")
sum(rec1 != rec2)         # 1

# (d) Manhattan distances to all candidates
c(A = sum(abs(x0 - candA)),
  B = sum(abs(x0 - candB)),
  C = sum(abs(x0 - candC))) # B has minimum (5)

# =============================================================================

# Question 2
# Correct
# Mark 4.00 out of 4.00

# A k-NN classifier for e-mails uses two measurements, the link score and the urgency score,
# both already on the same scale from 0 to 10. The class label records whether the e-mail was spam:
# Spam or Normal. The training set has seven e-mails:

# Training point   link score   urgency score   Class
# C                         6               0   Normal
# B                         3               5   Spam
# A                         8               1   Normal
# G                         7               9   Normal
# F                         9               5   Spam
# E                         4               3   Spam
# D                         0               7   Spam

# A new e-mail has link score = 7 and urgency score = 7. Use Euclidean distance and the
# majority-vote rule from the notes. Round every answer to four decimal places; whole numbers need no decimals.

# (a) The Euclidean distance from the new point to its nearest training point:
# 2

# (b) The predicted class with k = 1:
# Spam
# Normal
# Mark 1.00 out of 1.00
# The correct answer is: Normal

# (c) The predicted class with k = 3:
# Normal
# Spam
# Mark 1.00 out of 1.00
# The correct answer is: Spam

# (d) With k = 5 the number of the five nearest neighbours whose class is Spam:
# 3

# Distances from the new point (7, 7) to each training point, from nearest to farthest:
# Rank   Point   Distance   Class
# 1      G       2          Normal
# 2      F       2.8284     Spam
# 3      B       4.4721     Spam
# 4      E       5          Spam
# 5      A       6.0828     Normal
# 6      D       7          Spam
# 7      C       7.0711     Normal

# (a) The nearest point is G, at distance 2.
# (b) With k = 1 the prediction is the class of that single point: Normal.
# (c) With k = 3 the three nearest points are G, F, B with classes Normal, Spam, Spam, so the majority vote gives
# Spam. The vote changes between k = 1 and k = 3: a single nearest neighbour is a noisy guide, which is the high-
# variance side of the bias-variance trade-off.
# (d) Among the five nearest points (G, F, B, E, A), 3 are Spam and 2 are Normal, so k = 5 would predict Spam.

# Incorrect. Spam
# Correct. Normal
# Correct. Spam
# Incorrect. Normal

# R Verification / Computation:
train_emails <- data.frame(
  Point = c("C", "B", "A", "G", "F", "E", "D"),
  link = c(6, 3, 8, 7, 9, 4, 0),
  urgency = c(0, 5, 1, 9, 5, 3, 7),
  Class = c("Normal", "Spam", "Normal", "Normal", "Spam", "Spam", "Spam")
)
new_email <- c(7, 7)

train_emails$dist <- sqrt((train_emails$link - new_email[1])^2 + (train_emails$urgency - new_email[2])^2)
train_emails_sorted <- train_emails[order(train_emails$dist), ]
train_emails_sorted

# =============================================================================

# Question 3
# Correct
# Mark 5.00 out of 5.00

# Six shelf positions gave the following measurements of x = shelf height (metres) and y =
# units sold per day:

# Point   1      2     3      4      5      6
# x_i     2    2.5     3      4      7    7.5
# y_i   2.6   13.3   6.2   11.8   13.4      3

# You want to estimate f(x0) at x0 = 3.5 with the Nadaraya-Watson estimator from the notes,
# f_hat(x0) = sum_(i=1->6) w_i * y_i with weights w_i = K((x0 - x_i)/h) / sum_(j=1->6) K((x0 - x_j)/h)
# using the Epanechnikov kernel K(u) = (3/4)*(1 - u^2) for |u| <= 1 and K(u) = 0 otherwise,
# and bandwidth h = 2.5.

# Round every answer to four decimal places; whole numbers need no decimals.

# (a) The number of training points that receive a non-zero weight at x0:
# 4

# (b) The weight w_i of the training point nearest to x0:
# 0.2824

# (c) The Nadaraya-Watson estimate f_hat(3.5):
# 8.8576

# (d) The k-NN regression estimate at x0 with k = 3, the plain average of the y values of the three nearest training points:
# 10.4333

# (e) Suppose the bandwidth were made very large, say h = 1000. The Nadaraya-Watson estimate at x0 would then be close to:
# The overall mean of the six y values, because every weight moves towards 1/6.
# Zero, because the weights become too small to add up to one, so the estimate collapses.
# The y value of the nearest training point, which keeps the largest weight.
# The fitted value of a least-squares line, because a wide kernel is a linear fit.

# Mark 1.00 out of 1.00
# The correct answer is: The overall mean of the six y values, because every weight moves towards 1/6.

# Standardised distances u_i = (x0 - x_i)/h and kernel values:
# Point    1       2       3       4       5       6
# u_i    0.6     0.4     0.2    -0.2    -1.4    -1.6
# K(u_i) 0.48    0.63    0.72    0.72       0       0
# w_i  0.1882  0.2471  0.2824  0.2824       0       0

# (a) Only the points with |u_i| <= 1, that is points 1, 2, 3, 4, have K(u_i) > 0; 4 points. The Epanechnikov kernel is
# zero outside the window [x0 - h, x0 + h], unlike the Gaussian kernel, which gives every point a small positive
# weight.
# (b) The nearest point is point 3. Its weight is K(u_3) / sum_j K(u_j) = 0.72 / 2.55 = 0.2824. The weights sum to one.
# (c) f_hat(3.5) = sum_i w_i * y_i = 8.8576; a weighted average in which closer points count more.
# (d) The three nearest points are 2, 3, 4 and the plain average of their y values is 10.4333. k-NN always uses exactly
# three points, whatever their distance, and gives them equal weight; the kernel window uses however many points
# fall within h of x0 and weights them by distance.
# (e) With a very large h, every u_i is close to 0, so every K(u_i) is close to 3/4 and every weight is close to 1/6. The
# estimate becomes the overall mean of the y values (8.3833): the fit is completely oversmoothed. A very small h
# does the opposite, leaving only the nearest point in the window.

# Correct. The overall mean of the six y values, because every weight moves towards 1/6.
# Incorrect. The y value of the nearest training point, which keeps the largest weight.
# Incorrect. The fitted value of a least-squares line, because a wide kernel is a linear fit.
# Incorrect. Zero, because the weights become too small to add up to one, so the estimate collapses.

# R Verification / Computation:
x_vals <- c(2, 2.5, 3, 4, 7, 7.5)
y_vals <- c(2.6, 13.3, 6.2, 11.8, 13.4, 3)
x0 <- 3.5
h <- 2.5

u_vals <- (x0 - x_vals) / h
k_epanechnikov <- ifelse(abs(u_vals) <= 1, 0.75 * (1 - u_vals^2), 0)
w_vals <- k_epanechnikov / sum(k_epanechnikov)

# (a) Points with non-zero weight
sum(w_vals > 0) # 4

# (b) Weight of nearest point (point 3: x = 3, distance = 0.5)
w_vals[which.min(abs(x_vals - x0))] # 0.2824

# (c) Nadaraya-Watson estimate
sum(w_vals * y_vals) # 8.8576

# (d) k-NN regression with k = 3
nearest_3_idx <- order(abs(x_vals - x0))[1:3]
mean(y_vals[nearest_3_idx]) # 10.4333

# =============================================================================

# Question 4
# Correct
# Mark 4.00 out of 4.00

# A sample of n = 8 patients gave these values of waiting times at a clinic (minutes / 10), already sorted:
# 2.2, 2.5, 2.6, 4.2, 4.8, 5.8, 7.0, 7.1

# You want to estimate the density at x0 = 7.5. Use the formulas from the notes.
# • Histogram: with bins of width h_bin, f_hat(x0) = (count in the bin containing x0) / (n * h_bin)
# • Silverman's rule-of-thumb bandwidth: h = 0.9 * min(sigma_hat, IQR / 1.34) * n^(-1/5),
#   where sigma_hat is the sample standard deviation (R's sd()) and IQR the interquartile range (R's IQR()).
# • Kernel density estimate: f_hat(x0) = (1 / (n * h)) * sum_(i=1->n) K((x0 - x_i)/h)
#   with the Gaussian kernel K(u) = (1 / sqrt(2 * pi)) * exp(-u^2 / 2) (R's dnorm())
#   or the uniform kernel K(u) = 1/2 for |u| <= 1 and 0 otherwise.

# Round every answer to four decimal places.

# (a) The histogram density estimate at x0, using bins of width 2 that start at 0: [0, 2), [2, 4), [4, 6), and so on:
# 0.1250

# (b) Silverman's rule-of-thumb bandwidth h for this sample:
# 1.1828

# (c) The kernel density estimate at x0 with the Gaussian kernel and the bandwidth from (b):
# 0.0974

# (d) The kernel density estimate at x0 with the uniform kernel and the same bandwidth h:
# 0.1057

# (a) x0 = 7.5 lies in the bin [6, 8), which contains 2 of the 8 values, so f_tilde(x0) = 2 / (8 * 2) = 0.125. Dividing by n
# turns the count into a proportion and dividing by the bin width makes the total area equal to one.
# (b) sigma_hat = 1.9919 and IQR = 3.525 so IQR / 1.34 = 2.6306. The smaller of the two is 1.9919, and
# h = 0.9 * 1.9919 * 8^(-1/5) = 1.1828. R's bw.nrd0() returns the same value.
# (c) With u_i = (x0 - x_i)/h the Gaussian kernel values K(u_i) are 0, 0.0001, 0.0001, 0.0081, 0.0295, 0.142, 0.3648,
# 0.3768; their sum is 0.9214, and f_hat(x0) = 0.9214 / (8 * 1.1828) = 0.0974. Every observation contributes, but
# distant ones contribute very little.
# (d) With the uniform kernel only the 2 observations within h of x0 (that is, in [6.3172, 8.6828]) get 1/2 each,
# so f_hat(x0) = 2 * (1/2) / (8 * 1.1828) = 0.1057. This is a histogram-like estimate with a bin of width 2h centred on
# x0, which is why the histogram is the special case of a uniform kernel.

# R Verification / Computation:
wait_times <- c(2.2, 2.5, 2.6, 4.2, 4.8, 5.8, 7.0, 7.1)
n <- length(wait_times)
x0 <- 7.5

# (a) Histogram estimate with bins of width 2: bin [6, 8) has 7.0 and 7.1 (count = 2)
h_bin <- 2
count_bin <- sum(wait_times >= 6 & wait_times < 8)
count_bin / (n * h_bin) # 0.1250

# (b) Silverman's rule-of-thumb bandwidth
s_sd <- sd(wait_times)
s_iqr <- IQR(wait_times)
h_silv <- 0.9 * min(s_sd, s_iqr / 1.34) * n^(-1/5)
round(h_silv, 4) # 1.1828

# (c) Gaussian KDE
u_gauss <- (x0 - wait_times) / h_silv
round(sum(dnorm(u_gauss)) / (n * h_silv), 4) # 0.0974

# (d) Uniform KDE
u_unif <- ifelse(abs(u_gauss) <= 1, 0.5, 0)
round(sum(u_unif) / (n * h_silv), 4)         # 0.1057

# =============================================================================

# Question 5
# Correct
# Mark 5.00 out of 5.00

# Six shops are to be grouped into k = 2 clusters by k-means using one measurement, daily sales (thousand Rand):
# 4, 5, 8, 17, 22, 25

# The algorithm starts with the two centroids mu_1 = 5 and mu_2 = 25 (cluster 1 and cluster 2). Follow the algorithm in the notes: an assignment
# step puts each observation in the cluster of its nearest centroid; an update step moves each centroid to the mean of the observations assigned
# to it. The within-cluster sum of squares is WCSS = sum_(i=1->k) sum_(x in S_i) (x - mu_i)^2.

# Round every answer to four decimal places; whole numbers need no decimals.

# (a) After the first assignment step, the number of observations in cluster 1:
# 3

# (b) After the first update step, the new centroid mu_1:
# 5.6667

# (c) After the first update step, the new centroid mu_2:
# 21.3333

# (d) The WCSS of the clustering at this point (the assignments from the first assignment step, the centroids from the first update step):
# 41.3333

# (e) What happens at the second assignment step, using the updated centroids from (b) and (c)?
# The observation with value 17 moves to cluster 1, so the centroids change and the algorithm continues.
# The observation with value 8 moves to cluster 2, so the centroids change and the algorithm continues.
# No observation moves, so the centroids do not change and the algorithm stops with this clustering as its final answer.
# The observations with values 17 and 8 swap clusters, so the centroids change and the algorithm continues.

# Mark 1.00 out of 1.00
# The correct answer is: No observation moves, so the centroids do not change and the algorithm stops with this clustering as its final answer.

# First assignment step. Each value goes to the nearer starting centroid (5 or 25):
# Value               4    5    8   17   22   25
# Distance to mu_1=5  1    0    3   12   17   20
# Distance to mu_2=25 21  20   17    8    3    0
# Cluster             1    1    1    2    2    2

# (a) Cluster 1 receives 3 observations (4, 5, 8); cluster 2 the other 3 (17, 22, 25).
# First update step.
# (b) mu_1 = (4 + 5 + 8) / 3 = 5.6667.
# (c) mu_2 = (17 + 22 + 25) / 3 = 21.3333.
# (d) WCSS = (4 - 5.6667)^2 + (5 - 5.6667)^2 + (8 - 5.6667)^2 + (17 - 21.3333)^2 + (22 - 21.3333)^2 + (25 - 21.3333)^2 = 41.3333

# Second assignment step. With the updated centroids, the distances are:
# Value                   4        5        8        17       22       25
# Distance to mu_1=5.6667 1.6667   0.6667   2.3333  11.3333  16.3333  19.3333
# Distance to mu_2=21.3333 17.3333 16.3333  13.3333   4.3333   0.6667   3.6667
# Cluster                 1        1        1         2        2        2

# (e) Every observation stays in its cluster, so the algorithm has converged: the centroids no longer change and the WCSS in (d) is the final
# value. Only observations whose nearest centroid has changed move; the others stay, and each update step lowers (or keeps) the WCSS.

# Correct. No observation moves, so the centroids do not change and the algorithm stops with this clustering as its final answer.
# Incorrect. The observation with value 17 moves to cluster 1, so the centroids change and the algorithm continues.
# Incorrect. The observation with value 8 moves to cluster 2, so the centroids change and the algorithm continues.
# Incorrect. The observations with values 17 and 8 swap clusters, so the centroids change and the algorithm continues.

# R Verification / Computation:
sales <- c(4, 5, 8, 17, 22, 25)
c1 <- sales[abs(sales - 5) <= abs(sales - 25)]
c2 <- sales[abs(sales - 25) < abs(sales - 5)]

# (a) Count in c1
length(c1) # 3

# (b) Updated mu1
mu1_new <- mean(c1)
round(mu1_new, 4) # 5.6667

# (c) Updated mu2
mu2_new <- mean(c2)
round(mu2_new, 4) # 21.3333

# (d) WCSS
wcss <- sum((c1 - mu1_new)^2) + sum((c2 - mu2_new)^2)
round(wcss, 4)    # 41.3333

# =============================================================================

# Question 6
# Correct
# Mark 1.00 out of 1.00

# Which of the following statements about k-nearest neighbours, non-parametric regression and k-means clustering are
# true? Select all that apply. Three of the six statements are true.

# Select one or more:
# [ ] a. The Nadaraya-Watson weights are equal for every training observation inside the bandwidth and zero outside it,
#        whatever kernel is used.
# [ ] b. Standardising the test set with its own mean and standard deviation is preferable, because the test set should be
#        treated separately from the training set.
# [ ] c. A kernel density estimate is a histogram with narrower bins, so it still changes shape when the bin edges are
#        moved.
# [X] d. k-means is unsupervised: it uses no class labels, and every observation is assigned to some cluster whether
#        or not it belongs to a natural group.
#        (True. There is no ground truth; every observation gets a cluster, including observations that are not close to anything.)
# [X] e. The within-cluster sum of squares never increases when the number of clusters k is increased,
#        which is why it cannot by itself choose k.
#        (True. More clusters can only fit the data at least as well, so WCSS decreases with k and the elbow method looks for diminishing returns instead.)
# [X] f. A single extreme outlier can pull a k-means centroid away from the bulk of its cluster, because the
#        objective squares every distance.
#        (True. The centroid is a mean, and a mean is pulled towards an extreme value; the squared distance makes the pull stronger.)

# The true statements match the assumptions and properties in the notes; each false statement reverses a direction (small
# versus large k or h), swaps a property between two methods, or claims a guarantee that the method does not have.

# The correct answers are:
# - A single extreme outlier can pull a k-means centroid away from the bulk of its cluster, because the objective squares every distance.
# - The within-cluster sum of squares never increases when the number of clusters k is increased, which is why it cannot by itself choose k.
# - k-means is unsupervised: it uses no class labels, and every observation is assigned to some cluster whether or not it belongs to a natural group.

# =============================================================================

# Question 7
# Correct
# Mark 1.00 out of 1.00

# A bank has records of 800 past loan applications, each with the applicant's income, age and existing debt, and each
# marked approved or declined by a credit officer. For each new applicant the bank wants to predict which of the two
# decisions an officer would make, using the past records, without assuming any formula linking the three measurements
# to the decision.

# Which method from Chapters 7 to 9 fits this situation best?

# Select one:
# [ ] a. k-means clustering
# [ ] b. k-nearest neighbours regression
# [ ] c. Nadaraya-Watson kernel regression
# [X] d. k-nearest neighbours classification
#        (Correct: the outcome is a category (approved/declined) that is known for past cases, and the decision for a new case is copied from its most similar past cases.)
# [ ] e. Kernel density estimation

# Explanation:
# First ask whether there is an outcome to predict. If there is none, the problem is unsupervised: k-means finds groups of
# similar observations, and kernel density estimation describes the distribution of a single variable. If there is an outcome,
# ask whether it is a category (k-NN classification, a majority vote among the nearest cases) or a number (k-NN
# regression, the plain average of the k nearest responses, or Nadaraya-Watson regression, a smooth weighted average of
# every response with weights that fall off with distance).

# Here the outcome is a category (approved/declined) that is known for past cases, and the decision for a new case is
# copied from its most similar past cases, so the answer is k-nearest neighbours classification.

# The correct answer is: k-nearest neighbours classification
```[cite: 187, 188, 189, 190, 191, 192, 193]