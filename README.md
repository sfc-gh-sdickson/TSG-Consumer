# TSG Consumer Partners — Snowflake Intelligence Platform

A complete Snowflake-native intelligence platform for TSG Consumer Partners, a private equity firm focused on consumer brands. Powered by Cortex Agent, Cortex Analyst, Cortex Search, and ML-driven UDF functions.

![Architecture](docs/images/architecture.svg)

## Overview

This project deploys **TSG_AGENT**, a Cortex Agent that provides:

- **Portfolio Analytics** — Revenue, margins, deal metrics across 12 consumer brands
- **Brand Intelligence** — NPS, sentiment, awareness, social engagement tracking
- **Revenue Forecasting** — Channel performance, growth trends, predictive forecasts
- **Market Research** — Competitive intelligence, consumer trends, TAM analysis
- **Operational Insights** — Supply chain health, fulfillment, cost structure
- **ML Predictions** — LTV scoring, churn risk, market opportunity assessment

## Portfolio

12 active consumer brands totaling $1.045B invested across 7 sectors:

| Company | Sector | Investment |
|---------|--------|------------|
| BrightLeaf Organics | Food & Beverage | $85M |
| UrbanPulse Athletics | Apparel & Accessories | $120M |
| PureGlow Beauty | Health & Beauty | $65M |
| TailWag Pet Co | Pet Care | $95M |
| FrostBite Beverages | Food & Beverage | $110M |
| NestCraft Home | Home & Living | $75M |
| VitalKids Nutrition | Food & Beverage | $55M |
| CloudStep Footwear | Apparel & Accessories | $140M |
| GreenThread Basics | Apparel & Accessories | $45M |
| SunRise Supplements | Health & Beauty | $90M |
| WildTrail Outdoors | Outdoor & Recreation | $105M |
| PixelPlay Interactive | Entertainment | $60M |

## Quick Start

Execute scripts in order:

```
1. sql/setup/01_database_and_schema.sql     — Database, schemas, warehouse
2. sql/setup/02_create_tables.sql           — 9 table definitions
3. sql/data/03_generate_synthetic_data.sql  — Synthetic portfolio data
4. sql/views/04_create_views.sql            — 6 analytical views
5. sql/views/05_create_semantic_views.sql   — 5 semantic views
6. sql/search/06_create_cortex_search.sql   — 3 Cortex Search services
7. notebooks/07_ml_models.ipynb             — ML model training (optional)
8. sql/models/08_ml_model_functions.sql     — 4 agent UDF functions
9. sql/agent/09_create_financial_agent.sql  — Agent creation
```

## Agent Tools (12 total)

| Type | Count | Tools |
|------|-------|-------|
| Cortex Analyst | 5 | Portfolio Performance, Brand Analytics, Revenue Growth, eCommerce Digital, Operational Efficiency |
| Cortex Search | 3 | Brand Strategy, Market Research, Portfolio Knowledge |
| Generic (UDF) | 4 | LTV Scores, Churn Risk, Revenue Forecasts, Market Opportunities |

## Project Structure

```
├── README.md
├── docs/
│   ├── AGENT_SETUP.md              — Step-by-step deployment guide
│   ├── DEPLOYMENT_SUMMARY.md       — Component inventory and status
│   ├── questions.md                — 40 test questions for the agent
│   └── images/
│       ├── architecture.svg        — System architecture diagram
│       ├── deployment_flow.svg     — Deployment workflow diagram
│       └── ml_models.svg           — ML pipeline diagram
├── sql/
│   ├── setup/
│   │   ├── 01_database_and_schema.sql
│   │   └── 02_create_tables.sql
│   ├── data/
│   │   └── 03_generate_synthetic_data.sql
│   ├── views/
│   │   ├── 04_create_views.sql
│   │   └── 05_create_semantic_views.sql
│   ├── search/
│   │   └── 06_create_cortex_search.sql
│   ├── models/
│   │   └── 08_ml_model_functions.sql
│   └── agent/
│       └── 09_create_financial_agent.sql
└── notebooks/
    └── 07_ml_models.ipynb
```

## Documentation

- [Agent Setup Guide](docs/AGENT_SETUP.md) — Complete deployment instructions
- [Deployment Summary](docs/DEPLOYMENT_SUMMARY.md) — Component inventory
- [Test Questions](docs/questions.md) — 40 questions to test the agent
