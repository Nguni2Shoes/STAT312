# ==============================================================================
# STAT312 Semester Test 1 (2026) Theory: Questions and Model Solutions
# Module: Advanced Data Analytics (STAT312)
# Assessment: Semester Test 1 (Theory Section)
# Date: 14 August 2026
# Total Marks: 50 Marks (Section A Written Theory: 25 Marks)
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION A — WRITTEN THEORY [25 MARKS]
# ------------------------------------------------------------------------------

# ==============================================================================
# QUESTION 1: Types of Analytics & Causal Inference [6 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# Following a sharp rise in the proportion of members cancelling their membership
# ("lapsing"), the analytics team of a South African medical aid scheme produces
# two outputs:
# - Report A: A study of the past three years' records, finding that members who
#   had a claim rejected in the previous quarter lapse at three times the rate of
#   members whose claims were all paid.
# - Report B: A system that looks at each current member and decides which one
#   of four retention offers (a premium discount, a free annual health check,
#   a benefit upgrade, or a phone call from a consultant) that member should be
#   sent. The scheme can spend only a fixed amount on these offers each month,
#   so it cannot send the most expensive offer to everyone.

# ------------------------------------------------------------------------------
# Part (a) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# Name the type of analytics that each of Report A and Report B represents, and
# explain in a single paragraph what Report B requires that Report A does not.

# Model Answer:
# Report A represents Diagnostic Analytics, as it examines historical observational
# data to identify past patterns and relationships (specifically, why members lapse).
# Report B represents Prescriptive Analytics, as it recommends specific actions
# (retention offers) for individual members to optimize an outcome under resource
# constraints. Report B requires a predictive response model combined with a
# mathematical optimization algorithm to allocate targeted interventions under a
# strict monthly budget cap, whereas Report A requires only observational data
# aggregation and correlation analysis without evaluating optimal decision rules
# under constraints.


# ------------------------------------------------------------------------------
# Part (b) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# The executive committee reads Report A and resolves: "Rejecting claims causes
# members to lapse, so we should approve more claims." In a single paragraph:
# (i) state whether Report A's finding supports the committee's conclusion, and why;
# (ii) give one specific alternative explanation for the pattern Report A found; and
# (iii) state what evidence the scheme would need before acting on the resolution.

# Model Answer:
# (i) Report A's finding does not support the executive committee's conclusion
# because Report A establishes an observational association (correlation), not
# causation.
# (ii) An alternative explanation is confounding by underlying financial distress
# or severe illness: members experiencing severe financial hardship or complex health
# issues are both more likely to submit non-covered claim types (leading to rejections)
# and more likely to lapse due to inability to afford premiums, creating a spurious
# correlation between claim rejection and lapsing.
# (iii) Before acting on the resolution, the scheme would need experimental evidence
# from a randomized controlled trial (A/B testing) or a rigorous causal inference
# study demonstrating that approving previously rejected claims directly causes a
# statistically significant reduction in member lapse rates.


# ==============================================================================
# QUESTION 2: Regression Model Evaluation & Out-of-Sample Optimism [6 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# A junior analyst at a property firm fits five different multiple regression
# models predicting the selling price of residential properties, using all 900
# observations in the firm's database. She compares the five models on the R^2
# computed from those same 900 observations, selects the model with the highest
# R^2, and reports that R^2 to management as the accuracy that can be expected
# on next quarter's listings.

# ------------------------------------------------------------------------------
# Part (a) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# Identify and explain the errors in the way she has selected her model and
# reported its accuracy.

# Model Answer:
# The analyst committed three major errors:
# 1. In-Sample Optimistic Bias: She evaluated model accuracy on the exact same
#    900 observations used to estimate model coefficients. The in-sample R^2 is
#    optimistically biased because least-squares regression fits coefficients
#    specifically to minimize residual errors on that training sample.
# 2. Model Selection Bias Towards Complexity: In-sample R^2 monotonically increases
#    (or never decreases) as more predictors are added, regardless of whether those
#    predictors hold true population relevance. Selecting the model with the
#    highest in-sample R^2 artificially favors overfitted models that fit
#    sample-specific noise.
# 3. Misreporting Out-of-Sample Accuracy: Reporting in-sample R^2 to management
#    misrepresents out-of-sample prediction capability. In-sample fit metrics
#    significantly overstate performance when applied to unseen future listings
#    (next quarter's listings).


# ------------------------------------------------------------------------------
# Part (b) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# Set out, step by step, the procedure you would follow instead.

# Model Answer:
# 1. Data Partitioning / Resampling Setup: Partition the 900 property observations
#    into a dedicated training set (e.g., 80% / 720 observations) and a held-out
#    test set (e.g., 20% / 180 observations), or set up a K-fold cross-validation
#    scheme (e.g., 5-fold or 10-fold CV) on the data.
# 2. Model Training & Tuning: Fit each of the five candidate multiple regression
#    models using ONLY the training data (or training folds).
# 3. Out-of-Sample Model Selection: Evaluate the candidate models on the held-out
#    validation/test sets using genuine out-of-sample metrics, such as Test Root
#    Mean Squared Error (RMSE) or Cross-Validated MSE. Select the model that
#    minimizes out-of-sample error (or applies the one-standard-error rule).
# 4. Honest Performance Reporting: Compute and report the final selected model's
#    Test R^2 and Test RMSE strictly on unseen test data, presenting these metrics
#    to management as the realistic expectation for next quarter's listings.


