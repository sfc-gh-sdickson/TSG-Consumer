/*===========================================================================
  TSG Consumer Partners — Step 8: ML Model Functions & Agent UDFs
  Script: 08_ml_model_functions.sql
  
  Prerequisites: Run scripts 01-07 first (notebook must be run to register models)
  Creates UDF functions that call registered ML models from the Snowflake
  Model Registry and return enriched results for the Cortex Agent.
===========================================================================*/

USE ROLE ACCOUNTADMIN;
USE DATABASE TSG_INTELLIGENCE;
USE SCHEMA MODELS;
USE WAREHOUSE TSG_WH;

CREATE OR REPLACE FUNCTION TSG_INTELLIGENCE.MODELS.AGENT_GET_LTV_SCORES()
  RETURNS ARRAY
  LANGUAGE SQL
  COMMENT = 'Returns brand lifetime value scores using the registered TSG_BRAND_LTV_MODEL from the Snowflake Model Registry'
AS
$$
  WITH features AS (
    SELECT
      pc.COMPANY_ID,
      pc.COMPANY_NAME,
      pc.SECTOR,
      COALESCE(pc.INVESTMENT_AMOUNT, 0)::FLOAT AS INVESTMENT_AMOUNT,
      COALESCE(pc.EMPLOYEE_COUNT, 0) AS EMPLOYEE_COUNT,
      COALESCE(rev.avg_revenue, 0)::FLOAT AS AVG_REVENUE,
      COALESCE(rev.avg_gross_margin, 0)::FLOAT AS AVG_GROSS_MARGIN,
      COALESCE(rev.avg_ebitda_margin, 0)::FLOAT AS AVG_EBITDA_MARGIN,
      COALESCE(rev.avg_growth, 0)::FLOAT AS AVG_REVENUE_GROWTH,
      COALESCE(bm.avg_brand_equity, 0)::FLOAT AS AVG_BRAND_EQUITY,
      COALESCE(bm.avg_nps, 0)::FLOAT AS AVG_NPS,
      COALESCE(bm.avg_social_engagement, 0)::FLOAT AS AVG_SOCIAL_ENGAGEMENT,
      COALESCE(da.avg_conversion, 0)::FLOAT AS AVG_CONVERSION_RATE,
      COALESCE(da.avg_ltv_cac, 0)::FLOAT AS AVG_LTV_CAC,
      COALESCE(mr.market_growth, 0)::FLOAT AS MARKET_GROWTH_RATE,
      0 AS SECTOR_ENCODED
    FROM TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES pc
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(REVENUE) AS avg_revenue, AVG(GROSS_MARGIN) AS avg_gross_margin,
             AVG(EBITDA_MARGIN) AS avg_ebitda_margin, AVG(REVENUE_GROWTH_YOY) AS avg_growth
      FROM TSG_INTELLIGENCE.ANALYTICS.REVENUE_DATA WHERE FISCAL_YEAR >= 2024 GROUP BY COMPANY_ID
    ) rev ON pc.COMPANY_ID = rev.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(BRAND_EQUITY_INDEX) AS avg_brand_equity, AVG(NET_PROMOTER_SCORE) AS avg_nps,
             AVG(SOCIAL_ENGAGEMENT) AS avg_social_engagement
      FROM TSG_INTELLIGENCE.ANALYTICS.BRAND_METRICS WHERE METRIC_DATE >= '2024-01-01' GROUP BY COMPANY_ID
    ) bm ON pc.COMPANY_ID = bm.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(CONVERSION_RATE) AS avg_conversion, AVG(LTV_CAC_RATIO) AS avg_ltv_cac
      FROM TSG_INTELLIGENCE.ANALYTICS.DIGITAL_ANALYTICS WHERE METRIC_DATE >= '2024-01-01' GROUP BY COMPANY_ID
    ) da ON pc.COMPANY_ID = da.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(MARKET_GROWTH_RATE) AS market_growth
      FROM TSG_INTELLIGENCE.ANALYTICS.MARKET_RESEARCH GROUP BY COMPANY_ID
    ) mr ON pc.COMPANY_ID = mr.COMPANY_ID
    WHERE pc.STATUS = 'Active'
  ),
  predictions AS (
    SELECT
      f.COMPANY_NAME,
      f.SECTOR,
      f.AVG_REVENUE,
      f.AVG_BRAND_EQUITY,
      f.AVG_REVENUE_GROWTH,
      f.AVG_NPS,
      f.MARKET_GROWTH_RATE,
      MODEL(TSG_INTELLIGENCE.MODELS.TSG_BRAND_LTV_MODEL, v2)!PREDICT(
        f.INVESTMENT_AMOUNT, f.EMPLOYEE_COUNT, f.AVG_REVENUE, f.AVG_GROSS_MARGIN,
        f.AVG_EBITDA_MARGIN, f.AVG_REVENUE_GROWTH, f.AVG_BRAND_EQUITY,
        f.AVG_NPS, f.AVG_SOCIAL_ENGAGEMENT, f.AVG_CONVERSION_RATE,
        f.AVG_LTV_CAC, f.MARKET_GROWTH_RATE, f.SECTOR_ENCODED
      ):output_feature_0::FLOAT AS ltv_score
    FROM features f
  )
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'company_name', p.COMPANY_NAME,
    'sector', p.SECTOR,
    'ltv_score', ROUND(p.ltv_score, 2),
    'avg_revenue_m', ROUND(p.AVG_REVENUE / 1000000, 2),
    'brand_equity_index', ROUND(p.AVG_BRAND_EQUITY, 2),
    'revenue_growth_pct', ROUND(p.AVG_REVENUE_GROWTH, 2),
    'nps', ROUND(p.AVG_NPS, 1),
    'market_growth_rate', ROUND(p.MARKET_GROWTH_RATE, 2),
    'ltv_tier', CASE
      WHEN p.ltv_score >= 200 THEN 'Platinum'
      WHEN p.ltv_score >= 100 THEN 'Gold'
      WHEN p.ltv_score >= 50 THEN 'Silver'
      ELSE 'Bronze'
    END
  ))
  FROM predictions p
