/*===========================================================================
  TSG Consumer Partners - Step 5: Semantic Views for Cortex Analyst
  Script: 05_create_semantic_views.sql

  Prerequisites: Run scripts 01-04 first
  Creates semantic views for Cortex Analyst text-to-SQL capabilities
===========================================================================*/

USE ROLE ACCOUNTADMIN;
USE DATABASE TSG_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE TSG_WH;

CREATE OR REPLACE SEMANTIC VIEW SV_PORTFOLIO_PERFORMANCE

  TABLES (
    portfolio AS TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES
      PRIMARY KEY (COMPANY_ID)
      WITH SYNONYMS ('companies', 'portfolio companies', 'brands')
      COMMENT = 'Portfolio company master data including investment details',
    revenue AS TSG_INTELLIGENCE.ANALYTICS.REVENUE_DATA
      PRIMARY KEY (REVENUE_ID)
      WITH SYNONYMS ('financials', 'revenue', 'sales data')
      COMMENT = 'Quarterly revenue and profitability data by channel and region',
    deals AS TSG_INTELLIGENCE.ANALYTICS.INVESTMENT_DEALS
      PRIMARY KEY (DEAL_ID)
      WITH SYNONYMS ('investments', 'deal data', 'valuations')
      COMMENT = 'Investment deal terms, valuations, and projected returns'
  )

  RELATIONSHIPS (
    revenue_to_portfolio AS
      revenue (COMPANY_ID) REFERENCES portfolio (COMPANY_ID),
    deals_to_portfolio AS
      deals (COMPANY_ID) REFERENCES portfolio (COMPANY_ID)
  )

  FACTS (
    portfolio.investment_amount_fact AS INVESTMENT_AMOUNT
      COMMENT = 'Total investment amount in USD',
    portfolio.ownership_fact AS OWNERSHIP_STAKE
      COMMENT = 'Ownership percentage',
    portfolio.employee_count_fact AS EMPLOYEE_COUNT
      COMMENT = 'Number of employees'
  )

  DIMENSIONS (
    portfolio.company_name AS COMPANY_NAME
      WITH SYNONYMS = ('brand', 'company', 'brand name')
      COMMENT = 'Name of the portfolio company',
    portfolio.sector AS SECTOR
      WITH SYNONYMS = ('industry', 'category', 'vertical')
      COMMENT = 'Industry sector',
    portfolio.sub_sector AS SUB_SECTOR
      WITH SYNONYMS = ('sub-industry', 'sub-category')
      COMMENT = 'Industry sub-sector',
    portfolio.status AS STATUS
      COMMENT = 'Investment status (Active, Exited, etc.)',
    portfolio.investment_date AS INVESTMENT_DATE
      COMMENT = 'Date of initial investment',
    portfolio.headquarters AS HEADQUARTERS
      WITH SYNONYMS = ('location', 'HQ', 'city')
      COMMENT = 'Company headquarters location',
    revenue.fiscal_year AS FISCAL_YEAR
      WITH SYNONYMS = ('year', 'FY')
      COMMENT = 'Fiscal year',
    revenue.fiscal_quarter AS FISCAL_QUARTER
      WITH SYNONYMS = ('quarter', 'Q')
      COMMENT = 'Fiscal quarter (Q1-Q4)',
    revenue.channel AS CHANNEL
      WITH SYNONYMS = ('sales channel', 'distribution channel')
      COMMENT = 'Revenue channel (DTC, Wholesale, Amazon)',
    revenue.region AS REGION
      WITH SYNONYMS = ('geography', 'market')
      COMMENT = 'Geographic region',
    deals.deal_type AS DEAL_TYPE
      COMMENT = 'Type of investment deal',
    deals.exit_strategy AS EXIT_STRATEGY
      COMMENT = 'Planned exit strategy'
  )

  METRICS (
    revenue.total_revenue AS SUM(REVENUE)
      WITH SYNONYMS = ('sales', 'top line', 'revenue')
      COMMENT = 'Total revenue in USD',
    revenue.total_gross_profit AS SUM(GROSS_PROFIT)
      COMMENT = 'Total gross profit in USD',
    revenue.total_ebitda AS SUM(EBITDA)
      COMMENT = 'Total EBITDA in USD',
    revenue.total_net_income AS SUM(NET_INCOME)
      COMMENT = 'Total net income in USD',
    revenue.avg_gross_margin AS AVG(GROSS_MARGIN)
      WITH SYNONYMS = ('margin', 'gross margin')
      COMMENT = 'Average gross margin percentage',
    revenue.avg_ebitda_margin AS AVG(EBITDA_MARGIN)
      COMMENT = 'Average EBITDA margin percentage',
    revenue.avg_revenue_growth AS AVG(REVENUE_GROWTH_YOY)
      WITH SYNONYMS = ('growth rate', 'YoY growth')
      COMMENT = 'Average year-over-year revenue growth',
    portfolio.total_invested AS SUM(INVESTMENT_AMOUNT)
      COMMENT = 'Total capital invested across portfolio',
    portfolio.company_count AS COUNT(COMPANY_ID)
      COMMENT = 'Number of portfolio companies',
    deals.avg_ev_revenue_multiple AS AVG(EV_REVENUE_MULTIPLE)
      WITH SYNONYMS = ('revenue multiple', 'EV/Revenue')
      COMMENT = 'Average EV/Revenue multiple',
    deals.avg_ev_ebitda_multiple AS AVG(EV_EBITDA_MULTIPLE)
      WITH SYNONYMS = ('EBITDA multiple', 'EV/EBITDA')
      COMMENT = 'Average EV/EBITDA multiple',
    deals.avg_irr AS AVG(IRR_PROJECTED)
      WITH SYNONYMS = ('IRR', 'internal rate of return')
      COMMENT = 'Average projected IRR',
    deals.avg_moic AS AVG(MOIC_PROJECTED)
      WITH SYNONYMS = ('MOIC', 'multiple on invested capital')
      COMMENT = 'Average projected MOIC'
  )

  COMMENT = 'Portfolio performance analysis - revenue, profitability, investment returns';

