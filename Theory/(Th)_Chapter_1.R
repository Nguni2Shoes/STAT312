# =============================================================================
# =============================================================================

#                               Notes:
#         Fundamentals of Data Analytics and Statistical Learning

# =============================================================================
# =============================================================================

# Contents
# 1 Introduction to Data Analytics
# 1.1 Descriptive Analytics
# 1.2 Diagnostic Analytics 
# 1.3 Predictive Analytics (THIS IS THE FOCUS OF THIS MODULE)
# 1.4 Prescriptive Analytics
# 2 Statistical Learning Theory
# 2.1 The Learning Problem 
# 2.2 Data Collection 
# Choosing Your Samples
# Where Data Comes From and Its Quality
# 3 Data Wrangling and Preprocessing
# 3.1 Data Import and Integration 
# 3.2 Missing Data Mechanisms
# 3.3 Data Validation and Quality Assessment 
# 4 Supervised versus Unsupervised Learning
# 4.1 Supervised Learning Paradigm 
# Regression versus Classification 
# 4.2 Unsupervised Learning Applications
# Principal Applications 
# 4.3 Model Evaluation and Validation
# 5 Conclusion

# ============================================================================

# 1 Introduction to Data Analytics
# Data analytics is a way of getting useful information from data. It involves using statistics,
# computer programmes, and expert knowledge to turn raw data into facts that help with
# making decisions. Modern data analytics uses different methods, each for a specific purpose.
# There are four main types of data analytics:
# • Descriptive analytics looks at past trends.
# • Diagnostic analytics explains why things happened.
# • Predictive analytics forecasts what might happen next.
# • Prescriptive analytics helps you make the best decisions.
# These types build on each other, becoming more advanced and complex as you go.

# ============================================================================

# 1.1 Descriptive Analytics
# Descriptive analytics form the foundational layer of data analysis, employing statistical
# summaries, visualisation techniques, and exploratory data analysis to characterise empirical
# distributions and identify salient patterns within datasets. These methods encompass uni­
# variate statistics (measures of central tendency, dispersion, and distributional shape), and
# bivariate relationships (correlation coefficients, contingency tables).

# ============================================================================

# Example: Descriptive Analytics in Practice
# Consider retail transaction data spanning multiple quarters. Descriptive analytics might
# reveal:
  # Summary statistics for quarterly sales
  quarterly_sales <- data.frame(
    Quarter = c("Q1", "Q2", "Q3", "Q4"),
    Revenue = c(1.2e6, 1.8e6, 1.5e6, 2.1e6),
    Transactions = c(5200, 7800, 6100, 8900)
  )
# Descriptive measures
summary(quarterly_sales$Revenue)
sd(quarterly_sales$Revenue)
cor(quarterly_sales$Revenue, quarterly_sales$Transactions)
# These measures quantify central tendencies, variability, and associations without infer­
# ring causation or predicting future values.

# ============================================================================

# 1.2 Diagnostic Analytics
# Diagnostic analytics goes beyond simply describing what happened; it helps us understand
# why. It uses methods like correlation analysis (seeing how things relate), hypothesis testing
# (testing ideas), and causal inference (figuring out cause and effect) to find relationships
# between different factors and explain observed events.
# When using diagnostic analytics, it’s important to be careful about confounding variables
# (hidden factors), selection bias (skewed data), and spurious correlations (things that seem
#                                                                            related but aren’t). More advanced techniques, such as regression analysis and structural
# equation modelling, help us untangle complicated connections within data to get to the real
# reasons behind phenomena.

# ============================================================================

# Correlation vs Causation
# Diagnostic analytics must distinguish between statistical association and causal relation­
# ships. High correlation coefficients do not establish causation; proper causal inference
# requires experimental design, natural experiments, or sophisticated observational study
# methodologies with appropriate controls for confounding factors

# ============================================================================

