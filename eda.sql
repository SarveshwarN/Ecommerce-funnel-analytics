SELECT
  MIN(order_date) AS min_order_date,
  MAX(order_date) AS max_order_date,
  COUNT(DISTINCT order_date) AS active_order_days
FROM gold.daily_kpis;

SELECT
  stage,
  SUM(sessions) AS total_sessions
FROM gold.funnel_summary_daily
GROUP BY stage
ORDER BY
  CASE stage
    WHEN 'visited' THEN 1
    WHEN 'view' THEN 2
    WHEN 'add_to_cart' THEN 3
    WHEN 'checkout' THEN 4
    WHEN 'purchase' THEN 5
    ELSE 99
  END;

  SELECT
  SUM(orders) AS total_orders,
  SUM(ordering_users) AS total_ordering_users,
  SUM(net_gmv) AS total_revenue,
  AVG(aov) AS avg_daily_aov
FROM gold.daily_kpis;


SELECT
  COUNT(*) AS total_sessions,
  AVG(did_view) AS pct_sessions_with_view,
  AVG(did_add_to_cart) AS pct_sessions_with_cart,
  AVG(did_checkout) AS pct_sessions_with_checkout,
  AVG(did_purchase) AS pct_sessions_with_purchase
FROM gold.session_funnel_flags;