

**DATA QUALITY \& CLEANING REPORT**







***1. Introduction***



**This report outlines the data cleaning, preprocessing, and validation steps performed on two datasets:**



* **Campaign Performance Data**
* **Shopify Sales Data**



**The objective was to prepare high quality, analysis ready datasets for downstream tasks such as SQL modeling, business intelligence (Power BI), and AI driven insights.**







**2. Initial Data Assessment**



&#x20;***Campaign Dataset***



* **Rows: \~9700+**
* **Columns: 45+**
* **Issues identified:**



* &#x20;**Missing values in multiple numerical and categorical columns**
* &#x20;**Duplicate records (\~300)**
* &#x20;**Inconsistent date formats**
* &#x20;**Presence of string based null values ("nan", "null", etc.)**
* &#x20;**Negative zero values (`-0.0`)**
* &#x20;**Outliers in spend and conversion metrics**



&#x20;***Shopify Dataset***



* &#x20;**Rows: \~5600+**
* &#x20;**Columns: 50+**
* &#x20;**Issues identified:**



* &#x20;  **High missing values in derived metrics (AOV, Return Rate, etc.)**
* &#x20;  **Missing IDs (Order ID, Customer ID, Product ID)**
* &#x20;  **Duplicate rows**
* &#x20;  **Inconsistent categorical values**
* &#x20;  **Invalid date formats**
* &#x20;  **Pre calculated metrics unreliable**



**3. Data Cleaning Process**



&#x20;**3.1 Duplicate Removal**



**\* Removed duplicate rows from both datasets**

**\* Ensured unique and consistent records for analysis**



&#x20;**3.2 Standardization of Missing Values**



&#x20;**Converted all null like strings:**



&#x20; **`"nan"`, `"NaN"`, `"NULL"`, `""` → `NaN`**

&#x20;**Ensured uniform missing value representation**



&#x20;**3.3 Categorical Data Cleaning**



* **Trimmed whitespace and standardized text columns**
* **Filled missing categorical values with `"Unknown"`**



&#x20;**3.4 Numerical Data Cleaning**



* &#x20;**Converted all numerical columns using `pd.to\_numeric()`**
* &#x20;**Filled missing values with `0` where appropriate (e.g., clicks, impressions, sales)**









**3.5 Date Standardization**



* &#x20;**Converted date columns using:**



&#x20;**`pd.to\_datetime(..., errors="coerce")`**

* &#x20;**Created original backup columns:**



&#x20;  **`Date\_Original`**

* &#x20;**Flagged invalid dates:**



&#x20; **`flag\_invalid\_date`**

* &#x20;**Replaced missing dates with placeholder:**



&#x20;  **`2025-01-01`**





**3.6 Handling Negative Zero Values**



* &#x20;**Identified floating point artifacts (`-0.0`)**
* &#x20;**Normalized all values to `0.0`**





&#x20;**3.7 Outlier Detection**



&#x20;**Applied IQR (Interquartile Range) method**

&#x20;**Created flags such as:**



* &#x20;**`flag\_outlier\_amount\_spent`**
* &#x20;**`flag\_spend\_outlier`**



&#x20;**No rows were removed — only flagged for analysis**







**4. Feature Engineering**





&#x20;**4.1 Campaign Metrics**



**Using a safe division approach, the following metrics were calculated:**



* &#x20;**CTR (Click Through Rate)**
* &#x20;**CPC (Cost Per Click)**
* &#x20;**CPM (Cost Per 1000 Impressions)**
* &#x20;**ROAS (Return on Ad Spend)**
* **ROI (Return on Investment)**
* **CVR (Conversion Rate)**
* &#x20;**AOV (Average Order Value)**



&#x20;**Division by zero handled using custom `safe\_divide()` function**



&#x20;**4.2 Shopify Metrics (Recalculated)**



**Pre existing metrics were found unreliable and recalculated:**



* &#x20;**Average Order Value (AOV)**
* &#x20;**Average Items Per Order**
* &#x20;**Return Rate**



**Derived using:**



* &#x20;**Total Sales**
* &#x20;**Orders**
* &#x20;**Items Sold**
* &#x20;**Items Returned**







**5. Data Quality Flags**



**To enhance traceability, several flags were introduced:**



**Campaign Dataset**



* &#x20;**`flag\_invalid\_date`**
* &#x20;**`flag\_zero\_impressions`**
* &#x20;**`flag\_zero\_clicks`**
* &#x20;**`flag\_zero\_spend`**
* &#x20;**`flag\_missing\_campaign\_name`**
* &#x20;**`flag\_spend\_outlier`**





&#x20;**Shopify Dataset**



* **\* `flag\_invalid\_date`**
* &#x20;**`flag\_invalid\_transaction\_timestamp`**
* &#x20;**`flag\_missing\_order\_id`**
* &#x20;**`flag\_missing\_customer\_id`**
* &#x20;**`flag\_zero\_orders`**
* &#x20;**`flag\_zero\_sales`**
* &#x20;**`flag\_negative\_sales`**



**6. Key Design Decisions**



* &#x20;**Missing categorical → `"Unknown"`**
* &#x20;**Missing numeric → `0`**
* &#x20;**Missing IDs → `-1` (to maintain relational integrity)**
* &#x20;**Derived metrics → recalculated instead of trusting raw data**
* **Outliers → flagged, not removed**







**7. Final Data Quality Status**



**| Aspect           | Status            |**

**| ---------------- | ----------------- |**

**| Missing Values   | Handled           |**

**| Duplicates       | Removed           |**

**| Data Types       | Standardized      |**

**| Metrics          | Recalculated      |**

**| Dates            | Cleaned \& Flagged |**

**| Outliers         | Flagged           |**

**| Data Consistency | Achieved          |**



**8. Conclusion**



**The datasets have been successfully cleaned, validated, and enriched with additional features and quality flags. They are now:**



* &#x20;**Analysis-ready**
* &#x20;**Suitable for SQL modeling**
* &#x20;**Compatible with BI tools (Power BI)**
* &#x20;**Reliable for AI driven insights**









