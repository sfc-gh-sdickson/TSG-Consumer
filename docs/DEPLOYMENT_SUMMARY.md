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
| 1 | BrightLeaf Organics | Food & Beverage | Organic Foods | $85M |
| 2 | UrbanPulse Athletics | Apparel & Accessories | Athleisure | $120M |
| 3 | PureGlow Beauty | Health & Beauty | Clean Beauty | $65M |
| 4 | TailWag Pet Co | Pet Care | Premium Pet Food | $95M |
| 5 | FrostBite Beverages | Food & Beverage | Functional Beverages | $110M |
| 6 | NestCraft Home | Home & Living | Home Decor | $75M |
| 7 | VitalKids Nutrition | Food & Beverage | Kids Nutrition | $55M |
| 8 | CloudStep Footwear | Apparel & Accessories | Footwear | $140M |
| 9 | GreenThread Basics | Apparel & Accessories | Sustainable Fashion | $45M |
| 10 | SunRise Supplements | Health & Beauty | Dietary Supplements | $90M |
| 11 | WildTrail Outdoors | Outdoor & Recreation | Outdoor Gear | $105M |
| 12 | PixelPlay Interactive | Entertainment | Kids Entertainment | $60M |

**Total Portfolio Investment: $1.045B across 12 companies in 7 sectors**

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
