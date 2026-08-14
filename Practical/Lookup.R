# ============================================================================
# ============================================================================
#                                 CHAPTER 1
# ============================================================================
# ============================================================================

# Based on the provided sources, the following core concepts from Chapter 1 are highly likely to appear in your test, along with the detailed information required to explain and apply them:
#   
#   ### **1. The Four Stages of Data Analytics**
#   Analytics tasks are categorized into a landscape of increasing value and sophistication:
#   *   **Descriptive Analytics:** Asks **"What happened?"** by using statistical summaries and visualizations (like bar charts or box plots) to describe past trends. 
# *   **Diagnostic Analytics:** Asks **"Why did it happen?"** It employs techniques like correlation analysis and causal inference to find relationships and explain events. 
# *   **Predictive Analytics:** Asks **"What will happen?"** using past data patterns to forecast future outcomes (the primary focus of this module). 
# *   **Prescriptive Analytics:** Asks **"What should we do?"** by integrating predictive models with optimization algorithms to recommend the best course of action under uncertainty. 
# 
# ### **2. Correlation vs. Causation**
# A common theoretical question involves distinguishing between these two:
#   *   **High correlation does not establish a causal link.** It merely shows a statistical association. 
# *   **Confounders** (hidden third variables) can drive both observed variables, creating a "spurious correlation". 
# *   Establishing **causation** requires rigorous experimental design or sophisticated observational study methodologies, not just a tight scatter plot.
# 
# ### **3. The Statistical Learning Framework**
# This describes the goal of the models you will build:
#   *   The objective is to find a rule, \\(f(x)\\), that predicts a response \\(Y\\) from inputs \\(X\\) while **minimizing average loss**.
# *   **Empirical Risk:** Because we do not have access to the entire population, we minimize the average loss on the data we *do* have as a proxy for the true risk.
# *   **Loss Functions:** These quantify how "wrong" a prediction is. Examples include **squared error loss** for regression and **zero-one loss** for classification.
# 
# ### **4. Bias, Variance, and Model Complexity**
# You must be able to read this trade-off off a complexity curve:
#   *   **Bias:** Systematic errors that occur if model assumptions are too simple (**underfitting**). High bias models fail to capture the true signal.
# *   **Variance:** Sensitivity to small fluctuations in the training set (**overfitting**). High variance models follow the "noise" in the data too closely.
# *   **The Sweet Spot:** As flexibility increases, bias falls but variance rises. The optimal model minimizes the **total expected squared error**, which is the sum of \\(Bias^2 + Variance + Irreducible\ Error\ (\sigma^2)\\).
# 
# ### **5. Supervised vs. Unsupervised Learning**
# The distinction lies in the nature of the learning objective and the data:
#   *   **Supervised Learning:** Uses **labeled data** \\(\{(x_i, y_i)\}\\). Tasks include **Regression** (predicting a continuous numeric \\(Y\\)) and **Classification** (predicting a discrete category \\(Y\\)).
# *   **Unsupervised Learning:** Uses **unlabeled data** \\(\{x_i\}\\) to discover latent structures. Tasks include **Clustering** (grouping similar points), **Dimensionality Reduction** (PCA), and **Density Estimation**.
# 
# ### **6. Missing Data (Rubin’s Taxonomy)**
# Knowing the mechanism is critical for deciding how to handle missing rows:
#   *   **MCAR (Missing Completely At Random):** Missingness is purely random chance. **Listwise deletion** (removing the row) is only safe and unbiased under this assumption.
# *   **MAR (Missing At Random):** Missingness depends on **observed values** (e.g., men are less likely to report income, but gender is recorded). It requires **multiple imputation**.
# *   **MNAR (Missing Not At Random):** Missingness depends on the **unobserved values** themselves (e.g., the sickest patients do not return a health survey). This requires **sensitivity analysis** as it is the most dangerous form of bias.
# 
# ### **7. Data Quality and Wrangling**
# The "80% Rule" states that data import, cleaning, and reshaping eat up **60–80%** of a real analytics project. Key quality dimensions include:
#   *   **Completeness:** Patterns of missing values.
# *   **Consistency:** Logical constraints (e.g., an age cannot be negative).
# *   **Accuracy:** How well the data reflects the external truth.
# *   **Timeliness:** Whether the data is still relevant.
# 
# ### **8. Essential R Functions for Exploration**
# For the practical/coding section, ensure you can use these base-R tools:
#   *   `str(df)`: Provides a **compact structure report**, showing variable classes and previews.
# *   `summary(df)`: Reports basic statistics and **NA counts** per column.
# *   `aggregate(y ~ x, data = df, FUN = mean)`: Computes **group means** (e.g., average cost per department).
# *   `ifelse()`: Used to **recode impossible values** (like age = 999) to `NA` before calculating means to prevent biased results.
# *   `trimws(tolower(x))`: Essential for **text standardization** to fix inconsistent casing or accidental spaces.

