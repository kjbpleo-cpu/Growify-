

# ==========================================================
# GROWIFY TAKE-HOME ASSIGNMENT
# Task 2: Python Data Cleaning & Validation Pipeline
#

# ==========================================================
# ----------------------------------------------------------
# 1. IMPORT LIBRARIES
# ----------------------------------------------------------
import pandas as pd
import numpy as np




# ----------------------------------------------------------
# 2. LOAD RAW DATASETS
# ----------------------------------------------------------
# Campaign dataset
# Shopify dataset
campaign_df = pd.read_csv("/content/Campaign_Raw.csv")
shopify_df = pd.read_csv("/content/Raw_Shopify_Sales.csv")

# ----------------------------------------------------------
# 3. INITIAL DATA INSPECTION
# ----------------------------------------------------------
# Review dataset shape and preview top records

print("Campaign shape:", campaign_df.shape)
print("Shopify shape:", shopify_df.shape)

display(campaign_df.head())
display(shopify_df.head())


# ----------------------------------------------------------
# 4. DATA AUDIT FUNCTION
# ----------------------------------------------------------

def audit_df(df, name):
    print(f"\n{name} INFO")
    print("-" * 50)
    print(df.info())
    print("\nMissing values:")
    print(df.isna().sum().sort_values(ascending=False))
    print("\nDuplicate rows:", df.duplicated().sum())
    print("\nSample data:")
    display(df.head())

audit_df(campaign_df, "Campaign Data")
audit_df(shopify_df, "Shopify Data")




# ----------------------------------------------------------
# 5. REMOVE DUPLICATE ROWS
# ----------------------------------------------------------
# Duplicate records are removed from both raw datasets
# before further cleaning.

# Campaign
campaign_duplicates_before = campaign_df.duplicated().sum()
campaign_df = campaign_df.drop_duplicates()
print("Campaign duplicates removed:", campaign_duplicates_before)

# Shopify
shopify_duplicates_before = shopify_df.duplicated().sum()
shopify_df = shopify_df.drop_duplicates()
print("Shopify duplicates removed:", shopify_duplicates_before)


# ----------------------------------------------------------
# 6. STANDARDIZE NULL / NaN REPRESENTATIONS
# ----------------------------------------------------------

campaign_df = campaign_df.replace(["NAN", "nan", "NaN","Nan", "null", ""], np.nan)
shopify_df = shopify_df.replace(["NAN", "nan", "NaN", "null", ""], np.nan)
campaign_df = campaign_df.replace(
    [r'^\s*nan\s*$', r'^\s*NaN\s*$', r'^\s*NAN\s*$', r'^\s*null\s*$', r'^\s*None\s*$', r'^\s*$'],
    np.nan,
    regex=True
)


# ----------------------------------------------------------
# 7. CAMPAIGN DATA CLEANING
# ----------------------------------------------------------
# 7.1 Clean important categorical columns

cat_cols = [
    "Data Source name",
    "Campaign Name",
    "Campaign Effective Status",
    "Ad Set Name",
    "Ad Name",
    "Country Funnel",
    "Geo Location Segment"
]

for col in cat_cols:
    if col in campaign_df.columns:
        campaign_df[col] = campaign_df[col].fillna("Unknown").astype(str).str.strip()


# 7.2 Clean numeric campaign columns
# Fill valid activity/amount columns with 0 where missing

num_cols = [
    "FB Spent Funnel (INR)",
    "Amount Spent (INR)",
    "Clicks (all)",
    "Impressions",
    "Page Likes",
    "Landing Page Views",
    "Link Clicks",
    "Adds to Cart",
    "Checkouts Initiated",
    "Adds of Payment Info",
    "Purchases",
    "Purchases Conversion Value (INR)",
    "Website Contacts",
    "Messaging Conversations Started",
    "Adds to Cart Conversion Value (INR)",
    "Checkouts Initiated Conversion Value (INR)",
    "Adds of Payment Info Conversion Value (INR)",
    "Row Count"
]