# 1.3 Predictive Analytics (THIS IS THE FOCUS OF THIS MODULE)
# Predictive analytics uses past data patterns to estimate future results. It does this using tech­
# niques like supervised learning algorithms, time series analysis, and probabilistic modelling.
# Essentially, these methods aim to figure out the likely value of a target variable (𝑌) given
# a set of predictor variables (𝑋1, 𝑋2, …, 𝑋𝑝). While predicting future outcomes often involves
# forecasting over time, it’s important to remember that not all prediction tasks are about time
# series. For example, you might predict whether a customer will churn next month, or whether
# a loan applicant will default, without directly using a time component in the prediction itself.
# Predictive modelling includes various approaches, such as:
# • Parametric methods (like linear regression and generalised linear models)
# • Non-parametric methods (like decision trees and kernel methods)
# • Ensemble techniques (like random forests and gradient boosting)
# To ensure a model performs well, it’s crucial to evaluate its effectiveness carefully. This involves
# considering factors like bias-variance decomposition, using cross-validation procedures, and
# checking out-of-sample prediction accuracy.

# ============================================================================

# 1.4 Prescriptive Analytics
# Prescriptive analytics integrate predictive models with optimisation algorithms to recommend
# optimal decisions under uncertainty. This paradigm combines forecasting capabilities with
# operations research methodologies, including linear programming, dynamic programming,
# and stochastic optimisation.
# The prescriptive framework addresses decision-making under multiple objectives, resource
# constraints, and uncertain parameters. Applications include portfolio optimisation, supply
# chain management, and resource allocation problems where analytical insights directly inform
# strategic decisions.

# ============================================================================

# 2 Statistical Learning Theory
# Statistical learning uses statistical methods to help computers find patterns and make predic­
# tions from data.1 This involves building models that recognise relationships within a dataset.
# Statistical learning allows systems to learn from examples and make informed decisions or
# predictions, even with new, unseen data. In essence, statistical learning is key to making
# predictions and understanding data.

# ============================================================================

# 2.1 The Learning Problem
# Suppose that we have two continuous variables, 𝑋 and 𝑌, with a known, smooth probability
# density function. Our goal in statistical learning is to find a function 𝑓(𝑥) that can predict 𝑌
# from 𝑋. We want this function to minimise the expected risk, which is the expected error we
# would make across all possible 𝑋 and 𝑌 pairs. This is expressed as:
# 𝑅(𝑓) = ∬𝐿(𝑦, 𝑓(𝑥))𝑝(𝑥, 𝑦)𝑑𝑥𝑑𝑦
# Here, 𝐿(𝑦, 𝑓(𝑥)) measures how wrong our prediction 𝑓(𝑥) is compared to the actual value 𝑦,
# and 𝑝(𝑥, 𝑦) is the joint probability density function of 𝑋 and 𝑌.
# However, since we don’t usually know the true 𝑝(𝑥, 𝑦), we instead try to minimise the empirical
# risk. This involves using a set of 𝑛 training examples (𝑥𝑖, 𝑦𝑖) to estimate the expected risk:
# ^𝑅𝑛(𝑓) = 1/𝑛∑(𝑖=1->n) 𝐿(𝑦𝑖, 𝑓(𝑥𝑖))

# The Learning Problem
# At its core, statistical learning aims to find a function that best predicts an output (𝑌)
# given an input (𝑋). Since we can’t know all possible data, algorithms learn by minimising
# prediction errors on the data we do have. This is done by using a loss function to quantify
# how wrong our predictions are and then finding the function that keeps these errors as
# small as possible on our available data.

# Figure 1: The bias–variance trade-off in statistical learning models. Training error decreases
# monotonically with model complexity, whilst test error initially decreases before increasing
# due to overfitting. The optimal complexity balances underfitting (high bias) and overfitting
# (high variance) to minimise generalisation error.

# The Fundamental Trade-off
# Statistical learning theory highlights a key balancing act: model complexity versus how
# well it performs on new data. If a model is too complex, it might perfectly fit the data
# it learned from (overfitting), but then struggle with any new, unseen information. This
# balancing act, known as the bias-variance trade-off, helps us choose the right model and
# use techniques to stop it from overfitting.

# ============================================================================

