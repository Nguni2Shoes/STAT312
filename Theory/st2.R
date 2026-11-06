# ==============================================================================
# STAT312 Semester Test 2 (2026) Theory: Questions and Model Solutions
# Module: Advanced Data Analytics (STAT312)
# Assessment: Semester Test 2 (Theory Section)
# Date: 11 September 2026
# Total Marks: 50 Marks (Section A Written Theory: 25 Marks)
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION A — WRITTEN THEORY [25 MARKS]
# ------------------------------------------------------------------------------

# ==============================================================================
# QUESTION 1: Regularised Regression — Ridge vs. LASSO [5 Marks]
# ==============================================================================

# ------------------------------------------------------------------------------
# Part (a) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# Compare and contrast ridge regression and LASSO regression as methods for
# regularising the linear model. Your answer must address the following three
# points (one mark each):
# - The penalty each method adds to the least-squares objective.
# - The geometry of the constrained problem: the shape of each method's
#   constraint region in coefficient space, and where the residual-sum-of-squares
#   contours first touch that region.
# - The consequence for the fitted model: what each method does with the
#   coefficient of a predictor that has little or no association with the response.

# Model Answer:
# 1. Penalty Objective: Ridge adds an L2 penalty (lambda * sum(beta_j^2)) to the
#    residual sum of squares (RSS), penalizing the squared magnitude of coefficients.
#    LASSO adds an L1 penalty (lambda * sum(|beta_j|)) to RSS, penalizing the absolute
#    magnitude of coefficients.
# 2. Geometry & Constraint Contours: Ridge produces a smooth hyperspherical (circular
#    in 2D) constraint region (sum(beta_j^2) <= s), so the expanding elliptical RSS
#    contours generally touch the boundary off the coordinate axes. LASSO produces a
#    polytopic constraint region with sharp corners on the coordinate axes (sum(|beta_j|) <= s),
#    causing RSS contours to hit the corners first.
# 3. Consequence for Uninformative Predictors: Ridge continuously shrinks coefficients
#    toward zero but never sets them strictly to zero. LASSO forces uninformative
#    predictor coefficients exactly to zero, performing implicit feature selection and
#    yielding a sparse model.


# ------------------------------------------------------------------------------
# Part (b) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# Describe one practical scenario, for either ridge or LASSO, in which you would
# prefer that method to the other. Your answer must address the following two points
# (one mark each):
# - Describe the scenario: what is being predicted, and something about the predictors.
# - Justify the preference by a property established in part (a).

# Model Answer:
# Scenario: Predicting customer lifetime value (CLV) in e-commerce using 500 candidate
# behavioural and demographic predictors, where only a small subset of features are
# expected to hold genuine predictive power.
# Justification: LASSO is preferred over ridge because its L1 penalty enforces sparsity
# by driving uninformative coefficients exactly to zero (as established in part a). This
# automatically removes noise predictors, producing a compact, interpretable model
# that isolates the key drivers of customer value.


# ==============================================================================
# QUESTION 2: Logistic Regression & Odds Ratio Interpretation [5 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# A microlender issues short-term loans to small businesses. To predict whether an
# applicant will default, an analyst fits a logistic regression to 1,500 historical loans.
# The response default is a factor with levels "No" and "Yes", so the model estimates
# the probability of default. The predictor utilisation is the proportion of the
# applicant's credit limit already in use, between 0 and 1. The predictor first_time
# has levels "No" and "Yes"; "No" (repeat borrowers) is the reference category.
#
# The analyst fits the model and inspects the coefficients:
# > coef(summary(default_model))
#               estimate std.error statistic p.value
# (Intercept)     -3.098     0.421     -7.36 2.2e-13
# utilisation      2.402     0.351      6.85 7.3e-12
# first_timeYes    0.621     0.181      3.43 6.1e-04
#
# In her report to management, the analyst writes:
# "Holding utilisation constant, being a first-time borrower increases the
# probability of default by 0.621, about 62 percentage points, and this increase is
# the same for every applicant."

# ------------------------------------------------------------------------------
# Part (a) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# The direction of the analyst's claim is right, but her sentence is incorrect
# as an interpretation of the fitted model. Give two distinct reasons why it is
# incorrect (one mark each).

