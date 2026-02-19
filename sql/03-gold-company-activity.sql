WITH joined AS (
    SELECT
        f.activity_date,
        f.company_id,
        d.company_name,
        d.country,
        d.industry_tag,
        d.last_contact_at,
        f.active_users,
        f.events
    FROM silver_fact_company_usage_daily f
    LEFT JOIN silver_dim_company d
        ON f.company_id = d.company_id
),

rolling AS (
    SELECT
        *,
        SUM(active_users) OVER (
            PARTITION BY company_id
            ORDER BY activity_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS active_users_7d,

        SUM(events) OVER (
            PARTITION BY company_id
            ORDER BY activity_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS events_7d
    FROM joined
)

SELECT
    *,
    CASE 
        WHEN active_users_7d = 0
        AND last_contact_at < DATEADD(day, -30, CURRENT_DATE)
        THEN TRUE
        ELSE FALSE
    END AS is_churn_risk
FROM rolling;