$$;

CREATE OR REPLACE FUNCTION TSG_INTELLIGENCE.MODELS.AGENT_GET_CHURN_RISK()
  RETURNS ARRAY
  LANGUAGE SQL
  COMMENT = 'Returns churn risk scores using the registered TSG_CHURN_RISK_MODEL from the Snowflake Model Registry'
AS
$$
  WITH features AS (
    SELECT
      pc.COMPANY_ID,
      pc.COMPANY_NAME,
      pc.SECTOR,
      COALESCE(pc.INVESTMENT_AMOUNT, 0)::FLOAT AS INVESTMENT_AMOUNT,
      COALESCE(pc.EMPLOYEE_COUNT, 0) AS EMPLOYEE_COUNT,
      COALESCE(rev.avg_revenue, 0)::FLOAT AS AVG_REVENUE,
      COALESCE(rev.avg_gross_margin, 0)::FLOAT AS AVG_GROSS_MARGIN,
      COALESCE(rev.avg_ebitda_margin, 0)::FLOAT AS AVG_EBITDA_MARGIN,
      COALESCE(rev.avg_growth, 0)::FLOAT AS AVG_REVENUE_GROWTH,
      COALESCE(bm.avg_brand_equity, 0)::FLOAT AS AVG_BRAND_EQUITY,
      COALESCE(bm.avg_nps, 0)::FLOAT AS AVG_NPS,
      COALESCE(bm.avg_social_engagement, 0)::FLOAT AS AVG_SOCIAL_ENGAGEMENT,
      COALESCE(da.avg_conversion, 0)::FLOAT AS AVG_CONVERSION_RATE,
      COALESCE(da.avg_ltv_cac, 0)::FLOAT AS AVG_LTV_CAC,
      COALESCE(mr.market_growth, 0)::FLOAT AS MARKET_GROWTH_RATE,
      COALESCE(bm.avg_csat, 0)::FLOAT AS AVG_CSAT,
      COALESCE(ops.avg_dso, 0)::FLOAT AS AVG_DSO,
      0 AS SECTOR_ENCODED
    FROM TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES pc
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(REVENUE) AS avg_revenue, AVG(GROSS_MARGIN) AS avg_gross_margin,
             AVG(EBITDA_MARGIN) AS avg_ebitda_margin, AVG(REVENUE_GROWTH_YOY) AS avg_growth
      FROM TSG_INTELLIGENCE.ANALYTICS.REVENUE_DATA WHERE FISCAL_YEAR >= 2024 GROUP BY COMPANY_ID
    ) rev ON pc.COMPANY_ID = rev.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(BRAND_EQUITY_INDEX) AS avg_brand_equity, AVG(NET_PROMOTER_SCORE) AS avg_nps,
             AVG(SOCIAL_ENGAGEMENT) AS avg_social_engagement, AVG(CUSTOMER_SAT_SCORE) AS avg_csat
      FROM TSG_INTELLIGENCE.ANALYTICS.BRAND_METRICS WHERE METRIC_DATE >= '2024-06-01' GROUP BY COMPANY_ID
    ) bm ON pc.COMPANY_ID = bm.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(CONVERSION_RATE) AS avg_conversion, AVG(LTV_CAC_RATIO) AS avg_ltv_cac
      FROM TSG_INTELLIGENCE.ANALYTICS.DIGITAL_ANALYTICS WHERE METRIC_DATE >= '2024-06-01' GROUP BY COMPANY_ID
    ) da ON pc.COMPANY_ID = da.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(MARKET_GROWTH_RATE) AS market_growth
      FROM TSG_INTELLIGENCE.ANALYTICS.MARKET_RESEARCH GROUP BY COMPANY_ID
    ) mr ON pc.COMPANY_ID = mr.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(DAYS_SALES_OUTSTANDING) AS avg_dso
      FROM TSG_INTELLIGENCE.ANALYTICS.OPERATIONS_METRICS WHERE METRIC_DATE >= '2024-06-01' GROUP BY COMPANY_ID
    ) ops ON pc.COMPANY_ID = ops.COMPANY_ID
    WHERE pc.STATUS = 'Active'
  ),
  predictions AS (
    SELECT
      f.*,
      MODEL(TSG_INTELLIGENCE.MODELS.TSG_CHURN_RISK_MODEL, v2)!PREDICT(
        f.INVESTMENT_AMOUNT, f.EMPLOYEE_COUNT, f.AVG_REVENUE, f.AVG_GROSS_MARGIN,
        f.AVG_EBITDA_MARGIN, f.AVG_REVENUE_GROWTH, f.AVG_BRAND_EQUITY,
        f.AVG_NPS, f.AVG_SOCIAL_ENGAGEMENT, f.AVG_CONVERSION_RATE,
        f.AVG_LTV_CAC, f.MARKET_GROWTH_RATE, f.SECTOR_ENCODED
      ):output_feature_0::INT AS churn_prediction
    FROM features f
  )
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'company_name', p.COMPANY_NAME,
    'sector', p.SECTOR,
    'churn_prediction', p.churn_prediction,
    'nps_score', ROUND(p.AVG_NPS, 1),
    'csat_score', ROUND(p.AVG_CSAT, 2),
    'revenue_growth', ROUND(p.AVG_REVENUE_GROWTH, 2),
    'dso', ROUND(p.AVG_DSO, 2),
    'risk_level', CASE
      WHEN p.churn_prediction = 1 THEN 'High'
      ELSE 'Low'
    END,
    'key_risk_factors', ARRAY_CONSTRUCT_COMPACT(
      CASE WHEN p.AVG_NPS < 30 THEN 'Low NPS' END,
      CASE WHEN p.AVG_CSAT < 65 THEN 'Low CSAT' END,
      CASE WHEN p.AVG_REVENUE_GROWTH < 0 THEN 'Declining Revenue' END,
      CASE WHEN p.AVG_DSO > 50 THEN 'High DSO' END
    )
  ))
  FROM predictions p
