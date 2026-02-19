SELECT
    company_id,
    TRIM(name) AS company_name,
    country,
    industry_tag,
    CAST(last_contact_at AS DATE) AS last_contact_at
FROM bronze_crm_company_daily;