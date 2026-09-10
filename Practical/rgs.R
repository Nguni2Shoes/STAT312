# Install the packages:
install.packages(c("chattr", "ellmer", "usethis"))
# Set your API Key (get one from Google AI Studio):

# In the RStudio console, open your user .Renviron file:
usethis::edit_r_environ()

# A text file will open in RStudio. Paste the following line on a 
# new line (replace with your actual key):
GEMINI_API_KEY=""

part_1 <- "AQ.Ab8RN6LvD7"

part_2 <- "rwTw6jvNDiTv0"

part_3 <- "LjXMyo6KO6IrR1"

part_4 <- "rtJw2QoQ2gprA"

# Save the file (Ctrl+S), then restart your R session 
# (Ctrl+Shift+F10 on Windows).

# Tell chattr to use Gemini via ellmer:
library(chattr)

# Initialize Gemini as the active chat backend
chattr_use(ellmer::chat_google_gemini())

# Launch the panel in RStudio Viewer
chattr_app()

# ----------------------------------------------------------------------

# Native PDF Reading with ellmer (Recommended)

# Gemini natively accepts PDF documents, and ellmer (the engine powering 
# chattr) can pass local PDF files directly to Gemini from an 
# R script or the console:
library(ellmer)

# 1. Initialize your Gemini chat session
chat <- chat_google_gemini()

# 2. Attach the PDF and ask your question
chat$chat(
  content_pdf_file("questions.pdf"),
  "Read this document and solve question 1."
)

# OR (Change to the right directory first)

chat$chat(
  content_pdf_file("questions.pdf"),
  "Read this document and solve question 9 (f) and (g). The other answers are:
  (a) Odds ratio, one extra delivery day  : 1.3079
(b) Odds ratio, Electronics dummy       : 1.9408
(c) P(return) for the new order         : 0.6536
(d) Test-set accuracy                   : 0.8182
(e) Test-set recall (Yes)               : 0.3103
(g) Test-set precision (Yes)            : 0.8182
(i) Baseline rule accuracy              : 0.7603"
)

# Best Practices to Prevent Performance Drops
# 1. Page-targeted prompting: Rather than asking "Solve the questions 
# in this PDF," ask:
# chat$chat(
# content_pdf_file("questions.pdf"),
# "Focus strictly on Page 3, Question 2. Interpret Figure 2.1 and write the R code."
# )
# 2. Fresh sessions per problem: Once you finish working through a specific 
# multi-part question or problem set, start a fresh 
# chat <- chat_google_gemini() object. Clearing old conversational clutter 
# keeps the model sharp on both statistical theory and clean syntax.

# ----------------------------------------------------------------------

# To get Gemini to write or complete the code accurately using your separate 
# CSV file and R script, the model needs to know three things:
#   
# 1. The exact question/objective from your script.
# 2. The data schema (column names and data types from the CSV).
# 3. Any starter code you already wrote.
# Here is the exact step-by-step workflow using chattr and RStudio.

# Step 1: Load the CSV into R Memory First
# Never send an entire 50,000-row raw CSV into the chat—it wastes token limits 
# and adds noise. Instead, load the data into your R session and inspect it:

# Run this in your Console or Script
df <- read.csv("data.csv")

# Quick check
str(df)

# Pro-Tip: Inspecting Unbalanced or Messy Data

# If your question involves specific factor levels or missing data 
# (e.g., categorical predictors, dates, or NA handling), add one 
# line before calling the AI:
summary(df)

# Method 2: Pass Script & Data Directly via ellmer (Most Reliable)
# If you want complete control, pass your script and the CSV schema directly 
# through the console or a scratchpad script using ellmer. 
# This bypasses editor selection quirks entirely:

library(ellmer)

chat <- chat_google_gemini()

# 1. Inspect your CSV so you have the column structure
df <- read.csv("data.csv")
schema <- paste(capture.output(str(df)), collapse = "\n")

# 2. Read your actual question/script file
my_code <- readLines("my_analysis.R")

# 3. Send everything in one shot
chat$chat(
  paste(
    "Here is the dataset schema:",
    schema,
    "\n---",
    "Here is my code script containing the questions and starter code:",
    paste(my_code, collapse = "\n"),
    "\n---",
    "Complete the starter code according to the question instructions."
  )
)





