CREATE OR REPLACE SEMANTIC VIEW SV_BRAND_ANALYTICS

  TABLES (
    portfolio AS TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES
      PRIMARY KEY (COMPANY_ID)
      COMMENT = 'Portfolio company master data',
    brand AS TSG_INTELLIGENCE.ANALYTICS.BRAND_METRICS
      PRIMARY KEY (METRIC_ID)
      WITH SYNONYMS ('brand health', 'brand data', 'brand performance')
      COMMENT = 'Monthly brand health and sentiment metrics',
    market AS TSG_INTELLIGENCE.ANALYTICS.MARKET_RESEARCH
      PRIMARY KEY (RESEARCH_ID)
      WITH SYNONYMS ('market data', 'market intelligence', 'competitive data')
      COMMENT = 'Market research and competitive intelligence'
  )

  RELATIONSHIPS (
    brand_to_portfolio AS
      brand (COMPANY_ID) REFERENCES portfolio (COMPANY_ID),
    market_to_portfolio AS
      market (COMPANY_ID) REFERENCES portfolio (COMPANY_ID)
  )

  DIMENSIONS (
    portfolio.company_name AS COMPANY_NAME
      WITH SYNONYMS = ('brand', 'company')
      COMMENT = 'Name of the portfolio company',
    portfolio.sector AS SECTOR
      COMMENT = 'Industry sector',
    portfolio.sub_sector AS SUB_SECTOR
      COMMENT = 'Industry sub-sector',
    brand.metric_date AS METRIC_DATE
      WITH SYNONYMS = ('date', 'month')
      COMMENT = 'Date of brand metric measurement',
    market.category AS CATEGORY
      COMMENT = 'Market research category',
    market.competitive_position AS COMPETITIVE_POSITION
      WITH SYNONYMS = ('market position', 'competitive standing')
      COMMENT = 'Competitive market position',
    market.consumer_trend AS CONSUMER_TREND
      WITH SYNONYMS = ('trend', 'consumer behavior')
      COMMENT = 'Key consumer trend identified'
  )

  METRICS (
    brand.avg_brand_awareness AS AVG(BRAND_AWARENESS)
      WITH SYNONYMS = ('awareness', 'brand awareness score')
      COMMENT = 'Average brand awareness percentage',
    brand.avg_brand_sentiment AS AVG(BRAND_SENTIMENT)
      WITH SYNONYMS = ('sentiment', 'brand sentiment score')
      COMMENT = 'Average brand sentiment score',
    brand.avg_nps AS AVG(NET_PROMOTER_SCORE)
      WITH SYNONYMS = ('NPS', 'net promoter score', 'promoter score')
      COMMENT = 'Average Net Promoter Score',
    brand.total_social_followers AS SUM(SOCIAL_FOLLOWERS)
      WITH SYNONYMS = ('followers', 'social audience')
      COMMENT = 'Total social media followers',
    brand.avg_social_engagement AS AVG(SOCIAL_ENGAGEMENT)
      WITH SYNONYMS = ('engagement', 'social engagement rate')
      COMMENT = 'Average social media engagement rate',
    brand.avg_share_of_voice AS AVG(SHARE_OF_VOICE)
      WITH SYNONYMS = ('SOV', 'share of voice')
      COMMENT = 'Average share of voice percentage',
    brand.avg_brand_equity AS AVG(BRAND_EQUITY_INDEX)
      WITH SYNONYMS = ('brand equity', 'equity index')
      COMMENT = 'Average brand equity index',
    brand.avg_csat AS AVG(CUSTOMER_SAT_SCORE)
      WITH SYNONYMS = ('CSAT', 'customer satisfaction', 'satisfaction score')
      COMMENT = 'Average customer satisfaction score',
    market.avg_market_size AS AVG(MARKET_SIZE_USD)
      COMMENT = 'Average market size in USD',
    market.avg_market_growth AS AVG(MARKET_GROWTH_RATE)
      WITH SYNONYMS = ('market growth', 'category growth')
      COMMENT = 'Average market growth rate'
  )

  COMMENT = 'Brand analytics - health scores, sentiment, market position, and consumer trends';