# 2.2 Data Collection
# The way we collect data greatly affects how accurate our analysis is and what conclusions
# we can draw. The methods we use for choosing samples, measuring things, and finding data
# sources all decide if the information we gather truly represents what we’re studying, and they
# limit what kind of analysis we can do later.
# Choosing Your Samples
# • Probability sampling helps ensure our data accurately represents the larger group by using
# random methods. Different types, like simple random, stratified, cluster, and systematic
# sampling, are chosen based on the group’s features and practical needs.
# • Non-probability sampling (like convenience or purposive sampling) can be easier to do,
# but it might lead to biased results because it doesn’t use random selection. It’s used when
# random sampling isn’t possible.
# Where Data Comes From and Its Quality
# Today, data comes from many places, such as official records, sensors, social media, and
# research studies. Each source has its own quality issues:
# • Official records might be biased or have errors in how things were measured.
# • Sensor data needs to be properly set up and matched up over time.
# • Social media data often doesn’t represent everyone and has privacy concerns.

# Big Data Considerations
# Large-scale datasets introduce computational challenges and statistical considerations
# beyond traditional sample size calculations. The “three Vs” of big data (volume, velocity,
# variety) require distributed computing frameworks, streaming algorithms, and heteroge­
# neous data integration techniques while maintaining statistical rigour

# ============================================================================

# 3 Data Wrangling and Preprocessing
# Data wrangling is the process of cleaning and transforming raw data into a usable format
# for analysis. This step usually takes up a significant portion of an analytics project’s time
# (around 60-80%). It requires knowledge of how data is structured, programming skills, and an
# understanding of the subject matter to ensure the data is accurate and suitable for analysis.

# ============================================================================

# 3.1 Data Import and Integration
# Modern data analysis often means bringing together information from many different places.
# These sources might have varied formats, structures, and levels of quality. The challenges
# in combining them include matching up their structures, identifying the same things across
# different datasets, lining up information by time, and dealing with different ways data has
# been categorised.

# Example: Data Import and Initial Assessment

# Simulate a realistic data import scenario
set.seed(123)
sales_data <- data.frame(
  date = seq(as.Date("2023-01-01"), as.Date("2023-12-31"),
             by="day"),
  revenue = rnorm(365, 10000, 2000),
  region = sample(c("North", "South", "East", "West"),
                  365, replace=TRUE),
  product_line = sample(
    c("A", "B", "C"), 365, replace=TRUE)
)
# Introduce realistic data quality issues
sales_data$revenue[sample(365, 10)] <- NA # Missing values
sales_data$revenue[sample(365, 5)] <- -1000 # Impossible
# Initial data assessment
str(sales_data)
#> 'data.frame': 365 obs. of 4 variables:
#> $ date : Date, format: "2023-01-01" "2023-01-02" ...
#> $ revenue : num 8879 9540 13117 10141 10259 ...
#> $ region : chr "East" "North" "North" "East" ...
#> $ product_line: chr "B" "B" "C" "B" ...
#> 
summary(sales_data)

# date                revenue         region            product_line
# Min. :2023-01-01    Min. :−1000     Length:365        Length:365
# 1st Qu.:2023-04-02  1st Qu.: 8747   Class :character  Class :character
# Median :2023-07-02  Median : 9892   Mode :character   Mode :character
# Mean :2023-07-02    Mean : 9915     NA                NA
# 3rd Qu.:2023-10-01  3rd Qu.:11345   NA                NA
# Max. :2023-12-31    Max. :16482     NA                NA
# NA                  NA’s :10        NA                NA

# ============================================================================

# 3.2 Missing Data Mechanisms
# Missing data classification follows Rubin’s taxonomy: Missing Completely At Random (MCAR),
# Missing At Random (MAR), and Missing Not At Random (MNAR). Each mechanism requires
# different analytical approaches:
#   • MCAR: Missingness is unrelated to any data (observed or unobserved), like pure chance.
# For example, in a customer satisfaction survey sent via email, some responses are missing
# simply because a random server error prevented a few emails from being delivered, inde­
# pendent of the customers’ satisfaction levels, demographics, or any other factors. Complete
# case analysis remains unbiased
# • MAR: Missingness depends on observed data but not on the missing values themselves.
# For example, in an income survey, men are less likely to report their salary than women, but
# gender is recorded; missing incomes relate to observed gender, not the income amounts.
# Multiple imputation or maximum likelihood methods preserve validity.
# • MNAR: Missingness depends directly on the unobserved (missing) values. For example,
# in a depression study, severely depressed participants are less likely to complete the
# symptom questionnaire; missing scores are related to high (unobserved) depression levels
# themselves. Sensitivity analysis and pattern-mixture models address potential bias

