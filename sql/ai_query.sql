SELECT
    dd.year_num,
    dd.month_num,
    dd.month_name,
    dc.data_source_name,
    dc.campaign_funnel_stage,
    dc.campaign_region,
    dc.geo_location_segment,
    SUM(f.amount_spent_inr) AS total_spend,
    SUM(f.purchases_conversion_value_inr) AS total_sales,
    SUM(f.impressions) AS total_impressions,
    SUM(f.link_clicks) AS total_link_clicks,
    SUM(f.purchases) AS total_purchases,
    ROUND(
        CASE WHEN SUM(f.impressions) = 0 THEN 0
             ELSE (SUM(f.link_clicks) * 100.0 / SUM(f.impressions))
        END, 4
    ) AS ctr_percent,
    ROUND(
        CASE WHEN SUM(f.link_clicks) = 0 THEN 0
             ELSE (SUM(f.amount_spent_inr) / SUM(f.link_clicks))
        END, 4
    ) AS cpc,
    ROUND(
        CASE WHEN SUM(f.amount_spent_inr) = 0 THEN 0
             ELSE (SUM(f.purchases_conversion_value_inr) / SUM(f.amount_spent_inr))
        END, 4
    ) AS roas
FROM growify.fact_marketing_performance f
JOIN growify.dim_campaign dc
    ON f.campaign_key = dc.campaign_key
JOIN growify.dim_date dd
    ON f.date_key = dd.date_key
GROUP BY
    dd.year_num,
    dd.month_num,
    dd.month_name,
    dc.data_source_name,
    dc.campaign_funnel_stage,
    dc.campaign_region,
    dc.geo_location_segment
ORDER BY
    dd.year_num,
    dd.month_num,
    dc.data_source_name;