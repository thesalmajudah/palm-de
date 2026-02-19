SELECT
    company_id,
    CAST(date AS DATE) AS activity_date,
    COALESCE(active_users, 0) AS active_users,
    COALESCE(events, 0) AS events
FROM bronze_product_usage_daily;