# TSG Consumer Partners — Deployment Summary

## Project Status: Ready for Deployment

**Date:** March 2026
**Platform:** Snowflake
**Database:** TSG_INTELLIGENCE
**Agent:** TSG_INTELLIGENCE.AGENT.TSG_AGENT

## Component Inventory

### Database Objects

| Component | Object | Schema | Status |
|-----------|--------|--------|--------|
| Database | TSG_INTELLIGENCE | — | Ready |
| Schema | RAW | TSG_INTELLIGENCE | Ready |
| Schema | ANALYTICS | TSG_INTELLIGENCE | Ready |
| Schema | SEARCH | TSG_INTELLIGENCE | Ready |
| Schema | MODELS | TSG_INTELLIGENCE | Ready |
| Schema | AGENT | TSG_INTELLIGENCE | Ready |
| Warehouse | TSG_WH | — | Ready |

### Tables (9 total)

| Table | Schema | Description |
|-------|--------|-------------|
| PORTFOLIO_COMPANIES | ANALYTICS | 12 active portfolio companies |
| BRAND_METRICS | ANALYTICS | Monthly brand health scores |
| REVENUE_DATA | ANALYTICS | Quarterly revenue by channel/region |
| DIGITAL_ANALYTICS | ANALYTICS | eCommerce and digital metrics |
| MARKET_RESEARCH | ANALYTICS | Competitive intelligence |
| CHANNEL_PERFORMANCE | ANALYTICS | Sales channel breakdowns |
| OPERATIONS_METRICS | ANALYTICS | Operational health metrics |
| INVESTMENT_DEALS | ANALYTICS | Deal terms and valuations |
| BRAND_STRATEGY_DOCS | ANALYTICS | Strategy documents |

### Analytical Views (6 total)

| View | Schema |
|------|--------|
| V_PORTFOLIO_PERFORMANCE | ANALYTICS |
| V_BRAND_ANALYTICS | ANALYTICS |
| V_REVENUE_GROWTH | ANALYTICS |
| V_ECOMMERCE_DIGITAL | ANALYTICS |
| V_OPERATIONAL_EFFICIENCY | ANALYTICS |
| V_BRAND_STRATEGY_KNOWLEDGE | ANALYTICS |

### Semantic Views (5 total)

| Semantic View | Schema | Tool Name |
|---------------|--------|-----------|
| SV_PORTFOLIO_PERFORMANCE | ANALYTICS | portfolio_performance_analyst |
| SV_BRAND_ANALYTICS | ANALYTICS | brand_analytics_analyst |
| SV_REVENUE_GROWTH | ANALYTICS | revenue_growth_analyst |
| SV_ECOMMERCE_DIGITAL | ANALYTICS | ecommerce_digital_analyst |
| SV_OPERATIONAL_EFFICIENCY | ANALYTICS | operational_efficiency_analyst |

### Cortex Search Services (3 total)

| Service | Schema | Tool Name |
|---------|--------|-----------|
| BRAND_STRATEGY_SEARCH | ANALYTICS | brand_strategy_search |
| MARKET_RESEARCH_SEARCH | ANALYTICS | market_research_search |
| PORTFOLIO_KNOWLEDGE_SEARCH | ANALYTICS | portfolio_knowledge_search |

### ML UDF Functions (4 total)

| Function | Schema | Tool Name |
|----------|--------|-----------|
| AGENT_GET_LTV_SCORES() | MODELS | get_ltv_scores |
| AGENT_GET_CHURN_RISK() | MODELS | get_churn_risk |
| AGENT_GET_FORECASTS() | MODELS | get_forecasts |
| AGENT_GET_OPPORTUNITIES() | MODELS | get_opportunities |

### Agent

| Property | Value |
|----------|-------|
| Name | TSG_AGENT |
| Location | TSG_INTELLIGENCE.AGENT |
| Orchestration Model | claude-4-sonnet |
| Time Budget | 60 seconds |
| Token Budget | 32,000 |
| Total Tools | 12 |

## Portfolio Companies

| # | Company | Sector | Sub-Sector | Investment |
|---|---------|--------|------------|------------|
| 1 | ATI Restoration | Home Services | Restoration Services | $175M |
| 2 | Crumbl Cookies | Food & Beverage | Specialty Bakery | $200M |
| 3 | Thrive Pet Healthcare | Pet Care | Veterinary Services | $300M |
| 4 | Saltair | Health & Beauty | Personal Care | $50M |
| 5 | Wrench Group | Home Services | HVAC & Plumbing | $250M |
| 6 | DUDE Wipes | Consumer Products | Personal Hygiene | $100M |
| 7 | Legacy.com | Digital Media | Online Memorials | $125M |
| 8 | Mavis Tire | Automotive Services | Tire & Auto Service | $450M |
| 9 | Power Stop | Automotive Parts | Performance Brakes | $130M |
| 10 | Radiance Holdings | Health & Beauty | Med Spa & Aesthetics | $180M |
| 11 | Revolut Ltd | Fintech | Digital Banking | $150M |
| 12 | Super Star Car Wash | Automotive Services | Car Wash | $200M |

**Total Portfolio Investment: $2.31B across 12 companies in 8 sectors**

## Deployment Script Execution Order

```
1. sql/setup/01_database_and_schema.sql
2. sql/setup/02_create_tables.sql
3. sql/data/03_generate_synthetic_data.sql
4. sql/views/04_create_views.sql
5. sql/views/05_create_semantic_views.sql
6. sql/search/06_create_cortex_search.sql
7. notebooks/07_ml_models.ipynb (optional)
8. sql/models/08_ml_model_functions.sql
9. sql/agent/09_create_financial_agent.sql
```
