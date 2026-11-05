-- Generic BigQuery example: historical account performance segmentation
-- Purpose:
--   Demonstrate the analytical structure of a monthly account-grading workflow.
--
-- Important:
--   This is a clean-room, generalized example based on the SQL approach discussed
--   in the project documentation. Source table names, field names, exclusions,
--   proprietary thresholds, and production-specific rules have been replaced.
--   Replace the illustrative source tables and fields before running.
--
-- Expected illustrative sources:
--   `sample_project.sample_dataset.fact_activity`
--     account_id, activity_id, activity_date, is_listed, is_successful
--     region, territory
--
--   `sample_project.sample_dataset.dim_account`
--     account_id, account_type
--
-- Configurable policy parameters are intentionally left as parameters rather
-- than embedding any original production cutoffs.

DECLARE evaluation_start DATE DEFAULT DATE '2024-01-01';
DECLARE low_conversion_cutoff FLOAT64 DEFAULT 0.35;
DECLARE high_conversion_cutoff FLOAT64 DEFAULT 0.60;
DECLARE low_historical_volume_cutoff INT64 DEFAULT 5;

WITH
-- 1. Create a consistent monthly evaluation calendar.
evaluation_months AS (
  SELECT
    month_start AS evaluation_month,
    DATE_SUB(month_start, INTERVAL 2 MONTH) AS recent_window_start
  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      evaluation_start,
      DATE_TRUNC(CURRENT_DATE(), MONTH),
      INTERVAL 1 MONTH
    )
  ) AS month_start
),

-- 2. Prepare eligible activity at account-month grain.
--    Production-specific exclusions are deliberately not reproduced here.
eligible_activity AS (
  SELECT
    activity.account_id,
    activity.region,
    activity.territory,
    DATE_TRUNC(activity.activity_date, MONTH) AS activity_month,
    COUNT(DISTINCT IF(activity.is_listed, activity.activity_id, NULL))
      AS activity_count,
    COUNT(DISTINCT IF(activity.is_successful, activity.activity_id, NULL))
      AS successful_activity_count
  FROM `sample_project.sample_dataset.fact_activity` AS activity
  LEFT JOIN `sample_project.sample_dataset.dim_account` AS account
    ON activity.account_id = account.account_id
  WHERE activity.account_id IS NOT NULL
    AND activity.activity_date >= DATE_SUB(evaluation_start, INTERVAL 12 MONTH)
    AND COALESCE(account.account_type, 'standard') = 'standard'
  GROUP BY
    activity.account_id,
    activity.region,
    activity.territory,
    activity_month
),

-- 3. Calculate recent performance using activity before each evaluation month.
recent_performance AS (
  SELECT
    activity.region,
    activity.territory,
    activity.account_id,
    months.evaluation_month,
    SUM(activity.activity_count) AS recent_activity_count,
    SUM(activity.successful_activity_count) AS recent_success_count
  FROM eligible_activity AS activity
  INNER JOIN evaluation_months AS months
    ON activity.activity_month >= months.recent_window_start
   AND activity.activity_month < months.evaluation_month
  GROUP BY
    activity.region,
    activity.territory,
    activity.account_id,
    months.evaluation_month
),

-- 4. Derive a recent conversion measure, guarding against division by zero.
recent_metrics AS (
  SELECT
    *,
    SAFE_DIVIDE(recent_success_count, recent_activity_count)
      AS recent_conversion_rate
  FROM recent_performance
  WHERE recent_success_count > 0
),

-- 5. Add longer-term context.
--    Historical activity and successful outcomes are calculated independently
--    so the analysis can compare recent performance with account history.
historical_context AS (
  SELECT
    metrics.region,
    metrics.territory,
    metrics.account_id,
    metrics.evaluation_month,
    SUM(
      IF(
        activity.activity_month >= DATE_SUB(metrics.evaluation_month, INTERVAL 12 MONTH)
        AND activity.activity_month < DATE_SUB(metrics.evaluation_month, INTERVAL 2 MONTH),
        activity.activity_count,
        0
      )
    ) AS earlier_activity_count,
    AVG(
      IF(
        activity.activity_month >= DATE_SUB(metrics.evaluation_month, INTERVAL 12 MONTH)
        AND activity.activity_month < metrics.evaluation_month,
        activity.successful_activity_count,
        NULL
      )
    ) AS average_monthly_success
  FROM recent_metrics AS metrics
  LEFT JOIN eligible_activity AS activity
    ON activity.account_id = metrics.account_id
   AND activity.region = metrics.region
   AND activity.territory = metrics.territory
   AND activity.activity_month >= DATE_SUB(metrics.evaluation_month, INTERVAL 12 MONTH)
   AND activity.activity_month < metrics.evaluation_month
  GROUP BY
    metrics.region,
    metrics.territory,
    metrics.account_id,
    metrics.evaluation_month
),

-- 6. Calculate peer-relative performance thresholds within each operating group.
peer_thresholds AS (
  SELECT
    region,
    territory,
    evaluation_month,
    APPROX_QUANTILES(recent_success_count, 3)[OFFSET(1)]
      AS lower_volume_quantile,
    APPROX_QUANTILES(recent_success_count, 3)[OFFSET(2)]
      AS upper_volume_quantile
  FROM recent_metrics
  GROUP BY region, territory, evaluation_month
),

-- 7. Assign relative bands for volume and conversion performance.
performance_bands AS (
  SELECT
    metrics.*,
    history.earlier_activity_count,
    history.average_monthly_success,
    thresholds.lower_volume_quantile,
    thresholds.upper_volume_quantile,
    CASE
      WHEN metrics.recent_success_count >= thresholds.upper_volume_quantile
        THEN 'HIGH'
      WHEN metrics.recent_success_count >= thresholds.lower_volume_quantile
        THEN 'MID'
      ELSE 'LOW'
    END AS volume_band,
    CASE
      WHEN metrics.recent_conversion_rate >= high_conversion_cutoff
        THEN 'HIGH'
      WHEN metrics.recent_conversion_rate >= low_conversion_cutoff
        THEN 'MID'
      ELSE 'LOW'
    END AS conversion_band
  FROM recent_metrics AS metrics
  LEFT JOIN historical_context AS history
    USING (region, territory, account_id, evaluation_month)
  LEFT JOIN peer_thresholds AS thresholds
    USING (region, territory, evaluation_month)
),

-- 8. Translate the combined indicators into an interpretable segment.
--    This is illustrative classification logic, not a production rule set.
final_classification AS (
  SELECT
    *,
    CASE
      WHEN conversion_band = 'LOW'
        OR (
          volume_band = 'LOW'
          AND COALESCE(average_monthly_success, 0) <= low_historical_volume_cutoff
        )
        OR COALESCE(earlier_activity_count, 0) = 0
        THEN 'FOUNDATIONAL'
      WHEN volume_band = 'HIGH' AND conversion_band = 'HIGH'
        THEN 'TOP_PERFORMER'
      ELSE 'CORE'
    END AS performance_segment
  FROM performance_bands
)

SELECT
  region,
  territory,
  account_id,
  evaluation_month,
  recent_activity_count,
  recent_success_count,
  recent_conversion_rate,
  earlier_activity_count,
  average_monthly_success,
  volume_band,
  conversion_band,
  performance_segment
FROM final_classification;
