#Confirms the time window and how many days have activity
SELECT
  MIN(order_date) AS min_order_date,
  MAX(order_date) AS max_order_date,
  COUNT(DISTINCT order_date) AS active_order_days
FROM gold.daily_kpis;

#Checks that stage volumes decrease (or stay flat) as users progress.
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

#Gives baseline totals and average daily AOV.
  SELECT
  SUM(orders) AS total_orders,
  SUM(ordering_users) AS total_ordering_users,
  SUM(net_gmv) AS total_revenue,
  AVG(aov) AS avg_daily_aov
FROM gold.daily_kpis;


#Converts binary flags into percentages of sessions reaching each stage
  SELECT
  COUNT(*) AS total_sessions,
  AVG(did_view) AS pct_sessions_with_view,
  AVG(did_add_to_cart) AS pct_sessions_with_cart,
  AVG(did_checkout) AS pct_sessions_with_checkout,
  AVG(did_purchase) AS pct_sessions_with_purchase

FROM gold.session_funnel_flags;

#view is strong but cart is weak, product page or pricing may be the friction.
#Action: Prioritize experiments where the drop is highest (e.g., PDP improvements, pricing tests, shipping clarity).