CREATE OR REPLACE SEMANTIC VIEW SV_REVENUE_GROWTH

  TABLES (
    portfolio AS TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES
      PRIMARY KEY (COMPANY_ID)
      COMMENT = 'Portfolio company master data',
    revenue AS TSG_INTELLIGENCE.ANALYTICS.REVENUE_DATA
      PRIMARY KEY (REVENUE_ID)
      COMMENT = 'Revenue and profitability data',
    channels AS TSG_INTELLIGENCE.ANALYTICS.CHANNEL_PERFORMANCE
      PRIMARY KEY (CHANNEL_ID)
      WITH SYNONYMS ('channel data', 'distribution', 'sales channels')
      COMMENT = 'Channel-level performance metrics'
  )

  RELATIONSHIPS (
    revenue_to_portfolio AS
      revenue (COMPANY_ID) REFERENCES portfolio (COMPANY_ID),
    channels_to_portfolio AS
      channels (COMPANY_ID) REFERENCES portfolio (COMPANY_ID)
  )

  DIMENSIONS (
    portfolio.company_name AS COMPANY_NAME
      WITH SYNONYMS = ('brand', 'company')
      COMMENT = 'Name of the portfolio company',
    portfolio.sector AS SECTOR
      COMMENT = 'Industry sector',
    revenue.fiscal_year AS FISCAL_YEAR
      WITH SYNONYMS = ('year', 'FY')
      COMMENT = 'Fiscal year',
    revenue.fiscal_quarter AS FISCAL_QUARTER
      WITH SYNONYMS = ('quarter')
      COMMENT = 'Fiscal quarter',
    revenue.channel AS CHANNEL
      COMMENT = 'Revenue channel',
    revenue.region AS REGION
      COMMENT = 'Geographic region',
    channels.channel_type AS CHANNEL_TYPE
      WITH SYNONYMS = ('sales channel', 'distribution type')
      COMMENT = 'Type of sales channel'
  )

  METRICS (
    revenue.total_revenue AS SUM(REVENUE)
      COMMENT = 'Total revenue',
    revenue.total_gross_profit AS SUM(GROSS_PROFIT)
      COMMENT = 'Total gross profit',
    revenue.total_ebitda AS SUM(EBITDA)
      COMMENT = 'Total EBITDA',
    revenue.avg_growth AS AVG(REVENUE_GROWTH_YOY)
      WITH SYNONYMS = ('growth', 'revenue growth')
      COMMENT = 'Average YoY revenue growth',
    channels.total_channel_revenue AS SUM(CHANNEL_REVENUE)
      WITH SYNONYMS = ('channel sales', 'channel revenue')
      COMMENT = 'Total channel revenue',
    channels.avg_channel_margin AS AVG(CHANNEL_MARGIN)
      COMMENT = 'Average channel margin',
    channels.total_units AS SUM(UNITS_SOLD)
      WITH SYNONYMS = ('units', 'volume')
      COMMENT = 'Total units sold',
    channels.avg_return_rate AS AVG(RETURN_RATE)
      WITH SYNONYMS = ('returns', 'return rate')
      COMMENT = 'Average product return rate',
    channels.total_customers AS SUM(CUSTOMER_COUNT)
      WITH SYNONYMS = ('customers', 'customer base')
      COMMENT = 'Total customer count',
    channels.avg_repeat_rate AS AVG(REPEAT_PURCHASE_RATE)
      WITH SYNONYMS = ('repeat rate', 'retention', 'repeat purchase')
      COMMENT = 'Average repeat purchase rate'
  )

  COMMENT = 'Revenue growth and channel performance analysis';