# Model Answer:
# Reason 1: The coefficient 0.621 represents a change on the log-odds scale, not a
# direct change in probability or percentage points.
# Reason 2: In logistic regression, the relationship between predictors and probability
# is non-linear (the logistic S-curve), meaning the absolute change in probability per
# unit change in predictor depends on the applicant's baseline probability and is not
# constant for every applicant.


# ------------------------------------------------------------------------------
# Part (b) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# Provide the correct interpretation of the first_timeYes coefficient. Your answer
# must address the following three points (one mark each):
# - State the comparison in terms of odds, naming the two groups being compared.
# - State the condition under which the comparison holds.
# - Quote the estimated size of the effect.

# Model Answer:
# Comparison: Comparing the odds of default for first-time borrowers (first_time = Yes)
# to repeat borrowers (first_time = No).
# Condition: Holding credit limit utilisation constant (fixed).
# Effect Size: The odds of default for a first-time borrower are multiplied by exp(0.621)
# (approximately 1.861, or an 86.1% increase in default odds) relative to a repeat borrower.


# ==============================================================================
# QUESTION 3: Discrete Naive Bayes Hand Calculations [6 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# A large retailer recruits its graduates through three channels. For each hire it also
# records whether the recruit previously completed an internship at the company.
# A data scientist fits a discrete naive Bayes classifier to the records of 200 recent
# graduate hires, to predict whether a recruit is still employed at the end of the
# probation period. The table gives counts from that training set by class:
#
# Training-set counts | Retained (120) | Not retained (80)
# internship = Yes    | 90             | 32
# channel = Referral  | 36             | 16
# channel = Job board | 48             | 32
# channel = Agency    | 36             | 32

# ------------------------------------------------------------------------------
# Part (a) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# From the table, estimate the following (one mark each). Show each calculation:
# - The prior probability of each class.
# - The two likelihoods needed for the new applicant in the Retained class:
#   P_hat(internship = Yes | Retained) and P_hat(channel = Referral | Retained).

# Model Answer:
# 1. Prior Probabilities:
#    P_hat(Retained) = 120 / 200 = 0.60 (or 60%)
#    P_hat(Not retained) = 80 / 200 = 0.40 (or 40%)
# 2. Retained Likelihoods:
#    P_hat(internship = Yes | Retained) = 90 / 120 = 0.75
#    P_hat(channel = Referral | Retained) = 36 / 120 = 0.30


# ------------------------------------------------------------------------------
# Part (b) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# Using the naive independence assumption, compute the unnormalised posterior
# weight for each class for an applicant who completed an internship (Yes) and was
# recruited through Referral. Show the products.
# (Note: Given for Not retained: P_hat(internship=Yes|Not retained) = 0.40 and
#  P_hat(channel=Referral|Not retained) = 0.20).

# Model Answer:
# Unnormalised Weight (Retained):
# W_Retained = P_hat(Retained) * P_hat(internship=Yes|Retained) * P_hat(channel=Referral|Retained)
#            = 0.60 * 0.75 * 0.30 = 0.135
#
# Unnormalised Weight (Not retained):
# W_NotRetained = P_hat(Not retained) * P_hat(internship=Yes|Not retained) * P_hat(channel=Referral|Not retained)
#               = 0.40 * 0.40 * 0.20 = 0.032


# ------------------------------------------------------------------------------
# Part (c) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# Complete both steps below (one mark each):
# - Convert the two weights from part (b) into normalised posterior probabilities.
# - Classify the new applicant.

# Model Answer:
# 1. Normalised Posterior Probabilities:
#    Total Evidence (Sum of weights) = 0.135 + 0.032 = 0.167
#    P(Retained | Applicant) = 0.135 / 0.167 = 0.8084 (80.84%)
#    P(Not retained | Applicant) = 0.032 / 0.167 = 0.1916 (19.16%)
# 2. Classification Decision:
#    Classify the new applicant as Retained, since P(Retained | Applicant) = 0.8084 > 0.50.


# ==============================================================================
# QUESTION 4: Gaussian Naive Bayes vs. Linear Discriminant Analysis [5 Marks]
# ==============================================================================

