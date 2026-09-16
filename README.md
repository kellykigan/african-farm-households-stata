# Agricultural Survey of African Farm Households: Stata Analysis

## Overview

This project demonstrates a reproducible Stata workflow for preparing and assessing agricultural survey data from African farm households.

The analysis focuses on data structure, data quality, missing values, variable plausibility, farm income, farm area, and market access.

## Dataset

The dataset contains household-level agricultural survey information from 11 African countries:

- Burkina Faso
- Cameroon
- Egypt
- Ethiopia
- Ghana
- Kenya
- Niger
- Senegal
- South Africa
- Zambia
- Zimbabwe

The dataset contains approximately 9,600 household observations and a large number of variables covering household characteristics, agricultural activities, income, market access, climate adaptation, and other farm-related information.

## Analysis

The Stata workflow includes:

- Inspecting the structure of the dataset
- Checking the household identifier
- Reviewing geographic variables
- Assessing variable types
- Auditing missing data
- Checking categorical variables
- Identifying potentially implausible household sizes
- Checking age and farming experience
- Examining the distribution of farm income
- Creating a log transformation of farm income
- Constructing total reported farm area
- Examining market access distances
- Creating log transformations of market distances
- Assessing missing farm income by country
- Producing exploratory graphs

## Repository Structure

```text
├── README.md
├── do/
│   └── 01_data_quality_audit.do
├── graphs/
│   ├── histogram_incfarm.png
│   ├── histogram_ln_farm_income.png
│   ├── box_farm_area_total.png
│   ├── box_distance_purchase_market.png
│   └── box_distance_selling_market.png
└── raw/
    └── Agricultural Survey of African Farm Households.csv