for col in num_cols:
    if col in campaign_df.columns:
        campaign_df[col] = pd.to_numeric(campaign_df[col], errors="coerce").fillna(0)

campaign_df.head()




# 7.3 Standardize campaign dates
# Kept original date for audit traceability and created a
# flag for invalid date parsing.
campaign_df["Date_Original"] = campaign_df["Date"]
campaign_df["Date"] = pd.to_datetime(campaign_df["Date_Original"], dayfirst=True, errors="coerce")
campaign_df["flag_invalid_date"] = campaign_df["Date"].isna()
campaign_df[["Date_Original", "Date", "flag_invalid_date"]].head(20)


# Fill invalid campaign dates with a placeholder date so
# the pipeline remains SQL/BI compatible.
#placeholder for nan dates
campaign_df["Date"] = campaign_df["Date"].fillna(pd.Timestamp("2025-01-01"))

campaign_df[["Date_Original", "Date", "flag_invalid_date"]].head(20)

campaign_df[campaign_df["Date"].isna()].head(10)

for col in num_cols:
    if col in campaign_df.columns:
        campaign_df[col] = campaign_df[col].mask(np.isclose(campaign_df[col], 0), 0)
campaign_df.head()


# 7.4 Flag potential campaign outliers
# IQR-based upper bound is used to mark suspiciously large
# monetary values without removing the rows.
value_cols = [
    "Amount Spent (INR)",
    "Purchases Conversion Value (INR)",
    "Adds to Cart Conversion Value (INR)",
    "Checkouts Initiated Conversion Value (INR)",
    "Adds of Payment Info Conversion Value (INR)"
]

for col in value_cols:
    q1 = campaign_df[col].quantile(0.25)
    q3 = campaign_df[col].quantile(0.75)
    iqr = q3 - q1
    upper = q3 + 1.5 * iqr
    campaign_df[f"flag_outlier_{col.replace(' ', '_').replace('(', '').replace(')', '').replace('/', '_')}"] = campaign_df[col] > upper

campaign_df.head()


# 7.5 Validate campaign cleaning results
print("Remaining nulls:")
print(campaign_df.isna().sum().sort_values(ascending=False).head(20))

print("\nRows with 'Unknown' in important categorical columns:")
for col in cat_cols:
    print(col, (campaign_df[col] == "Unknown").sum())

print("\nNegative zeros left:",
      sum((campaign_df[col].astype(float) == -0.0).sum() for col in num_cols if col in campaign_df.columns))

campaign_df = campaign_df.round(4)
campaign_df.replace(-0.0, 0.0, inplace=True)
neg_zero_count = 0
for col in campaign_df.select_dtypes(include=['float64']).columns:
    neg_zero_count += np.sum((campaign_df[col] == 0) & (np.signbit(campaign_df[col])))

print("True negative zeros:", neg_zero_count)


# 7.6 Derive campaign performance metrics and data quality flags
# Metrics derived: CTR, CPC, CPM, ROAS, ROI, CVR, AOV
#new columns
def safe_divide(a, b):
    return np.where((pd.isna(b)) | (b == 0),0, a / b)
