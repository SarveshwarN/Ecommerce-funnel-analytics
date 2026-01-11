#Basic daily KPI trend
SELECT
  order_date,
  orders,
  ordering_users,
  net_gmv,
  aov
FROM gold.daily_kpis
ORDER BY order_date;

#Sorts days by total revenue
#Returns top 5 days 
SELECT TOP (5)
    order_date,
    net_gmv,
    orders,
    aov
FROM gold.daily_kpis
ORDER BY net_gmv DESC;
#Returns bottom 5 days 
SELECT TOP (5)
    order_date,
    net_gmv,
    orders,
    aov
FROM gold.daily_kpis
ORDER BY net_gmv ASC;
#Helps identify exceptional and problematic days



#Classifies purchasing users into first-time vs repeat by earliest observed purchase date.
WITH user_first_purchase AS (
  SELECT
    user_id,
    MIN(session_date) AS first_purchase_date
  FROM gold.session_funnel_flags
  WHERE did_purchase = 1
  GROUP BY user_id
),
daily_purchasers AS (
  SELECT DISTINCT
    session_date,
    user_id
  FROM gold.session_funnel_flags
  WHERE did_purchase = 1
)
SELECT
  d.session_date,
  SUM(CASE WHEN u.first_purchase_date = d.session_date THEN 1 ELSE 0 END) AS new_purchasers,
  SUM(CASE WHEN u.first_purchase_date < d.session_date THEN 1 ELSE 0 END) AS repeat_purchasers
FROM daily_purchasers d
JOIN user_first_purchase u
  ON d.user_id = u.user_id
GROUP BY d.session_date
ORDER BY d.session_date;

#Business insights:
#If repeat purchasers dominate, retention is strong; acquisition may be lagging.
#Here new purchasers dominate, acquisition is strong; focus shifts to post-purchase retention.
#Action: Allocate marketing budget based on mix (retention offers vs acquisition campaigns)

