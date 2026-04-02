# End to End Marketing Analytics Dashboard

##  Overview

This project presents a complete end to end marketing analytics pipeline, transforming raw campaign and sales data into actionable insights using Python, PostgreSQL, and Power BI.

The goal is to analyze campaign performance, optimize marketing spend, and provide clear business insights through an interactive dashboard.


##  Project Architecture

Raw Data (Campaign + Shopify)
→ Data Cleaning (Python)
→ Data Modeling (PostgreSQL)
→ Visualization (Power BI Dashboard)



## Tech Stack

* **Python (Pandas)** – Data cleaning and preprocessing
* **PostgreSQL** – Data modeling and transformation
* **Power BI** – Dashboard creation and visualization

---

##  Data Cleaning (Python)

* Handled missing values using:

  * 0 for numerical performance metrics
  * ‘Unknown’ for categorical columns
* Removed duplicate records
* Standardized categorical values (e.g., INDIA → India)
* Fixed inconsistent formatting across columns
* Created derived metrics:

  * Average Order Value (AOV)
  * Conversion Rate
  * Return Rate
* Added data quality flags:

  * Invalid dates
  * Missing IDs
  * Zero sales/spend

---

##  Data Modeling (PostgreSQL)

### Tables Created:

* `stg_campaigns`
* `stg_shopify_sales`
* `dim_campaign`
* `dim_date`
* `fact_marketing_performance`

---

### Key Transformations:

* Replaced unreliable string splitting with **rule based classification**
* Cleaned `campaign_funnel_stage` using pattern matching:

  * TOF, MOF, BOF, RETARGET, UNKNOWN
* Derived `campaign_region` using structured columns:

  * `country_funnel`
  * `geo_location_segment`
* Calculated key performance metrics:

  * CTR (Click Through Rate)
  * CPC (Cost Per Click)
  * ROAS (Return on Ad Spend)
  * ROI (Return on Investment)
  * CVR (Conversion Rate)

---

##  Power BI Dashboard

The dashboard is divided into three analytical pages:

---

###  Page 1 — Executive Summary

* KPI Cards:

  * Total Spend
  * Total Sales
  * Total Conversions
  * CTR%
  * ROAS
* Revenue vs Spend trend over time
* Performance table by location and funnel stage
* Cross page slicers:

  * Month-Year
  * Location Segment
  * Data Source
  * Funnel Stage
  * Region

---

###  Page 2 — Channel Breakdown

* Performance by data source (Brand A / Brand B)
* Spend distribution across funnel stages
* Funnel performance matrix (Spend, Sales, ROAS)
* Sales by campaign region
* Revenue contribution by geo location

---

###  Page 3 — Audience Insights

* Conversion rate by location segment
* Scatter plot:

  * X-axis → Spend
  * Y-axis → Conversions
  * Bubble size → Sales
* Revenue distribution across audience segments

---

##  Key Insights

* TOF campaigns drive the highest spend and volume but moderate efficiency
* Retargeting campaigns show stronger ROAS and conversion efficiency
* Certain regions outperform others significantly in revenue generation
* High spend does not always translate to higher conversions, indicating optimization opportunities

---

##  Key Features

* End to end data pipeline (Python → SQL → Power BI)
* Clean and structured star schema design
* Dynamic filtering using cross page slicers
* Drill down and comparative analysis
* Interactive and user friendly dashboard design

---

##  How to Run

1. Load cleaned datasets into PostgreSQL
2. Execute SQL scripts to create tables and transformations
3. Connect Power BI to PostgreSQL (DirectQuery)
4. Load data and build visuals
5. Use slicers to interact with the dashboard

---

##  Conclusion

This project demonstrates the ability to:

* Clean and prepare real world messy data
* Design scalable SQL data models
* Build interactive dashboards for business insights
* Translate data into meaningful decisions

---

##  Author

Khushi Jain
B.Sc. (Hons) Computer Science
Delhi University