campaign_df["CTR"] = safe_divide(campaign_df["Link Clicks"], campaign_df["Impressions"]) * 100
campaign_df["CPC"] = safe_divide(campaign_df["Amount Spent (INR)"], campaign_df["Link Clicks"])
campaign_df["CPM"] = safe_divide(campaign_df["Amount Spent (INR)"] * 1000, campaign_df["Impressions"])
campaign_df["ROAS"] = safe_divide(campaign_df["Purchases Conversion Value (INR)"], campaign_df["Amount Spent (INR)"])
campaign_df["ROI"] = safe_divide(
    campaign_df["Purchases Conversion Value (INR)"] - campaign_df["Amount Spent (INR)"],
    campaign_df["Amount Spent (INR)"]
) * 100
campaign_df["CVR"] = safe_divide(campaign_df["Purchases"], campaign_df["Link Clicks"]) * 100
campaign_df["AOV"] = safe_divide(campaign_df["Purchases Conversion Value (INR)"], campaign_df["Purchases"])
campaign_df["flag_zero_impressions"] = campaign_df["Impressions"] == 0
campaign_df["flag_zero_clicks"] = campaign_df["Link Clicks"] == 0
campaign_df["flag_zero_spend"] = campaign_df["Amount Spent (INR)"] == 0
campaign_df["flag_missing_campaign_name"] = campaign_df["Campaign Name"].eq("Unknown")
q1 = campaign_df["Amount Spent (INR)"].quantile(0.25)
q3 = campaign_df["Amount Spent (INR)"].quantile(0.75)
iqr = q3 - q1
upper_bound = q3 + 1.5 * iqr

campaign_df["flag_spend_outlier"] = campaign_df["Amount Spent (INR)"] > upper_bound

print("Spend outliers:", campaign_df["flag_spend_outlier"].sum())


# Final campaign dataset structure check
campaign_df.info()




# ----------------------------------------------------------
# 8. SHOPIFY DATA CLEANING
# ----------------------------------------------------------


shopify_df = shopify_df.replace(["NAN", "nan", "NaN", "null", "NULL","Nan","Null", ""], np.nan)
shopify_duplicates_before = shopify_df.duplicated().sum()
print(shopify_duplicates_before)
shopify_df = shopify_df.drop_duplicates()
shopify_duplicates_after = shopify_df.duplicated().sum()

print("Shopify duplicates removed:", shopify_duplicates_before - shopify_duplicates_after)

shopify_df.info()

shopify_df.isna().sum().sort_values(ascending=False)


# 8.1 Clean important Shopify categorical columns
shopify_cat_cols = [
    "Data Source name",
    "Currency",
    "Sales Channel",
    "Country Funnel",
    "Geo Location Segment",
    "Billing Country",
    "Billing Province",
    "Billing City",
    "Order Tags",
    "Product Title",
    "Product Tags",
    "Product Type",
    "Variant Title",
    "SKU",
    "Customer Sale Type",
    "Shipping Country",
    "Order Name"
]

for col in shopify_cat_cols:
    if col in shopify_df.columns:
        shopify_df[col] = shopify_df[col].fillna("Unknown").astype(str).str.strip()


# 8.2 Standardize Shopify date columns
# Preserve original date strings for audit and add invalid
# date flags for downstream review.
shopify_date_cols = ["Date", "Transaction Timestamp", "Order Created At", "Order Updated At"]

for col in shopify_date_cols:
    if col in shopify_df.columns:
        shopify_df[f"{col}_Original"] = shopify_df[col]
        shopify_df[col] = pd.to_datetime(shopify_df[col], dayfirst=True, errors="coerce")
        shopify_df[f"flag_invalid_{col.lower().replace(' ', '_')}"] = shopify_df[col].isna()
        shopify_df[col] = shopify_df[col].fillna(pd.Timestamp("2025-01-01"))


# 8.3 Convert important Shopify numeric columns
shopify_num_cols = [
    "Order ID",
    "Product ID",
    "Gross Sales (INR)",
    "Net Sales (INR)",
    "Total Sales (INR)",
    "Orders",
    "Returns (INR)",
    "Return Rate",
    "Items Sold",
    "Items Returned",
    "Average Order Value (INR)",
    "New Customer Orders",
    "Returning Customer Orders",
    "Average Items Per Order",
    "Discounts (INR)",
    "Row Count",
    "Customer ID"
]

for col in shopify_num_cols:
    if col in shopify_df.columns:
        shopify_df[col] = pd.to_numeric(shopify_df[col], errors="coerce")


