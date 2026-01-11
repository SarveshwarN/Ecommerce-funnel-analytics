
#Splits revenue into mapped vs unmapped product_id,Quantifies how much revenue lacks product attribution,Calculates % contribution of each bucket
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
Business insights:
100% of revenue is unmapped to product_id, meaning product-level merchandising decisions cannot be made reliably.
Any “top products” or “category contribution” analysis would be misleading.
Business action:
Treat product attribution as a top analytics instrumentation priority (ensure purchase events always carry product_id).
Until fixed, avoid product-level decision-making based on this dataset.



#Ranks days by revenue. Computes how much revenue is driven by the top 20% of days. Measures temporal revenue concentration.
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
#Business insights
#High concentration means revenue depends heavily on campaign or spike days.
#Business action
#concentration is high: reduce dependence on spikes by improving baseline conversion.

#Joins revenue KPIs with funnel conversion. Shows whether revenue changes are driven by traffic,conversion, order value (AOV).
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

#Business insights
#Revenue drops with stable visits → conversion problem
#Stable conversion with falling revenue → AOV or pricing issue
#Rising conversion but flat revenue → low-value orders
#Business action
#Use this table as a weekly performance diagnostic to decide whether to focus on: UX & checkout improvements , pricing, bundling, or promotions




