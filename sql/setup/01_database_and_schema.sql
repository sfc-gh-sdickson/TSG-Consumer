/*===========================================================================
  TSG Consumer Partners — Step 1: Database, Schemas & Warehouse Setup
  Script: 01_database_and_schema.sql
  
  Prerequisites: ACCOUNTADMIN role or equivalent privileges
  Target Database: TSG_INTELLIGENCE
===========================================================================*/

USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS TSG_INTELLIGENCE
    COMMENT = 'TSG Consumer Partners Intelligence Platform — Portfolio analytics, brand metrics, and AI-driven insights';

USE DATABASE TSG_INTELLIGENCE;

CREATE SCHEMA IF NOT EXISTS RAW
    COMMENT = 'Raw ingested data from portfolio companies, market research, and financial systems';

CREATE SCHEMA IF NOT EXISTS ANALYTICS
    COMMENT = 'Curated analytical views, semantic models, and ML-ready datasets';

CREATE SCHEMA IF NOT EXISTS SEARCH
    COMMENT = 'Cortex Search services and document knowledge bases';

CREATE SCHEMA IF NOT EXISTS MODELS
    COMMENT = 'ML model artifacts, UDF functions, and prediction outputs';

CREATE SCHEMA IF NOT EXISTS AGENT
    COMMENT = 'Cortex Agent configuration, tools, and orchestration objects';

CREATE WAREHOUSE IF NOT EXISTS TSG_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Primary compute warehouse for TSG Intelligence platform';

USE WAREHOUSE TSG_WH;
USE SCHEMA TSG_INTELLIGENCE.ANALYTICS;