CREATE OR REPLACE SEMANTIC VIEW SV_ECOMMERCE_DIGITAL

  TABLES (
    portfolio AS TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES
      PRIMARY KEY (COMPANY_ID)
      COMMENT = 'Portfolio company master data',
    digital AS TSG_INTELLIGENCE.ANALYTICS.DIGITAL_ANALYTICS
      PRIMARY KEY (ANALYTICS_ID)
      WITH SYNONYMS ('digital data', 'web analytics', 'ecommerce metrics')
      COMMENT = 'Digital and eCommerce performance metrics'
  )

  RELATIONSHIPS (
    digital_to_portfolio AS
      digital (COMPANY_ID) REFERENCES portfolio (COMPANY_ID)
  )

  DIMENSIONS (
    portfolio.company_name AS COMPANY_NAME
      WITH SYNONYMS = ('brand', 'company')
      COMMENT = 'Name of the portfolio company',
    portfolio.sector AS SECTOR
      COMMENT = 'Industry sector',
    digital.metric_date AS METRIC_DATE
      WITH SYNONYMS = ('date', 'month')
      COMMENT = 'Date of digital metric measurement',
    digital.channel_name AS CHANNEL_NAME
      WITH SYNONYMS = ('marketing channel', 'acquisition channel', 'digital channel')
      COMMENT = 'Digital marketing channel name'
  )

  METRICS (
    digital.total_traffic AS SUM(WEBSITE_TRAFFIC)
      WITH SYNONYMS = ('traffic', 'website visits', 'page views')
      COMMENT = 'Total website traffic',
    digital.total_visitors AS SUM(UNIQUE_VISITORS)
      WITH SYNONYMS = ('visitors', 'unique visitors')
      COMMENT = 'Total unique visitors',
    digital.avg_bounce_rate AS AVG(BOUNCE_RATE)
      WITH SYNONYMS = ('bounce rate')
      COMMENT = 'Average bounce rate',
    digital.avg_conversion_rate AS AVG(CONVERSION_RATE)
      WITH SYNONYMS = ('conversion', 'CVR')
      COMMENT = 'Average conversion rate',
    digital.avg_aov AS AVG(AVG_ORDER_VALUE)
      WITH SYNONYMS = ('AOV', 'average order value', 'basket size')
      COMMENT = 'Average order value',
    digital.avg_cart_abandon AS AVG(CART_ABANDON_RATE)
      WITH SYNONYMS = ('cart abandonment', 'abandon rate')
      COMMENT = 'Average cart abandonment rate',
    digital.avg_email_open AS AVG(EMAIL_OPEN_RATE)
      WITH SYNONYMS = ('email open rate', 'open rate')
      COMMENT = 'Average email open rate',
    digital.avg_roas AS AVG(PAID_ROAS)
      WITH SYNONYMS = ('ROAS', 'return on ad spend')
      COMMENT = 'Average paid ROAS',
    digital.avg_organic_pct AS AVG(ORGANIC_TRAFFIC_PCT)
      WITH SYNONYMS = ('organic traffic', 'organic share')
      COMMENT = 'Average organic traffic percentage',
    digital.avg_mobile_pct AS AVG(MOBILE_TRAFFIC_PCT)
      WITH SYNONYMS = ('mobile traffic', 'mobile share')
      COMMENT = 'Average mobile traffic percentage',
    digital.avg_cac AS AVG(CUSTOMER_ACQ_COST)
      WITH SYNONYMS = ('CAC', 'customer acquisition cost')
      COMMENT = 'Average customer acquisition cost',
    digital.avg_ltv_cac AS AVG(LTV_CAC_RATIO)
      WITH SYNONYMS = ('LTV/CAC', 'lifetime value ratio')
      COMMENT = 'Average LTV to CAC ratio'
  )

  COMMENT = 'eCommerce and digital marketing performance analytics';

