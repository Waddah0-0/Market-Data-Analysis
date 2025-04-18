# 📊 Market Data Analysis - Shiny Web App

A fully interactive R Shiny application for analyzing market transaction data. This tool allows users to upload CSV files, visualize spending patterns, perform clustering analysis, and generate association rules using the Apriori algorithm.

## 🌟 Features

- **Upload and Analyze CSV Data**
- **Data Cleaning & Summary**
  - Removes duplicates and outliers
  - Checks for missing values
- **Visual Analytics**
  - Spending by Payment Type
  - Spending by Age Group
  - Spending by City
  - Total Spending Distribution
- **Customer Segmentation**
  - K-Means Clustering based on `age` and `total spending`
- **Market Basket Analysis**
  - Apriori-based Association Rule Mining
  - Adjustable support & confidence thresholds
  - Displays only strong rules (`lift > 1.2`)

---

## 🖥 Live Demo

> Not available yet. You can run the app locally by following the instructions below.

---

## 📁 File Structure

```plaintext
.
├── app.R             # Complete Shiny application code (UI + Server)
├── README.md         # Project description and usage
└── sample-data.csv   # (Optional) Sample dataset for testing
```

---

## ⚙️ Requirements

Before running the app, make sure you have the following R packages installed:

```r
install.packages(c(
  "shiny", "ggplot2", "plotly", "arules", 
  "arulesViz", "shinythemes", "DT", 
  "readxl", "dplyr"
))
```

---

## 🚀 How to Run

1. Clone the repository:

```bash
git clone https://github.com/yourusername/market-data-analysis.git
cd market-data-analysis
```

2. Open `app.R` in RStudio or run it from your terminal using:

```r
shiny::runApp("app.R")
```

---

## 📂 Data Format

Your uploaded `.csv` file **must include** the following columns:

| Column Name   | Description                                  |
|---------------|----------------------------------------------|
| `total`       | Total amount spent                           |
| `paymentType` | Payment method used (e.g., cash, credit)     |
| `age`         | Age of the customer                          |
| `city`        | City of the customer                         |
| `customer`    | Unique customer ID                           |
| `items`       | Comma-separated items bought (for Apriori)   |

---

## 🧪 How It Works

### 🔍 Data Cleaning
- Duplicates are removed using `unique()`.
- Outliers in the `count` field are removed using `boxplot$out`.
- Missing values are checked and handled.

### 📊 Visualization
- Aggregates and plots `total spending` across payment types, age groups, and cities using `barplot()` and `hist()`.

### 🤖 Clustering
- Applies **K-means** clustering to group customers based on age and total spending.
- Number of clusters is selectable between 2 and 4.

### 🔗 Association Rules
- Converts the `items` column into transaction sets.
- Applies the **Apriori** algorithm (from `arules` package).
- Only rules with `lift > 1.2` are shown.

---

## 📌 Screenshots

> *(Add your own screenshots here of each tab for Data, Visualizations, Clustering, and Association Rules)*

---

## 📚 License

This project is open-source and free to use under the MIT License.

---

## ✨ Acknowledgments

- Built using **R Shiny** framework
- Inspired by market basket analysis and customer segmentation techniques in data science

---

## 🙋‍♂️ Author

Made by [Your Name](https://github.com/yourusername)