# ==============================================================================
# QUESTION 3: Resampling Procedures & Model Validation Trade-Offs [7 Marks]
# ==============================================================================

# ------------------------------------------------------------------------------
# Part (a) [4 Marks]
# ------------------------------------------------------------------------------
# Question:
# Compare and contrast the hold-out method and K-fold cross-validation as procedures
# for estimating how well a fitted model will predict future observations. Your
# paragraph must address how each procedure uses the available data, and how the
# two differ with respect to the bias, the variance and the computational cost
# of the error estimate each produces.

# Model Answer:
# The hold-out method partitions the data once into a single training and test
# split (e.g., 80/20), whereas K-fold cross-validation randomly divides the dataset
# into K disjoint, equal-sized folds, training the model K times on K-1 folds and
# evaluating it on the remaining held-out fold so that every observation is tested
# exactly once. Regarding bias, the hold-out method has a slight pessimistic bias
# because it trains on only a fraction of the sample, while K-fold CV (with K=5 or 10)
# trains on a larger portion ((K-1)/K) of the sample, yielding a nearly unbiased
# error estimate. Regarding variance, the hold-out estimate suffers from high
# variance because it depends heavily on the specific random split; K-fold CV
# averages test errors across all K folds, substantially reducing variance.
# Regarding computational cost, the hold-out method requires fitting the model
# only once, making it computationally cheap, whereas K-fold CV requires K separate
# model fits, multiplying computational time by K.


# ------------------------------------------------------------------------------
# Part (b) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# A colleague has 250 observations of a clinical outcome and must choose between
# three candidate regression models. Each model takes under a second to fit. She
# proposes to make a single 80/20 hold-out split and to select whichever of the
# three models has the lowest test error on it. Her supervisor suggests 10-fold
# cross-validation instead. Advise her on which of these two approaches she should
# use, and justify your advice by reference to the particular circumstances of her problem.

# Model Answer:
# She should follow her supervisor's advice and use 10-fold cross-validation.
#
# Justification:
# 1. Sample Size (n = 250): In a small clinical dataset of 250 records, an 80/20
#    hold-out split leaves only 50 observations in the test set. A single test set
#    of 50 points yields a high-variance, unstable error estimate, creating a
#    high risk of selecting an inferior model due to split luck.
# 2. Low Computational Penalty: Because each model fits in under a second, running
#    10-fold CV for 3 candidate models requires only 30 model fits in total
#    (taking less than 30 seconds), rendering computational cost irrelevant.
# 3. Estimation Stability: 10-fold CV trains each fold on 225 observations (90%
#    of data) and averages evaluation across all 250 points, yielding a lower-variance,
#    far more reliable criterion for model selection.


# ==============================================================================
# QUESTION 4: Missing Data Taxonomy & Listwise Deletion Impact [6 Marks]
# ==============================================================================

# SCENARIO CONTEXT:
# A university's student-success unit is building a model to predict first-year
# academic performance from a set of predictors. One predictor, `hours of paid
# employment per week`, is self-reported in a voluntary intake questionnaire,
# and 22% of its values are missing. An analyst proposes to delete every student
# with a missing value and to fit the model on the students who remain.

# ------------------------------------------------------------------------------
# Part (a) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# Describe one concrete circumstance under which the missingness in this field would
# be missing completely at random (MCAR), one under which it would be missing at
# random (MAR), and one under which it would be missing not at random (MNAR).
# Each circumstance must be specific to this scenario — a general definition on
# its own earns no mark.

# Model Answer:
# - MCAR (Missing Completely At Random): A technical server glitch during survey
#   submission randomly dropped the employment question for 22% of submitted digital
#   forms, completely independent of student academic performance, work hours, or
#   demographic background.
# - MAR (Missing At Random): Engineering faculty students (an observed variable
#   recorded in the survey) face heavier course workloads and skipped the optional
#   employment section more frequently, but missingness within the Engineering
#   faculty is unrelated to their actual unobserved employment hours.
# - MNAR (Missing Not At Random): Students working long part-time employment hours
#   (e.g., >20 hours per week) intentionally leave the field blank out of fear that
#   disclosing high work hours will jeopardize their university standing or
#   financial aid eligibility.


# ------------------------------------------------------------------------------
# Part (b) [3 Marks]
# ------------------------------------------------------------------------------
# Question:
# The unit later telephones a random sample of the students who left the field blank,
# and finds that they work an average of 19 hours per week, whereas the students
# who completed the field reported an average of 8 hours. In light of this, in a
# single paragraph:
# (i) state which of the three mechanisms is operating, and why;
# (ii) explain what the analyst's deletion strategy would do to the fitted model; and
# (iii) state what you would do instead.

# Model Answer:
# (i) The operating mechanism is Missing Not At Random (MNAR) because the telephone
# follow-up demonstrates that the probability of missingness depends directly on
# the unobserved value of `hours of paid employment per week` itself (students
# with higher work hours, averaging 19 hrs/week, left the field blank significantly
# more often than those averaging 8 hrs/week).
# (ii) The analyst's listwise deletion strategy would discard a systematically
# non-representative subset of students, removing the heaviest working individuals
# and biasing the fitted model, which will understate the true impact of employment
# hours on academic performance.
# (iii) Instead of listwise deletion, the unit should perform a sensitivity analysis
# (or pattern-mixture modeling) to evaluate how different plausible missing-data
# assumptions affect model parameter estimates, using the telephone follow-up
# sample as auxiliary validation data.

# ==============================================================================
# END OF SEMESTER TEST 1 (2026) THEORY SECTION
# ==============================================================================
