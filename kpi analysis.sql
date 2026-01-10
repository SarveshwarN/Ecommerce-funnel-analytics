SELECT
  order_date,
  orders,
  ordering_users,
  net_gmv,
  aov
FROM gold.daily_kpis
ORDER BY order_date;

SELECT TOP (5)
    order_date,
    net_gmv,
    orders,
    aov
FROM gold.daily_kpis
ORDER BY net_gmv DESC;

SELECT TOP (5)
    order_date,
    net_gmv,
    orders,
    aov
FROM gold.daily_kpis
ORDER BY net_gmv ASC;




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