$$;

CREATE OR REPLACE FUNCTION TSG_INTELLIGENCE.MODELS.AGENT_GET_FORECASTS()
  RETURNS ARRAY
  LANGUAGE SQL
  COMMENT = 'Returns revenue growth forecasts using the registered TSG_REVENUE_FORECAST_MODEL from the Snowflake Model Registry'
AS
$$
  WITH features AS (
    SELECT
      pc.COMPANY_ID,
      pc.COMPANY_NAME,
      pc.SECTOR,
      COALESCE(pc.INVESTMENT_AMOUNT, 0)::FLOAT AS INVESTMENT_AMOUNT,
      COALESCE(pc.EMPLOYEE_COUNT, 0) AS EMPLOYEE_COUNT,
      COALESCE(rev.avg_revenue, 0)::FLOAT AS AVG_REVENUE,
      COALESCE(rev.avg_gross_margin, 0)::FLOAT AS AVG_GROSS_MARGIN,
      COALESCE(rev.avg_ebitda_margin, 0)::FLOAT AS AVG_EBITDA_MARGIN,
      COALESCE(rev.avg_growth, 0)::FLOAT AS AVG_REVENUE_GROWTH,
      COALESCE(bm.avg_brand_equity, 0)::FLOAT AS AVG_BRAND_EQUITY,
      COALESCE(bm.avg_nps, 0)::FLOAT AS AVG_NPS,
      COALESCE(bm.avg_social_engagement, 0)::FLOAT AS AVG_SOCIAL_ENGAGEMENT,
      COALESCE(da.avg_conversion, 0)::FLOAT AS AVG_CONVERSION_RATE,
      COALESCE(da.avg_ltv_cac, 0)::FLOAT AS AVG_LTV_CAC,
      COALESCE(mr.market_growth, 0)::FLOAT AS MARKET_GROWTH_RATE,
      COALESCE(current_rev.total_rev, 0)::FLOAT AS TOTAL_CURRENT_REV,
      COALESCE(hist.data_points, 0) AS DATA_POINTS,
      0 AS SECTOR_ENCODED
    FROM TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES pc
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(REVENUE) AS avg_revenue, AVG(GROSS_MARGIN) AS avg_gross_margin,
             AVG(EBITDA_MARGIN) AS avg_ebitda_margin, AVG(REVENUE_GROWTH_YOY) AS avg_growth
      FROM TSG_INTELLIGENCE.ANALYTICS.REVENUE_DATA WHERE FISCAL_YEAR >= 2024 GROUP BY COMPANY_ID
    ) rev ON pc.COMPANY_ID = rev.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(BRAND_EQUITY_INDEX) AS avg_brand_equity, AVG(NET_PROMOTER_SCORE) AS avg_nps,
             AVG(SOCIAL_ENGAGEMENT) AS avg_social_engagement
      FROM TSG_INTELLIGENCE.ANALYTICS.BRAND_METRICS WHERE METRIC_DATE >= '2024-01-01' GROUP BY COMPANY_ID
    ) bm ON pc.COMPANY_ID = bm.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(CONVERSION_RATE) AS avg_conversion, AVG(LTV_CAC_RATIO) AS avg_ltv_cac
      FROM TSG_INTELLIGENCE.ANALYTICS.DIGITAL_ANALYTICS WHERE METRIC_DATE >= '2024-01-01' GROUP BY COMPANY_ID
    ) da ON pc.COMPANY_ID = da.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(MARKET_GROWTH_RATE) AS market_growth
      FROM TSG_INTELLIGENCE.ANALYTICS.MARKET_RESEARCH GROUP BY COMPANY_ID
    ) mr ON pc.COMPANY_ID = mr.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, SUM(REVENUE) AS total_rev
      FROM TSG_INTELLIGENCE.ANALYTICS.REVENUE_DATA WHERE FISCAL_YEAR = 2025 GROUP BY COMPANY_ID
    ) current_rev ON pc.COMPANY_ID = current_rev.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, COUNT(*) AS data_points
      FROM TSG_INTELLIGENCE.ANALYTICS.REVENUE_DATA WHERE FISCAL_YEAR >= 2023 GROUP BY COMPANY_ID
    ) hist ON pc.COMPANY_ID = hist.COMPANY_ID
    WHERE pc.STATUS = 'Active'
  ),
  predictions AS (
    SELECT
      f.*,
      MODEL(TSG_INTELLIGENCE.MODELS.TSG_REVENUE_FORECAST_MODEL, v2)!PREDICT(
        f.INVESTMENT_AMOUNT, f.EMPLOYEE_COUNT, f.AVG_REVENUE, f.AVG_GROSS_MARGIN,
        f.AVG_EBITDA_MARGIN, f.AVG_REVENUE_GROWTH, f.AVG_BRAND_EQUITY,
        f.AVG_NPS, f.AVG_SOCIAL_ENGAGEMENT, f.AVG_CONVERSION_RATE,
        f.AVG_LTV_CAC, f.MARKET_GROWTH_RATE, f.SECTOR_ENCODED
      ):output_feature_0::FLOAT AS forecast_growth_pct
    FROM features f
  )
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'company_name', p.COMPANY_NAME,
    'sector', p.SECTOR,
    'current_annual_revenue_m', ROUND(p.TOTAL_CURRENT_REV / 1000000, 2),
    'historical_growth_pct', ROUND(p.AVG_REVENUE_GROWTH, 2),
    'market_growth_pct', ROUND(p.MARKET_GROWTH_RATE, 2),
    'forecast_growth_pct', ROUND(p.forecast_growth_pct, 2),
    'forecast_revenue_m', ROUND((p.TOTAL_CURRENT_REV / 1000000) * (1 + p.forecast_growth_pct / 100), 2),
    'confidence', CASE
      WHEN p.DATA_POINTS >= 8 THEN 'High'
      WHEN p.DATA_POINTS >= 4 THEN 'Medium'
      ELSE 'Low'
    END,
    'growth_outlook', CASE
      WHEN p.forecast_growth_pct >= 15 THEN 'Accelerating'
      WHEN p.forecast_growth_pct >= 8 THEN 'Steady Growth'
      WHEN p.forecast_growth_pct >= 0 THEN 'Moderate'
      ELSE 'Declining'
    END
  ))
  FROM predictions p
