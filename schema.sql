--create schema growify
CREATE SCHEMA IF NOT EXISTS growify;
--create tables shopify sales to import data
CREATE TABLE growify.stg_shopify_sales (
    "Data Source name" TEXT,
    "Date" DATE,
    "Currency" TEXT,
    "Sales Channel" TEXT,
    "Transaction Timestamp" TIMESTAMPTZ,
    "Order Created At" TIMESTAMPTZ,
    "Order Updated At" TIMESTAMPTZ,
    "Order ID" NUMERIC,
    "Order Name" TEXT,
    "Country Funnel" TEXT,
    "Geo Location Segment" TEXT,
    "Billing Country" TEXT,
    "Billing Province" TEXT,
    "Billing City" TEXT,
    "Order Tags" TEXT,
    "Product ID" NUMERIC,
    "Product Title" TEXT,
    "Product Tags" TEXT,
    "Product Type" TEXT,
    "Variant Title" TEXT,
    "Gross Sales (INR)" NUMERIC,
    "Net Sales (INR)" NUMERIC,
    "Total Sales (INR)" NUMERIC,
    "Orders" NUMERIC,
    "Returns (INR)" NUMERIC,
    "Return Rate" NUMERIC,
    "Items Sold" NUMERIC,
    "Items Returned" NUMERIC,
    "Average Order Value (INR)" NUMERIC,
    "New Customer Orders" NUMERIC,
    "Returning Customer Orders" NUMERIC,
    "Average Items Per Order" NUMERIC,
    "Discounts (INR)" NUMERIC,
    "Row Count" NUMERIC,
    "SKU" TEXT,
    "Customer Sale Type" TEXT,
    "Customer ID" NUMERIC,
    "Shipping Country" TEXT,
    "Date_Original" TEXT,
    "flag_invalid_date" BOOLEAN,
    "Transaction Timestamp_Original" TEXT,
    "flag_invalid_transaction_timestamp" BOOLEAN,
    "Order Created At_Original" TEXT,
    "flag_invalid_order_created_at" BOOLEAN,
    "Order Updated At_Original" TEXT,
    "flag_invalid_order_updated_at" BOOLEAN,
    "calc_average_order_value_inr" NUMERIC,
    "calc_average_items_per_order" NUMERIC,
    "calc_return_rate" NUMERIC,
    "flag_missing_order_id" BOOLEAN,
    "flag_missing_customer_id" BOOLEAN,
    "flag_zero_orders" BOOLEAN,
    "flag_zero_sales" BOOLEAN,
    "flag_negative_sales" BOOLEAN
);
--create table campaigns to import data
CREATE TABLE growify.stg_campaigns (
    data_source_name TEXT,
    date DATE,
    campaign_name TEXT,
    campaign_effective_status TEXT,
    ad_set_name TEXT,
    ad_name TEXT,
    country_funnel TEXT,
    geo_location_segment TEXT,
    fb_spent_funnel_inr NUMERIC,
    amount_spent_inr NUMERIC,
    clicks_all NUMERIC,
    impressions NUMERIC,
    page_likes NUMERIC,
    landing_page_views NUMERIC,
    link_clicks NUMERIC,
    adds_to_cart NUMERIC,
    checkouts_initiated NUMERIC,
    adds_of_payment_info NUMERIC,
    purchases NUMERIC,
    purchases_conversion_value_inr NUMERIC,
    website_contacts NUMERIC,
    messaging_conversations_started NUMERIC,
    adds_to_cart_conversion_value_inr NUMERIC,
    checkouts_initiated_conversion_value_inr NUMERIC,
    adds_of_payment_info_conversion_value_inr NUMERIC,
    row_count NUMERIC,
    date_original TEXT,
    flag_invalid_date BOOLEAN,
    flag_outlier_amount_spent_inr BOOLEAN,
    flag_outlier_purchases_conversion_value_inr BOOLEAN,
    flag_outlier_adds_to_cart_conversion_value_inr BOOLEAN,
    flag_outlier_checkouts_initiated_conversion_value_inr BOOLEAN,
    flag_outlier_adds_of_payment_info_conversion_value_inr BOOLEAN,
    ctr NUMERIC,
    cpc NUMERIC,
    cpm NUMERIC,
    roas NUMERIC,
    roi NUMERIC,
    cvr NUMERIC,
    aov NUMERIC,
    flag_zero_impressions BOOLEAN,
    flag_zero_clicks BOOLEAN,
    flag_zero_spend BOOLEAN,
    flag_missing_campaign_name BOOLEAN,
    flag_spend_outlier BOOLEAN
);
--validate import 
SELECT * FROM growify.stg_shopify_sales LIMIT 5;
--create new tables dim date , dim campaign , fact marketing performance
CREATE TABLE growify.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    day_of_month INTEGER NOT NULL,
    month_num INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    quarter_num INTEGER NOT NULL,
    year_num INTEGER NOT NULL,
    week_num INTEGER NOT NULL
);
CREATE TABLE growify.dim_campaign (
    campaign_key SERIAL PRIMARY KEY,
    campaign_name TEXT NOT NULL,
    ad_set_name TEXT,
    ad_name TEXT,
    data_source_name TEXT,
    campaign_effective_status TEXT,
    country_funnel TEXT,
    geo_location_segment TEXT,
	brand_name TEXT,
    campaign_funnel_stage TEXT,
    campaign_region TEXT,
	adset_objective TEXT,
    adset_audience TEXT,
	ad_type TEXT,
    creative_format TEXT,
    creative_source TEXT,
    product_category TEXT,
    product_collection TEXT
);
CREATE TABLE growify.fact_marketing_performance (
    fact_key BIGSERIAL PRIMARY KEY,
    date_key INTEGER NOT NULL REFERENCES growify.dim_date(date_key),
    campaign_key INTEGER NOT NULL REFERENCES growify.dim_campaign(campaign_key),
	fb_spent_funnel_inr NUMERIC,
    amount_spent_inr NUMERIC,
    clicks_all NUMERIC,
    impressions NUMERIC,
    page_likes NUMERIC,
    landing_page_views NUMERIC,
    link_clicks NUMERIC,
    adds_to_cart NUMERIC,
    checkouts_initiated NUMERIC,
    adds_of_payment_info NUMERIC,
    purchases NUMERIC,
    purchases_conversion_value_inr NUMERIC,
    website_contacts NUMERIC,
    messaging_conversations_started NUMERIC,
    adds_to_cart_conversion_value_inr NUMERIC,
    checkouts_initiated_conversion_value_inr NUMERIC,
    adds_of_payment_info_conversion_value_inr NUMERIC,
    ctr NUMERIC,
    cpc NUMERIC,
    cpm NUMERIC,
    roas NUMERIC,
    roi NUMERIC,
    cvr NUMERIC,
    aov NUMERIC,
    flag_invalid_date BOOLEAN,
    flag_zero_impressions BOOLEAN,
    flag_zero_clicks BOOLEAN,
    flag_zero_spend BOOLEAN,
    flag_missing_campaign_name BOOLEAN,
    flag_spend_outlier BOOLEAN
);
--insert data from the imported datas
INSERT INTO growify.dim_date (
    date_key,
    full_date,
    day_of_month,
    month_num,
    month_name,
    quarter_num,
    year_num,
    week_num
)
SELECT DISTINCT
    TO_CHAR(date, 'YYYYMMDD')::INTEGER AS date_key,
    date AS full_date,
    EXTRACT(DAY FROM date)::INTEGER,
    EXTRACT(MONTH FROM date)::INTEGER,
    TRIM(TO_CHAR(date, 'Month')) AS month_name,
    EXTRACT(QUARTER FROM date)::INTEGER,
    EXTRACT(YEAR FROM date)::INTEGER,
    EXTRACT(WEEK FROM date)::INTEGER
