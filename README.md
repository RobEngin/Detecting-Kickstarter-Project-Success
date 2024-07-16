# Detecting Kickstarter Project Success

This project aims to predict the success or failure of Kickstarter projects, with a particular focus on European projects. By utilizing statistical learning techniques, we analyze a comprehensive dataset of Kickstarter projects to uncover the factors contributing to their success or failure. The insights gained from this project are valuable for understanding the dynamics of Kickstarter campaigns in Europe.

## Table of Contents

- [Project Description](#project-description)
- [Data Collection and Preprocessing](#data-collection-and-preprocessing)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Prediction Models](#prediction-models)
- [Model Evaluation](#model-evaluation)
- [Final Comparison and Conclusion](#final-comparison-and-conclusion)
- [USA Projects Test](#usa-projects-test)
- [Authors](#authors)
- [License](#license)

## Project Description

Kickstarter is an online crowdfunding platform that allows creators to seek financial support from a community of backers. A project is considered successful if it meets or exceeds its funding goal within the specified campaign timeframe. This project aims to predict the success of Kickstarter projects using various statistical learning models.

## Data Collection and Preprocessing

The dataset contains information on 378,661 Kickstarter projects from around the world. The following preprocessing steps were performed:

1. **Status Cleaning**: Transform all statuses other than 'Success' to 'Failure'.
2. **Outlier Removal**: Remove outliers for the years 1970 and 2018.
3. **Country Filtering**: Retain only European countries.
4. **Goal Filtering**: Include only projects with funding goals between $1,000 and $100,000.
5. **Removing NaN Values**: Ensure no missing values in the dataset.

## Exploratory Data Analysis

Several insights were drawn from the cleaned dataset, such as:

- Success rates by country
- Number of projects and success rates by year
- Goal and success rates by category

## Prediction Models

We employed several prediction models to estimate the probability of a Kickstarter project's success:

1. **Logistic Regression**:
   - Simple Logistic Regression
   - Stepwise Logistic Regression
2. **Discriminant Analysis**:
   - Linear Discriminant Analysis (LDA)
   - Quadratic Discriminant Analysis (QDA)
3. **Random Forest**:
   - Applied both to balanced and unbalanced datasets

## Model Evaluation

Models were evaluated using metrics such as accuracy, precision, recall, ROC curve, error rate, and false negative rate. The Random Forest model on the balanced dataset outperformed other models, achieving high accuracy and significantly improving both recall and precision.

## Final Comparison and Conclusion

The Random Forest model demonstrated the best performance among all tested models. This model effectively handles class imbalance and provides robust predictions for Kickstarter project success.

## USA Projects Test

As a final test, the best-performing model (Random Forest) was applied to Kickstarter projects from the USA to validate its generalizability. The results confirmed the model's effectiveness across different regions.

## Authors

- Giovanni Piva
- Roberto Vicentini

---

This README provides a comprehensive overview of your project, guiding potential employers through your work and demonstrating your ability to handle a real-world data science problem.