# ============================================================================
# ============================================================================
#                                 CHAPTER 2
# ============================================================================
# ============================================================================

# Based on your course materials, the following concepts from **Chapter 2: Resampling Techniques for Model Validation** are essential for your test. For each concept, I have provided the detailed theoretical and practical information you will need to answer questions about them.
# 
# ### **1. The Optimism of Empirical Risk**
# This is the core motivation for using resampling.
# *   **Empirical Risk (\\(\hat{R}_{emp}\\)):** This is the average loss of a model calculated using the same data it was trained on. 
# *   **The Problem:** Empirical risk is **biased downward** (optimistic) because the model has already "seen" these data points. It measures how well a model "memorized the textbook" rather than how well it learned the "grammar rules" of the underlying data.
# *   **The Fix:** We must test the model on data it has **never seen** to get an honest estimate of **Expected Risk (\\(R(f)\\))** or generalization ability.
# 
# ### **2. The Bias–Variance Decomposition**
# You will likely be asked to explain the components of prediction error or read them off a curve.
# *   **Total Expected Error:** Decomposes into three parts: \\(\text{Bias}^2 + \text{Variance} + \text{Irreducible Error } (\sigma^2)\\).
# *   **Bias:** Systematic error resulting from model assumptions being too simple (**underfitting**).
# *   **Variance:** The model's sensitivity to small fluctuations in the training set (**overfitting**).
# *   **Irreducible Error (\\(\sigma^2\\)):** Inherent noise in the data that represents a **hard floor** on the error; no model change can drive error below this point.
# *   **Complexity Trade-off:** As model flexibility increases, bias falls but variance rises. Resampling helps identify the "sweet spot" that minimizes total error.
# 
# ### **3. The Holdout Method**
# This is the simplest form of resampling, where data is split into **disjoint** training and testing sets.
# *   **Properties:** It is computationally **cheap** (only one model fit) and unbiased for expected risk.
# *   **The Lottery Problem:** Its major weakness is **high variance**. The error estimate depends heavily on which specific observations happen to fall into the test set.
# *   **Split Proportions:** Typically 60%–80% for training (\\(\alpha\\)). A larger \\(\alpha\\) improves the model but makes the test-set error estimate noisier.
# 
# ### **4. K-Fold Cross-Validation**
# The "de facto standard" for most analytics tasks.
# *   **Process:** The data is split into \\(K\\) equal folds. For each iteration, the model is trained on \\(K-1\\) folds and tested on the remaining fold.
# *   **Averaging Advantage:** By averaging the error across all \\(K\\) folds, it **reduces the variance** of the error estimate compared to a single holdout split.
# *   **Standard Error (SE):** Calculated as \\(sd(\text{fold errors}) / \sqrt{K}\\). This measures the precision of the estimate and is used to apply the **one-standard-error rule** to choose simpler models.
# 
# ### **5. Leave-One-Out Cross-Validation (LOOCV)**
# This is the extreme limit of K-fold where \\(K = n\\).
# *   **Pros:** It is **deterministic** (no random split), has **minimal bias** because the training sets are nearly the full data, and is useful for small datasets.
# *   **Cons:** It is computationally **costly** (\\(n\\) fits) and can have higher variance than K-fold because the \\(n\\) training sets are almost identical.
# *   **The Linear Shortcut:** For **linear models**, LOOCV can be computed from a **single model fit** using the **hat values** (leverage) of each observation: \\(\text{LOOCV MSE} = \text{mean}((r / (1 - h))^2)\\).
# 
# ### **6. Stratification**
# This is a technique used during the splitting process, especially for classification or skewed data.
# *   **Goal:** To ensure each fold or split maintains the **same proportions of the target classes** as the original dataset.
# *   **Why it matters:** Without it, a rare class might be completely absent from a test fold, leading to wildly unstable error estimates.
# 
# ### **7. Resampling Strategy Selection**
# You may be asked to match a method to a scenario:
# *   **Large data (\\(n > 10,000\\)):** Use the **Holdout Method**; it is sufficient when there is enough data for a stable split.
# *   **Medium data (\\(1,000 < n < 10,000\\)):** Use **10-fold CV**; it is the standard balance of bias, variance, and computation.
# *   **Small data (\\(n < 1,000\\)):** Use **LOOCV**; limited data makes random splits unreliable.
# 
# ### **Essential R Functions for Chapter 2**
# If you need to code or interpret output:
# *   `initial_split(data, prop)`: Creates the partition.
# *   `training(split)` / `analysis(split)`: Extracts the training rows.
# *   `testing(split)` / `assessment(split)`: Extracts the test rows.
# *   `vfold_cv(data, v)`: Builds the K folds.
# *   `hatvalues(fit)`: Gets the leverage values needed for the analytical LOOCV shortcut.