CREATE OR REPLACE SEMANTIC VIEW SV_OPERATIONAL_EFFICIENCY

  TABLES (
    portfolio AS TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_COMPANIES
      PRIMARY KEY (COMPANY_ID)
      COMMENT = 'Portfolio company master data',
    ops AS TSG_INTELLIGENCE.ANALYTICS.OPERATIONS_METRICS
      PRIMARY KEY (OPS_ID)
      WITH SYNONYMS ('operations', 'operational data', 'supply chain')
      COMMENT = 'Operational efficiency and supply chain metrics'
  )

  RELATIONSHIPS (
    ops_to_portfolio AS
      ops (COMPANY_ID) REFERENCES portfolio (COMPANY_ID)
  )

  DIMENSIONS (
    portfolio.company_name AS COMPANY_NAME
      WITH SYNONYMS = ('brand', 'company')
      COMMENT = 'Name of the portfolio company',
    portfolio.sector AS SECTOR
      COMMENT = 'Industry sector',
    portfolio.sub_sector AS SUB_SECTOR
      COMMENT = 'Industry sub-sector',
    ops.metric_date AS METRIC_DATE
      WITH SYNONYMS = ('date', 'quarter')
      COMMENT = 'Date of operational metric measurement'
  )

  METRICS (
    ops.avg_inventory_turnover AS AVG(INVENTORY_TURNOVER)
      WITH SYNONYMS = ('inventory turns', 'turnover')
      COMMENT = 'Average inventory turnover ratio',
    ops.avg_dso AS AVG(DAYS_SALES_OUTSTANDING)
      WITH SYNONYMS = ('DSO', 'days sales outstanding')
      COMMENT = 'Average days sales outstanding',
    ops.avg_supply_chain_score AS AVG(SUPPLY_CHAIN_SCORE)
      WITH SYNONYMS = ('supply chain health', 'SC score')
      COMMENT = 'Average supply chain health score',
    ops.avg_fulfillment AS AVG(FULFILLMENT_RATE)
      WITH SYNONYMS = ('fulfillment', 'fill rate')
      COMMENT = 'Average fulfillment rate',
    ops.avg_otd AS AVG(ON_TIME_DELIVERY)
      WITH SYNONYMS = ('OTD', 'on-time delivery')
      COMMENT = 'Average on-time delivery rate',
    ops.avg_cogs_pct AS AVG(COGS_PCT_REVENUE)
      WITH SYNONYMS = ('COGS', 'cost of goods')
      COMMENT = 'Average COGS as percentage of revenue',
    ops.avg_sga_pct AS AVG(SGA_PCT_REVENUE)
      WITH SYNONYMS = ('SGA', 'selling general administrative')
      COMMENT = 'Average SGA as percentage of revenue',
    ops.total_capex AS SUM(CAPEX)
      WITH SYNONYMS = ('capital expenditure', 'capex')
      COMMENT = 'Total capital expenditure',
    ops.total_working_capital AS SUM(WORKING_CAPITAL)
      COMMENT = 'Total working capital',
    ops.avg_cash_conversion AS AVG(CASH_CONVERSION)
      WITH SYNONYMS = ('cash conversion cycle', 'CCC')
      COMMENT = 'Average cash conversion efficiency'
  )

  COMMENT = 'Operational efficiency and supply chain performance analytics';