FROM growify.stg_campaigns
WHERE date IS NOT NULL;
SELECT * FROM growify.dim_date LIMIT 10;

INSERT INTO growify.dim_campaign (
    campaign_name,
    ad_set_name,
    ad_name,
    data_source_name,
    campaign_effective_status,
    country_funnel,
    geo_location_segment,
    brand_name,
    campaign_funnel_stage,
    campaign_region,
    adset_objective,
    adset_audience,
    ad_type,
    creative_format,
    creative_source,
    product_category,
    product_collection
)
SELECT DISTINCT
    campaign_name,
    ad_set_name,
    ad_name,
    data_source_name,
    campaign_effective_status,
    country_funnel,
    geo_location_segment,
    TRIM(split_part(campaign_name, '|', 1)) AS brand_name,
    TRIM(CASE 
    WHEN LOWER(campaign_name) LIKE '%tof%' 
         OR LOWER(campaign_name) LIKE '%top%' 
    THEN 'TOF'
    WHEN LOWER(campaign_name) LIKE '%mof%' 
         AND LOWER(campaign_name) LIKE '%bof%' 
    THEN 'MOF+BOF'
    WHEN LOWER(campaign_name) LIKE '%mof%' 
         OR LOWER(campaign_name) LIKE '%consideration%' 
    THEN 'MOF'
    WHEN LOWER(campaign_name) LIKE '%bof%' 
         OR LOWER(campaign_name) LIKE '%conversion%' 
    THEN 'BOF'
    WHEN LOWER(campaign_name) LIKE '%retarget%' 
         OR LOWER(campaign_name) LIKE '%remarketing%' 
    THEN 'RETARGET'
    ELSE 'UNKNOWN'
	END AS campaign_funnel_stage,
    TRIM(split_part(campaign_name, '|', 3)) AS campaign_region,
    TRIM(split_part(ad_set_name, '|', 1)) AS adset_objective,
    TRIM(split_part(ad_set_name, '|', 2)) AS adset_audience,
    TRIM(split_part(ad_name, '|', 1)) AS ad_type,
    TRIM(split_part(ad_name, '|', 2)) AS creative_format,
    TRIM(split_part(ad_name, '|', 3)) AS creative_source,
    TRIM(split_part(ad_name, '|', 4)) AS product_category,
    TRIM(split_part(ad_name, '|', 5)) AS product_collection
FROM growify.stg_campaigns;
DROP TABLE growify.dim_campaign CASCADE;
CREATE TABLE growify.dim_campaign AS
SELECT DISTINCT
    campaign_name,
    ad_set_name,
    ad_name,
    data_source_name,
    campaign_effective_status,
    country_funnel,
    geo_location_segment,
    CASE 
        WHEN LOWER(TRIM(campaign_name)) LIKE '%tof%' THEN 'TOF'
		WHEN LOWER(TRIM(campaign_name)) LIKE '%mof%' AND LOWER(TRIM(campaign_name)) LIKE '%bof%' THEN 'MOF+BOF'
		WHEN LOWER(TRIM(campaign_name)) LIKE '%mof%' THEN 'MOF'
		WHEN LOWER(TRIM(campaign_name)) LIKE '%bof%' THEN 'BOF'
		WHEN LOWER(TRIM(campaign_name)) LIKE '%retarget%' OR LOWER(TRIM(campaign_name)) LIKE '%remarketing%' THEN 'RETARGET'
		ELSE 'UNKNOWN'
    END AS campaign_funnel_stage,
	CASE 
        WHEN country_funnel IS NOT NULL AND country_funnel <> '' THEN country_funnel
        WHEN geo_location_segment IS NOT NULL AND geo_location_segment <> '' THEN geo_location_segment
        ELSE 'UNKNOWN'
    END AS campaign_region
FROM growify.stg_campaigns;
SELECT
    campaign_name,
    brand_name,
    campaign_funnel_stage,
    campaign_region,
    adset_objective,
    adset_audience,
    ad_type,
    creative_format
FROM growify.dim_campaign
LIMIT 10;
Insert into growify.fact_marketing_performance AS
SELECT
    TO_CHAR(s.date, 'YYYYMMDD')::INTEGER AS date_key,
    d.campaign_name,
    d.data_source_name,
    d.campaign_funnel_stage,
    d.campaign_region,
    d.geo_location_segment,
	s.fb_spent_funnel_inr,
    s.amount_spent_inr,
    s.clicks_all,
    s.impressions,
    s.page_likes,
    s.landing_page_views,
    s.link_clicks,
    s.adds_to_cart,
    s.checkouts_initiated,
    s.adds_of_payment_info,
    s.purchases,
    s.purchases_conversion_value_inr,
    s.website_contacts,
    s.messaging_conversations_started,
    s.adds_to_cart_conversion_value_inr,
    s.checkouts_initiated_conversion_value_inr,
    s.adds_of_payment_info_conversion_value_inr,
    s.ctr,
    s.cpc,
    s.cpm,
    s.roas,
    s.roi,
    s.cvr,
    s.aov,
    s.flag_invalid_date,
    s.flag_zero_impressions,
    s.flag_zero_clicks,
    s.flag_zero_spend,
    s.flag_missing_campaign_name,
    s.flag_spend_outlier
FROM growify.stg_campaigns s
JOIN growify.dim_campaign d
    ON s.campaign_name = d.campaign_name
   AND s.ad_set_name = d.ad_set_name
   AND s.ad_name = d.ad_name
   AND s.data_source_name = d.data_source_name;
SELECT COUNT(*) FROM growify.fact_marketing_performance;
SELECT DISTINCT campaign_funnel_stage
FROM growify.fact_marketing_performance;
CREATE INDEX idx_fact_marketing_date_key
ON growify.fact_marketing_performance(date_key);
CREATE INDEX idx_fact_marketing_funnel_stage
ON growify.fact_marketing_performance(campaign_funnel_stage);

SELECT * FROM growify.fact_marketing_performance LIMIT 5;

--add indexes
CREATE INDEX idx_fact_marketing_date_key
ON growify.fact_marketing_performance(date_key);

CREATE INDEX idx_fact_marketing_campaign_key
ON growify.fact_marketing_performance(campaign_key);

CREATE INDEX idx_dim_campaign_campaign_name
ON growify.dim_campaign(campaign_name);

CREATE INDEX idx_dim_campaign_funnel_stage
ON growify.dim_campaign(campaign_funnel_stage);

CREATE INDEX idx_dim_campaign_region
ON growify.dim_campaign(campaign_region);

CREATE INDEX idx_dim_campaign_geo_location_segment
ON growify.dim_campaign(geo_location_segment);

--some queries
--total spend and revenue
SELECT
    SUM(amount_spent_inr) AS total_spend,
    SUM(purchases_conversion_value_inr) AS total_revenue
FROM growify.fact_marketing_performance;
--top10 campaigns by roas
SELECT
    dc.campaign_name,
    ROUND(SUM(f.amount_spent_inr), 2) AS total_spend,
    ROUND(SUM(f.purchases_conversion_value_inr), 2) AS total_revenue,
    ROUND(
        CASE WHEN SUM(f.amount_spent_inr) = 0 THEN 0
             ELSE SUM(f.purchases_conversion_value_inr) / SUM(f.amount_spent_inr)
        END, 4
    ) AS roas
FROM growify.fact_marketing_performance f
JOIN growify.dim_campaign dc
    ON f.campaign_key = dc.campaign_key
GROUP BY dc.campaign_name
ORDER BY roas DESC
LIMIT 10;
--monthly trend
SELECT
    dd.year_num,
    dd.month_name,
    SUM(f.amount_spent_inr) AS total_spend,
    SUM(f.purchases_conversion_value_inr) AS total_revenue
FROM growify.fact_marketing_performance f
JOIN growify.dim_date dd
    ON f.date_key = dd.date_key
GROUP BY dd.year_num, dd.month_num, dd.month_name
ORDER BY dd.year_num, dd.month_num;