# 8.4 Fill additive Shopify numeric columns with 0
shopify_zero_fill_cols = [
    "Gross Sales (INR)",
    "Net Sales (INR)",
    "Total Sales (INR)",
    "Orders",
    "Returns (INR)",
    "Items Sold",
    "Items Returned",
    "Discounts (INR)",
    "New Customer Orders",
    "Returning Customer Orders",
    "Row Count"
]

for col in shopify_zero_fill_cols:
    if col in shopify_df.columns:
        shopify_df[col] = shopify_df[col].fillna(0)

def safe_divide(a, b):
    return np.where((pd.isna(b)) | (b == 0), np.nan, a / b)

# 8.5 Recalculate Shopify metrics from base transactional columns
shopify_df["calc_average_order_value_inr"] = safe_divide(
    shopify_df["Total Sales (INR)"],
    shopify_df["Orders"]
)

shopify_df["calc_average_items_per_order"] = safe_divide(
    shopify_df["Items Sold"],
    shopify_df["Orders"]
)

shopify_df["calc_return_rate"] = safe_divide(
    shopify_df["Items Returned"],
    shopify_df["Items Sold"]
) * 100
shopify_df["Average Order Value (INR)"] = shopify_df["calc_average_order_value_inr"]
shopify_df["Average Items Per Order"] = shopify_df["calc_average_items_per_order"]
shopify_df["Return Rate"] = shopify_df["calc_return_rate"]

shopify_df.replace([np.inf, -np.inf], np.nan, inplace=True)

metric_cols = [
    "Average Order Value (INR)",
    "Average Items Per Order",
    "Return Rate",
    "calc_average_order_value_inr",
    "calc_average_items_per_order",
    "calc_return_rate"
]

for col in metric_cols:
    if col in shopify_df.columns:
        shopify_df[col] = shopify_df[col].fillna(0)


# 8.6 Add Shopify data quality flags
shopify_df["flag_missing_order_id"] = shopify_df["Order ID"].eq(-1) if "Order ID" in shopify_df.columns else False
shopify_df["flag_missing_customer_id"] = shopify_df["Customer ID"].eq(-1) if "Customer ID" in shopify_df.columns else False
shopify_df["flag_zero_orders"] = shopify_df["Orders"].eq(0) if "Orders" in shopify_df.columns else False
shopify_df["flag_zero_sales"] = shopify_df["Total Sales (INR)"].eq(0) if "Total Sales (INR)" in shopify_df.columns else False
shopify_df["flag_negative_sales"] = shopify_df["Total Sales (INR)"].lt(0) if "Total Sales (INR)" in shopify_df.columns else False


# 8.7 Final numeric formatting cleanup
shopify_df = shopify_df.round(4)

for col in shopify_df.select_dtypes(include=["float64"]).columns:
    shopify_df[col] = shopify_df[col].mask((shopify_df[col] == 0) & np.signbit(shopify_df[col]), 0)


# 8.8 Validate Shopify cleaning results
print("Remaining Shopify nulls:")
print(shopify_df.isna().sum().sort_values(ascending=False).head(25))


# 8.9 Fill important missing identifier fields with -1
# This preserves row integrity for SQL loading while making
# missing IDs explicit.
# Fix important IDs
shopify_df["Order ID"] = shopify_df["Order ID"].fillna(-1)
shopify_df["Customer ID"] = shopify_df["Customer ID"].fillna(-1)


shopify_df["Product ID"] = shopify_df["Product ID"].fillna(-1)

print(shopify_df.isna().sum().sort_values(ascending=False).head(25))

shopify_df.info()


# ----------------------------------------------------------
# 9. EXPORT CLEANED DATASETS
# ----------------------------------------------------------

from google.colab import files
campaign_df.to_csv("cleaned_campaigns.csv", index=False)
shopify_df.to_csv("cleaned_shopify_sales.csv", index=False)

files.download("cleaned_campaigns.csv")
files.download("cleaned_shopify_sales.csv")