# ------------------------------------------------------------------------------
# Part (a) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# Compare and contrast Gaussian naive Bayes and linear discriminant analysis (LDA)
# as classifiers for continuous features. Your answer must address the following
# three points (one mark each):
# - The assumption each method makes about the covariance structure of the features
#   within a class.
# - The consequence for the number of parameters that must be estimated, and hence
#   for the amount of training data each method needs.
# - The shape of the decision boundary LDA produces, and which of the covariance
#   assumptions above is responsible for that shape.

# Model Answer:
# 1. Covariance Assumption: Gaussian Naive Bayes assumes features are conditionally
#    independent within each class, implying a diagonal covariance matrix (zero pairwise
#    covariances). LDA assumes a shared/common full covariance matrix across all classes.
# 2. Parameters & Sample Complexity: Gaussian Naive Bayes estimates only single feature
#    variances per class (2*p parameters for K=2), requiring significantly less training
#    data. LDA estimates a full shared covariance matrix (p*(p+1)/2 parameters), requiring
#    larger sample sizes to avoid estimation instability when p is moderate to large.
# 3. Decision Boundary: LDA produces a linear decision boundary. This linear shape is
#    directly caused by the assumption of a shared (identical) covariance matrix across
#    classes, which causes the quadratic terms in x to cancel out in the log-posterior ratio.


# ------------------------------------------------------------------------------
# Part (b) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# Describe one practical scenario, for either Gaussian naive Bayes or LDA, in which
# you would prefer that method to the other. Your answer must address the following
# two points (one mark each):
# - Describe the scenario: what is being predicted, and something about the features.
# - Justify the preference by a property from part (a).

# Model Answer:
# Scenario: Medical screening to diagnose a rare blood disease using a panel of 30 highly
# correlated laboratory blood biomarkers measured on a moderate sample of patients.
# Justification: LDA is preferred over Gaussian Naive Bayes because blood biomarkers are
# physiologically correlated. Gaussian Naive Bayes' assumption of feature independence
# is strongly violated here, leading to poor posterior probability calibration, whereas
# LDA explicitly models and incorporates pairwise feature covariances.


# ==============================================================================
# QUESTION 5: Cost-Asymmetric Model Selection & Metric Interpretation [4 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# Two candidate binary classification models, Model A and Model B, were each evaluated
# on the same test set of 2,000 observations (200 positive, 1,800 negative).
#
# Model A Confusion Matrix: TP = 180, FN = 20, FP = 360, TN = 1,440
# Model B Confusion Matrix: TP = 120, FN = 80, FP = 60, TN = 1,740
#
# Summary Metrics Table:
# Metric              | Model A | Model B
# Accuracy            |  0.81   |  0.93
# Precision           |  0.33   |  0.67
# Recall (Sensitivity)|  0.90   |  0.60
# Specificity         |  0.80   |  0.97
# F1-score            |  0.49   |  0.63

# ------------------------------------------------------------------------------
# Part (a) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# A clinic screens patients for a serious medical condition.
# - Positive outcome: the patient has the condition.
# - Costlier error: a patient with the condition is sent home untreated (False Negative).
# - Cheaper error: a healthy patient returns for one extra confirmatory test (False Positive).
# State which model should be deployed and justify your choice.

# Model Answer:
# Choice: Deploy Model A.
# Justification: Because sending a sick patient home untreated (False Negative) is the
# costlier error, the priority is maximizing Recall (Sensitivity). Model A achieves a
# Recall of 0.90 (missing only 20 sick patients) compared to Model B's Recall of 0.60
# (which misses 80 sick patients).


# ------------------------------------------------------------------------------
# Part (b) [2 Marks]
# ------------------------------------------------------------------------------
# Question:
# A subscription company decides which customers receive an expensive promotional offer.
# - Positive outcome: the customer would respond to the offer.
# - Costlier error: the offer is wasted on a customer who will not respond (False Positive).
# - Cheaper error: a would-be responder is simply not contacted (False Negative).
# State which model should be deployed and justify your choice.

# Model Answer:
# Choice: Deploy Model B.
# Justification: Because wasting expensive promotional materials on a non-responding
# customer (False Positive) is the costlier error, the priority is maximizing Precision.
# Model B achieves a Precision of 0.67 (only 60 wasted offers) compared to Model A's
# Precision of 0.33 (360 wasted offers), ensuring high marketing cost-efficiency.