$$;

CREATE OR REPLACE FUNCTION TSG_INTELLIGENCE.MODELS.AGENT_GET_OPPORTUNITIES()
  RETURNS ARRAY
  LANGUAGE SQL
  COMMENT = 'Returns market opportunity scores using the registered TSG_MARKET_OPPORTUNITY_MODEL from the Snowflake Model Registry'
AS
$$
  WITH features AS (
    SELECT
      pc.COMPANY_ID,
      pc.COMPANY_NAME,
      pc.SECTOR,
      COALESCE(pc.INVESTMENT_AMOUNT, 0)::FLOAT AS INVESTMENT_AMOUNT,
      COALESCE(pc.EMPLOYEE_COUNT, 0) AS EMPLOYEE_COUNT,
      COALESCE(rev.avg_revenue, 0)::FLOAT AS AVG_REVENUE,
      COALESCE(rev.avg_gross_margin, 0)::FLOAT AS AVG_GROSS_MARGIN,
      COALESCE(rev.avg_ebitda_margin, 0)::FLOAT AS AVG_EBITDA_MARGIN,
      COALESCE(rev.avg_growth, 0)::FLOAT AS AVG_REVENUE_GROWTH,
      COALESCE(bm.avg_brand_equity, 0)::FLOAT AS AVG_BRAND_EQUITY,
      COALESCE(bm.avg_nps, 0)::FLOAT AS AVG_NPS,
      COALESCE(bm.avg_social_engagement, 0)::FLOAT AS AVG_SOCIAL_ENGAGEMENT,
      COALESCE(da.avg_conversion, 0)::FLOAT AS AVG_CONVERSION_RATE,
      COALESCE(da.avg_ltv_cac, 0)::FLOAT AS AVG_LTV_CAC,
      COALESCE(mr.MARKET_GROWTH_RATE, 0)::FLOAT AS MARKET_GROWTH_RATE,
      COALESCE(mr.MARKET_SIZE_USD, 0)::FLOAT AS MARKET_SIZE_USD,
      COALESCE(mr.TAM_USD, 0)::FLOAT AS TAM_USD,
      COALESCE(mr.COMPETITIVE_POSITION, 'Unknown') AS COMPETITIVE_POSITION,
      COALESCE(mr.CONSUMER_TREND, 'N/A') AS CONSUMER_TREND,
      0 AS SECTOR_ENCODED
    FROM TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES pc
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(REVENUE) AS avg_revenue, AVG(GROSS_MARGIN) AS avg_gross_margin,
             AVG(EBITDA_MARGIN) AS avg_ebitda_margin, AVG(REVENUE_GROWTH_YOY) AS avg_growth
      FROM TSG_INTELLIGENCE.ANALYTICS.REVENUE_DATA WHERE FISCAL_YEAR >= 2024 GROUP BY COMPANY_ID
    ) rev ON pc.COMPANY_ID = rev.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(BRAND_EQUITY_INDEX) AS avg_brand_equity, AVG(NET_PROMOTER_SCORE) AS avg_nps,
             AVG(SOCIAL_ENGAGEMENT) AS avg_social_engagement
      FROM TSG_INTELLIGENCE.ANALYTICS.BRAND_METRICS WHERE METRIC_DATE >= '2024-01-01' GROUP BY COMPANY_ID
    ) bm ON pc.COMPANY_ID = bm.COMPANY_ID
    LEFT JOIN (
      SELECT COMPANY_ID, AVG(CONVERSION_RATE) AS avg_conversion, AVG(LTV_CAC_RATIO) AS avg_ltv_cac
      FROM TSG_INTELLIGENCE.ANALYTICS.DIGITAL_ANALYTICS WHERE METRIC_DATE >= '2024-06-01' GROUP BY COMPANY_ID
    ) da ON pc.COMPANY_ID = da.COMPANY_ID
    LEFT JOIN TSG_INTELLIGENCE.ANALYTICS.MARKET_RESEARCH mr ON pc.COMPANY_ID = mr.COMPANY_ID
    WHERE pc.STATUS = 'Active'
  ),
  predictions AS (
    SELECT
      f.*,
      MODEL(TSG_INTELLIGENCE.MODELS.TSG_MARKET_OPPORTUNITY_MODEL, v2)!PREDICT(
        f.INVESTMENT_AMOUNT, f.EMPLOYEE_COUNT, f.AVG_REVENUE, f.AVG_GROSS_MARGIN,
        f.AVG_EBITDA_MARGIN, f.AVG_REVENUE_GROWTH, f.AVG_BRAND_EQUITY,
        f.AVG_NPS, f.AVG_SOCIAL_ENGAGEMENT, f.AVG_CONVERSION_RATE,
        f.AVG_LTV_CAC, f.MARKET_GROWTH_RATE, f.SECTOR_ENCODED
      ):output_feature_0::FLOAT AS opportunity_score
    FROM features f
  )
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'company_name', p.COMPANY_NAME,
    'sector', p.SECTOR,
    'market_size_b', ROUND(p.MARKET_SIZE_USD / 1000000000, 2),
    'tam_b', ROUND(p.TAM_USD / 1000000000, 2),
    'market_growth_pct', ROUND(p.MARKET_GROWTH_RATE, 2),
    'competitive_position', p.COMPETITIVE_POSITION,
    'opportunity_score', ROUND(p.opportunity_score, 2),
    'key_opportunities', ARRAY_CONSTRUCT_COMPACT(
      CASE WHEN p.MARKET_GROWTH_RATE > 8 THEN 'High-growth market' END,
      CASE WHEN p.AVG_CONVERSION_RATE > 3 THEN 'Strong digital conversion' END,
      CASE WHEN p.AVG_LTV_CAC > 3.5 THEN 'Efficient customer economics' END,
      CASE WHEN p.COMPETITIVE_POSITION IN ('Market Leader', 'Niche Leader', 'Strong Challenger') THEN 'Strong market position' END
    ),
    'consumer_trend', p.CONSUMER_TREND
  ))
  FROM predictions p
$$;