# Listwise Deletion Dangers
# Simply removing observations with missing data (listwise deletion) can introduce sub­
# stantial bias when missingness depends on observed or unobserved variables. This
# approach should only be employed when the MCAR assumption holds and sufficient
# sample size remains after deletion.

# ============================================================================
 
# 3.3 Data Validation and Quality Assessment
# Data quality assessment requires systematic evaluation across multiple dimensions: complete­
# ness (missing value patterns), consistency (logical constraints and business rules), accuracy
# (comparison with external sources), and timeliness (temporal relevance and currency).

# Data quality assessment functions
assess_completeness <- function(data) {
  sapply(data, function(x) mean(is.na(x)))
}
detect_outliers <- function(x, method = "iqr") {
  if (method == "iqr") {
    Q1 <- quantile(x, 0.25, na.rm = TRUE)
    Q3 <- quantile(x, 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    return(x < (Q1 - 1.5 * IQR) | x > (Q3 + 1.5 * IQR))
  }
}
# Apply to our example data
completeness_report <- assess_completeness(sales_data)
outlier_flags <- detect_outliers(sales_data$revenue)
print("Completeness Assessment:")
#> [1] "Completeness Assessment:"
print(completeness_report)
#> date revenue region product_line
#> 0.00000000 0.02739726 0.00000000 0.00000000
print(
  paste("Outliers detected:",
        sum(outlier_flags, na.rm = TRUE))
)
#> [1] "Outliers detected: 6"

# ============================================================================

# 4 Supervised versus Unsupervised Learning
# The distinction between supervised and unsupervised learning reflects fundamental differ­
# ences in available information and analytical objectives. This taxonomy shapes algorithm
# selection, performance evaluation metrics, and interpretation frameworks.

# ============================================================================

# 4.1 Supervised Learning Paradigm
# Supervised learning operates on labelled training data {(𝑥𝑖, 𝑦𝑖)}𝑛
# 𝑖=1 where each input 𝑥𝑖 asso­
# ciates with a known output 𝑦𝑖. The learning objective estimates the conditional distribution
# 𝑃(𝑌| 𝑋) or the conditional expectation 𝐸[𝑌| 𝑋] to enable prediction on unseen inputs.
# Regression versus Classification
# Supervised learning divides into regression (continuous target variables) and classification
# (discrete target variables). This distinction influences loss function selection, performance
# metrics, and algorithmic approaches:
# • Regression: Squared error loss, absolute error loss, quantile loss
# • Classification: Zero-one loss, log-likelihood loss, hinge loss

# Example: Supervised Learning Framework
# Simulate a supervised learning scenario
set.seed(456)
n <- 1000
# Generate predictors
experience <- rnorm(n, 10, 3)
education <- sample(
  c("Bachelor", "Master", "PhD"), n, replace=TRUE,
  prob=c(0.6, 0.3, 0.1))
education_numeric <- as.numeric(
  factor(education, levels=c("Bachelor", "Master", "PhD")))
# Generate target variable with realistic relationships
salary <- 30000 + 2000 * experience +
  5000 * education_numeric + rnorm(n, 0, 3000)
# Create supervised learning dataset
supervised_data <- data.frame(
  experience = experience,
  education = education,
  salary = salary
)
# Simple linear model demonstration
model <- lm(salary ~ experience + education,
            data = supervised_data)
model

#>
#> Call:
#> lm(formula = salary ~ experience + education, data = supervised_data)
#>
#> Coefficients:
#> (Intercept) experience educationMaster educationPhD
#> 35041        2004          4872          9771

# ============================================================================

# 4.2 Unsupervised Learning Applications
# Unsupervised learning operates on unlabelled data {𝑥𝑖}𝑛
# 𝑖=1 without corresponding target
# variables. These methods discover latent structure, reduce dimensionality, or identify patterns
# without external supervision.
# Principal Applications
# • Clustering: This involves partitioning observations into homogeneous groups. For example,
# a retail company might use K-Means clustering to automatically group its customers into
# distinct segments based on their purchasing behaviour, without needing pre-defined cate­
# gories. This helps in tailoring marketing strategies to different customer types.
# Dimensionality Reduction: This focuses on projecting high-dimensional data to lower
# dimensions while retaining important information. If you have a dataset with hundreds
# of features, like various measurements from a scientific experiment, Principal Component
# Analysis (PCA) can reduce these to just two or three main components. This allows for
# easier visualisation of the data and helps in identifying underlying trends that would other­
# wise be hidden.
# • Density Estimation: This aims to estimate probability distributions from samples. Imagine
# you are monitoring sensor data from a piece of machinery. You could use Kernel Density
# Estimation (KDE) to learn the “normal” operating range and distribution of these sensor
# readings. Any new reading that falls into a very low-density area of this learned distribution
# could be flagged as an anomaly, indicating a potential issue with the machine.
# • Association Rules (more computer science than statistics): This involves discovering rela­
# tionships between variables, often in transactional datasets. A classic example is market
# basket analysis in a supermarket. Using the Apriori algorithm, the supermarket can uncover
# patterns like “customers who buy bread and milk also tend to buy butter.” This insight can
# then be used to optimise product placement or create bundled offers.

# ============================================================================

# 4.3 Model Evaluation and Validation
# Supervised learning enables direct performance assessment through prediction accuracy on
# held-out test data. Common evaluation strategies include:
# • Cross-validation: K-fold, leave-one-out, bootstrap methods
# • Performance metrics: MSE, MAE, accuracy, precision, recall, F1-score
# • Model comparison: Information criteria, likelihood ratio tests
# Unsupervised learning evaluation proves more challenging due to the absence of ground truth
# labels. Evaluation approaches include internal validation (silhouette analysis, within-cluster
# sum of squares), external validation (when partial labels exist), and stability analysis across
# different algorithm initialisations.

# Key Distinction
# The fundamental difference between supervised and unsupervised learning lies not
# merely in data structure but in the nature of the learning objective. Supervised learning
# optimises predictive performance on specific tasks, while unsupervised learning discov­
# ers general patterns and structures that may inform multiple downstream applications.

# ============================================================================

# 5 Conclusion
# This foundational chapter establishes the conceptual framework for data analytics and sta­
# tistical learning. The progression from descriptive analysis through predictive modelling to
# prescriptive optimisation represents increasing analytical sophistication and practical impact.
# Understanding these fundamental distinctions guides appropriate methodology selection and
# ensures analytical rigour in applied research contexts.
# The integration of statistical theory with computational implementation requires careful
# attention to data quality, model assumptions, and validation procedures. Subsequent chapters
# will develop these themes through specific methodological approaches and real-world appli­
# cations across diverse domains

## ============================================================================
## ============================================================================

##                                Slides: 

## ============================================================================
## ============================================================================

# Today’s objectives
# By the end of this unit you should be able to:
# • Place a question in the four-stage analytics landscape
# • State the statistical learning problem: find 𝑓, minimise average
# loss
# • Read the bias–variance trade-off off a complexity curve
# • Tell supervised from unsupervised learning
# • Recognise the data-quality issues that decide whether any of it
# works

# ============================================================================

# The Analytics Landscape

# Four questions, increasing value -> Descriptive / Diagnostic / Predictive / Prescriptive
# Each stage builds on the one before — and is worth more to a decision-maker.

# Correlation is not causation
# • High correlation ≠ a causal link
# • Watch for confounders — a hidden
# third variable driving both
# • Spurious correlations abound in
# large data
# • Causation needs experimental
# design, not just a tight scatter

# ============================================================================

# The learning problem
# We want a rule 𝑓(𝑥) that predicts a response 𝑌 from inputs 𝑋.
# How good is a candidate 𝑓? Score it with a loss 𝐿( 𝑦, 𝑓(𝑥) ), then
# seek the rule with the smallest average loss.
# We can only average over the data we have — the empirical risk:
#   ̂𝑅𝑛(𝑓) = 1/𝑛 ∑ 𝐿(𝑦𝑖, 𝑓(𝑥𝑖))

# ============================================================================

# Bias, Variance & Model Complexity

# Model complexity (x axis) increases -> what happens to expected error (y axis)
# Sweet spot between overfit and underfit (measure: Bias^2 / Total Error / Variance)
# Add flexibility → bias falls, variance rises. The best model balances the two.

# The error decomposition
# For a test point 𝑥0, expected squared error splits into three parts:
#   𝐸[ (𝑌−̂𝑓(𝑥0))^2 ] = 𝜎2      + (𝑓(𝑥0) −𝐸[ ̂𝑓(𝑥0)])^ 2  + Var ( ̂𝑓(𝑥0))
#                           ⏟                   ⏟                       ⏟
#                       irreducible           bias2                   variance
# 
# • Underfit — high bias, low variance
# • Overfit — low bias, high variance

# ============================================================================

# Supervised vs Unsupervised Learning

# Two learning paradigms

#             Supervised                                  Unsupervised

# Labelled data {(𝑥𝑖, 𝑦𝑖)}𝑖=1 -> n             Unlabelled data {𝑥𝑖}𝑖=1 -> n
# Estimates 𝐸[𝑌∣𝑋] or 𝑃(𝑌∣𝑋)                   Discovers latent structure
# Performance is directly measurable                No direct performance measure
#
# Tasks: regression (continuous 𝑌),                Tasks: clustering, dimensionality reduction, density estimation
# classification (discrete 𝑌)

# How we judge each

#             Supervised                                  Unsupervised
# Cross-validation (K-fold,LOOCV)                   Internal indices (silhouette)
# Error metrics: MSE, MAE,accuracy                  External checks (if any labels)
# Information criteria (AIC/BIC)                    Stability across re-runs

# The honest measurement of supervised models is the thread running through this whole module.

# ============================================================================

# Data Quality & Wrangling

# Good data first

# Sampling                                              Quality dimensions

# Probability: random, stratified,cluster, systematic   Completeness — missing patterns
# Non-probability: convenience, purposive               Consistency — logical constraints
#                                                       Accuracy — vs external truth
#                                                       Timeliness — still relevant?

# ============================================================================

# Missing data: Rubin’s taxonomy

# Mechanism   Missingness depends on…     Safe approach
# MCAR        nothing — purely random     complete-case stays unbiased
# MAR         observed values only        multiple imputation
# MNAR        unobserved values           sensitivity analysis needed
  
# Knowing the mechanism decides whether deleting rows is harmless or dangerous.

# Wrangling is the job
# The 80% rule
# Data import, cleaning, missing-value handling and reshaping eat
# 60–80% of a real analytics project. Get this wrong and every
# model downstream is wrong too.

# ============================================================================

# Summary

# Key takeaways

# 1. Analytics climbs Descriptive → Diagnostic → Predictive → Prescriptive
# 2. Learning minimises empirical risk as a proxy for true risk
# 3. Error trades bias against variance, over an irreducible floor
# 4. Supervised uses labels; unsupervised finds structure
# 5. Data quality — especially missingness — gates everything

## ============================================================================
## ============================================================================

##                                Examples: 

## ============================================================================
## ============================================================================

# How to use these
# • Each example states a problem — try it before the reveal
# • Worked solutions appear in the lecturer copy (the amber boxes)
# • Code is real and runs against the course datasets

# ============================================================================

# Example 1 · Name the analytics question

# Which of the four stages?
#   For each scenario, name the analytics type — Descriptive,
#   Diagnostic, Predictive or Prescriptive.
# 1. A dashboard reports last quarter’s average sales per region
# 2. We test whether a price drop caused the sales spike
# 3. We forecast next month’s demand from history
# 4. We recommend stock levels that maximise profit

# Answers

# Example 1: Name the Analytics Question
# For each scenario, you must identify the correct stage of the analytics landscape

# 1. A dashboard reports last quarter’s average sales per region: 
#    Descriptive Analytics (looks at "what happened" in the past).
# 2. We test whether a price drop caused the sales spike: 
#    Diagnostic Analytics (investigates "why it happened" by looking for causal links).
# 3. We forecast next month’s demand from history: 
#    Predictive Analytics (estimates "what will happen" in the future).
# 4. We recommend stock levels that maximise profit: 
#    Prescriptive Analytics (integrates predictions with optimization to determine "what should we do").

# ============================================================================

# Example 2 · Descriptive analytics in R

# Summarise the clinical data

# clinical <- read_csv("../Class Notes 2026/clinical_data.csv") count(clinical, outcome)

# A tibble: 3 × 2
# outcome       n
# <chr>       <int>
# 1 High_Risk 32
# 2 Low_Risk 126
# 3 Moderate_Risk 42

# A picture beats a table

# Systolic blood pressure rises across risk groups — a clue for later modelling.

# Answers

# Example 2: Descriptive Analytics in R (Clinical Data)
# 
# Summarised Counts: 
# The count(clinical, outcome) function reveals there are 32 High_Risk, 126 Low_Risk, 
# and 42 Moderate_Risk observations.
# Key Insight: 
# The accompanying boxplot reveals that systolic blood pressure rises across risk groups, 
# providing a useful clue for later modelling

# ============================================================================

# Example 3 · Seeing bias & variance

# Fit polynomials of growing degree

set.seed(312); n <- 80
x <- sort(runif(n, -3, 3)); y <- sin(x) + rnorm(n, 0, 0.4)
dat <- tibble(x, y); i <- sample(n, 48) # 60% train
mse <- \(m, s) mean((s$y - predict(m, s))^2)
err <- map_dfr(1:12, \(d) {
  m <- lm(y ~ poly(x, d), dat[i, ])
  tibble(degree = d, Train = mse(m, dat[i, ]), Test = mse(m,dat[-i, ]))
})

# Train falls, test turns up

# Polynomial degree (complexity ->) (x-axis) vs MSE (y-axis)

# Training error keeps falling; test error bottoms out then climbs — overfitting.

# Answers

# Example 3: Seeing Bias and Variance (Polynomial Fits)
# 
# Observation: 
# As the polynomial degree (model complexity) increases, the training error keeps falling, 
# but the test error bottoms out and then begins to climb.
# Conclusion: 
# This pattern identifies overfitting, where the model is learning noise in the training data 
# rather than the underlying signal, causing it to perform poorly on new data

# ============================================================================

# Example 4 · Supervised or unsupervised?

# Label each task
# 1. Predict high-risk vs not from vitals (data are labelled)
# 2. Group customers into segments with no predefined labels
# 3. Estimate house price from property features
# 4. Reduce 20 survey items to a few underlying factors

# Answers

# Example 4: Supervised or Unsupervised?
# Label each task based on the nature of the data and the objective:
#   
# 1. Predict high-risk vs not from vitals (data are labelled): 
#    Supervised Learning (specifically classification).
# 2. Group customers into segments with no predefined labels: 
#    Unsupervised Learning (specifically clustering).
# 3. Estimate house price from property features: 
#    Supervised Learning (specifically regression).
# 4. Reduce 20 survey items to a few underlying factors: 
#    Unsupervised Learning (specifically dimensionality reduction).

# ============================================================================

# Exercise

# A device measures blood pressure, but fails more often for agitated
# (high-BP) patients, so those readings go missing.

# (a) “Predict 30-day readmission from vitals” — which analytics
#     stage and learning type?
# (b) What is the missingness mechanism?

# Answer

# Exercise: Missing Data Mechanism
# 
# Scenario: A device measures blood pressure but fails more often for agitated patients.
# Answer: This is a case of Missing Not At Random (MNAR).
# Reasoning: In Rubin’s taxonomy, data is MNAR when the probability of a value 
# being missing depends on the unobserved value itself (or a factor directly related to it). 
# Since agitation is often correlated with the blood pressure value being measured, 
# the "failure" of the device is systematically linked to the missing information, 
# which can introduce substantial bias if the data is simply removed








