SELECT
  c.COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'silver'
  AND c.TABLE_NAME = 'products'
ORDER BY c.ORDINAL_POSITION;


SELECT
  c.COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'gold'
  AND c.TABLE_NAME = 'product_sales_daily'
ORDER BY c.ORDINAL_POSITION;

SELECT TOP (20)
    product_id,
    MAX(title) AS title,
    MAX(category) AS category,
    SUM(gross_sales_usd) AS revenue,
    SUM(qty) AS units
FROM gold.product_sales_daily
WHERE product_id IS NOT NULL
GROUP BY product_id
ORDER BY revenue DESC;


SELECT TOP (20) *
FROM gold.product_sales_daily
WHERE product_id IS NOT NULL
  AND (title IS NULL OR category IS NULL);


SELECT
    COUNT(*) AS rows_unmapped,
    SUM(gross_sales_usd) AS revenue_unmapped,
    SUM(qty) AS units_unmapped
FROM gold.product_sales_daily
WHERE product_id IS NULL;


SELECT TOP (20)
    product_id,
    COALESCE(MAX(title), 'Unknown Title') AS title,
    COALESCE(MAX(category), 'Unknown Category') AS category,
    SUM(gross_sales_usd) AS revenue,
    SUM(qty) AS units
FROM gold.product_sales_daily
WHERE product_id IS NOT NULL
GROUP BY product_id
ORDER BY revenue DESC;

#Splits revenue into mapped vs unmapped product_id
#Quantifies how much revenue lacks product attribution
#Calculates % contribution of each bucket
SELECT
    CASE WHEN product_id IS NULL THEN 'UNMAPPED_PRODUCT' ELSE 'MAPPED_PRODUCT' END AS product_mapping,
    SUM(gross_sales_usd) AS revenue,
    ROUND(100.0 * SUM(gross_sales_usd) / NULLIF(SUM(SUM(gross_sales_usd)) OVER (), 0), 2) AS revenue_share_pct
FROM gold.product_sales_daily
GROUP BY CASE WHEN product_id IS NULL THEN 'UNMAPPED_PRODUCT' ELSE 'MAPPED_PRODUCT' END;
#Business insights
100% of revenue is unmapped to product_id, meaning product-level merchandising decisions cannot be made reliably.
Any “top products” or “category contribution” analysis would be misleading.
Business action
Treat product attribution as a top analytics instrumentation priority (ensure purchase events always carry product_id).
Until fixed, avoid product-level decision-making based on this dataset.

SELECT
  CASE WHEN product_id IS NULL THEN 'UNMAPPED_PRODUCT' ELSE 'MAPPED_PRODUCT' END AS product_mapping,
  COUNT(*) AS rows,
  SUM(gross_sales_usd) AS revenue,
  ROUND(
    100.0 * SUM(gross_sales_usd) / NULLIF(SUM(SUM(gross_sales_usd)) OVER (), 0),
    2
  ) AS revenue_share_pct
FROM gold.product_sales_daily
GROUP BY CASE WHEN product_id IS NULL THEN 'UNMAPPED_PRODUCT' ELSE 'MAPPED_PRODUCT' END;

SELECT
  SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS null_title_rows,
  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category_rows,
  COUNT(*) AS total_rows
FROM gold.product_sales_daily;


SELECT
  CASE
    WHEN product_id IS NULL THEN 'UNMAPPED_PRODUCT'
    ELSE 'MAPPED_PRODUCT'
  END AS product_mapping,
  COUNT(*) AS rows,
  SUM(gross_sales_usd) AS revenue,
  ROUND(
    100.0 * SUM(gross_sales_usd)
    / NULLIF(SUM(SUM(gross_sales_usd)) OVER (), 0),
    2
  ) AS revenue_share_pct

FROM gold.product_sales_daily
GROUP BY
  CASE
    WHEN product_id IS NULL THEN 'UNMAPPED_PRODUCT'
    ELSE 'MAPPED_PRODUCT'
  END;

WITH d AS (
  SELECT
    order_date,
    net_gmv,
    ROW_NUMBER() OVER (ORDER BY net_gmv DESC) AS rn,
    COUNT(*) OVER () AS total_days,
    SUM(net_gmv) OVER () AS total_revenue
  FROM gold.daily_kpis
),
top_days AS (
  SELECT
    SUM(net_gmv) AS top_revenue,
    MAX(total_revenue) AS total_revenue
  FROM d
  WHERE rn <= CEILING(0.2 * total_days)
)
SELECT
  top_revenue,
  total_revenue,
  ROUND(
    100.0 * top_revenue / NULLIF(total_revenue, 0),
    2
  ) AS top_20pct_days_revenue_share
FROM top_days;


WITH kpi AS (
  SELECT
    order_date,
    orders,
    net_gmv,
    aov
  FROM gold.daily_kpis
),
cvr AS (
  SELECT
    session_date,
    SUM(CASE WHEN stage = 'visited' THEN sessions ELSE 0 END) AS visited_sessions,
    SUM(CASE WHEN stage = 'purchase' THEN sessions ELSE 0 END) AS purchase_sessions
  FROM gold.funnel_summary_daily
  GROUP BY session_date
)
SELECT
  k.order_date,
  k.orders,
  k.net_gmv,
  k.aov,
  c.visited_sessions,
  c.purchase_sessions,
  ROUND(
    100.0 * c.purchase_sessions
    / NULLIF(c.visited_sessions, 0),
    2
  ) AS visit_to_purchase_cvr_pct
FROM kpi k
LEFT JOIN cvr c
  ON k.order_date = c.session_date
ORDER BY k.order_date;