# ============================================================================
# ============================================================================
#                                 CHAPTER 3
# ============================================================================
# ============================================================================

# Based on the provided sources, the following concepts from **Chapter 3: Linear Regression Implementation in R** are highly likely to appear in your test, with the specific details needed to answer theoretical and practical questions:
#   
#   ### **1. The Linear Regression Model and OLS**
#   Linear regression models the **conditional mean** of a continuous response variable (\\(Y\\)) as a linear function of one or more predictors (\\(X\\)).
# *   **The Equation:** \\(E[Y | X_1, \dots, X_p] = \beta_0 + \beta_1X_1 + \dots + \beta_pX_p\\).
# *   **Estimation Method:** Parameters are estimated via **Ordinary Least Squares (OLS)**, which finds the values that minimize the sum of squared residuals.
# *   **The Error Term (\\(\epsilon\\)):** Captures unexplained variation and is assumed to be normally distributed with a mean of zero and constant variance.
# 
# ### **2. Interpretation of Coefficients**
# You will likely be asked to "translate" the numbers in an R coefficient table into plain English.
# *   **Intercept (\\(\hat{\beta}_0\\)):** Represents the **expected value of \\(Y\\)** when all predictors are zero.
# *   **Slope (\\(\hat{\beta}_1\\)):** In simple regression, it is the expected change in \\(Y\\) for a **one-unit increase** in \\(X\\).
# *   **Partial Effects:** In **multiple regression**, a coefficient represents the change in \\(Y\\) for a one-unit increase in that specific predictor, **holding all other predictors fixed**.
# 
# ### **3. Handling Categorical Predictors (Factors)**
# R handles categorical data by automatically creating **dummy variables**.
# *   **The Reference Category:** By default, R uses the **alphabetically first** level of a factor as the baseline/reference category.
# *   **Reading the Table:** Coefficients for categorical levels represent the **difference** from that reference category.
# *   **Example:** if "Engineering" is the reference for department, the coefficient `departmentHR = -7442.3` means employees in HR earn £7442.3 less than those in Engineering on average, holding other factors constant.
# 
# ### **4. Model Assessment Metrics**
# You must know which metric to choose based on the business context provided in a question.
# *   **RMSE (Root Mean Squared Error):** Reported in the **same units as the response variable**; it is the default metric but is sensitive to large errors.
# *   **MAE (Mean Absolute Error):** More **robust to outliers** than RMSE because it does not square the errors.
# *   **MAPE (Mean Absolute Percentage Error):** A **scale-invariant** metric that expresses error as a percentage of the actual value.
# *   **\\(R^2\\) (Coefficient of Determination):** Represents the proportion of **variance explained** by the model; on a test set, it is the squared correlation between actual and predicted values.
# 
# ### **5. Regression Diagnostics (The Four Plots)**
# Running `plot(fit)` in R produces four panels used to validate model assumptions:
#   *   **Residuals vs Fitted:** Used to check **linearity**. You want to see a horizontal red line with points scattered randomly; a curved pattern suggests the relationship is non-linear.
# *   **Normal Q-Q:** Used to check the **normality of errors**. Points should fall closely along the diagonal dashed line.
# *   **Scale-Location:** Used to check for **constant variance (homoscedasticity)**. If the spread of points increases with the fitted values, the assumption fails.
# *   **Residuals vs Leverage:** Identifies **influential observations** (outliers) that have a disproportionate impact on the model's fit.
# 
# ### **6. The Five-Stage Implementation Workflow**
# Every practical task in this chapter follows these steps:
# 1.  **Explore:** Visualize relationships using `ggplot()` before fitting to check for linearity or outliers.
# 2.  **Split:** Partition data into **train and test sets** (e.g., 80/20) using `initial_split()` for an honest assessment.
# 3.  **Fit:** Use `lm(y ~ x, data = train)` to estimate coefficients.
# 4.  **Predict:** Use `predict(model, newdata = test)` to score the held-out data.
# 5.  **Assess:** Calculate performance metrics and run diagnostic plots to ensure assumptions hold.
# 
# ### **7. Essential R Code Snippets for Chapter 3**
# *   **Fit model:** `fit <- lm(y ~ x1 + x2, data = training_data)`.
# *   **Get coefficients:** `coef(fit)` or `summary(fit)`.
# *   **Test set RMSE:** `sqrt(mean((actual - predicted)^2))`.
# *   **Diagnostic plots:** `par(mfrow = c(2, 2)); plot(fit)`.
# *   **Check constant variance numerically:** `cor(abs(residuals(fit)), fitted(fit))`—a high correlation indicates the assumption has failed.



















