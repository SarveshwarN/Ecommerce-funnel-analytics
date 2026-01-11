#Computes overall stage totals and drop-off % between consecutive stages.
WITH stage_totals AS (
  SELECT
    stage,
    SUM(sessions) AS sessions
  FROM gold.funnel_summary_daily
  GROUP BY stage
),
ordered AS (
  SELECT
    stage,
    sessions,
    CASE stage
      WHEN 'visited' THEN 1
      WHEN 'view' THEN 2
      WHEN 'add_to_cart' THEN 3
      WHEN 'checkout' THEN 4
      WHEN 'purchase' THEN 5
      ELSE 99
    END AS stage_rank
  FROM stage_totals
),
calc AS (
  SELECT
    stage,
    sessions,
    LAG(sessions) OVER (ORDER BY stage_rank) AS prev_sessions
  FROM ordered
)
SELECT
  stage,
  sessions,
  prev_sessions,
  CASE
    WHEN prev_sessions IS NULL OR prev_sessions = 0 THEN NULL
    ELSE ROUND(100.0 * sessions / prev_sessions, 2)
  END AS pct_from_prev,
  CASE
    WHEN prev_sessions IS NULL OR prev_sessions = 0 THEN NULL
    ELSE ROUND(100.0 * (prev_sessions - sessions) / prev_sessions, 2)
  END AS dropoff_pct_from_prev
FROM calc
ORDER BY
  CASE stage
    WHEN 'visited' THEN 1
    WHEN 'view' THEN 2
    WHEN 'add_to_cart' THEN 3
    WHEN 'checkout' THEN 4
    WHEN 'purchase' THEN 5
    ELSE 99
  END;


#Returns the single funnel step with the maximum drop-off.
WITH stage_totals AS (
    SELECT
        stage,
        SUM(sessions) AS sessions
    FROM gold.funnel_summary_daily
    GROUP BY stage
),
ordered AS (
    SELECT
        stage,
        sessions,
        CASE stage
            WHEN 'visited' THEN 1
            WHEN 'view' THEN 2
            WHEN 'add_to_cart' THEN 3
            WHEN 'checkout' THEN 4
            WHEN 'purchase' THEN 5
            ELSE 99
        END AS stage_rank
    FROM stage_totals
),
calc AS (
    SELECT
        stage,
        sessions,
        LAG(stage)    OVER (ORDER BY stage_rank) AS prev_stage,
        LAG(sessions) OVER (ORDER BY stage_rank) AS prev_sessions
    FROM ordered
)
SELECT TOP (1)
    CONCAT(prev_stage, ' → ', stage) AS funnel_step,
    prev_sessions,
    sessions AS next_sessions,
    ROUND(100.0 * (prev_sessions - sessions) / NULLIF(prev_sessions, 0), 2) AS dropoff_pct
FROM calc
WHERE prev_stage IS NOT NULL
ORDER BY dropoff_pct DESC;

#Calculates daily conversion rate from visited sessions to purchase sessions.
WITH daily AS (
  SELECT
    session_date,
    SUM(CASE WHEN stage = 'visited' THEN sessions ELSE 0 END) AS visited_sessions,
    SUM(CASE WHEN stage = 'purchase' THEN sessions ELSE 0 END) AS purchase_sessions
  FROM gold.funnel_summary_daily
  GROUP BY session_date
)
SELECT
  session_date,
  visited_sessions,
  purchase_sessions,
  ROUND(100.0 * purchase_sessions / NULLIF(visited_sessions, 0), 2) AS visit_to_purchase_cvr_pct
FROM daily

ORDER BY session_date;
