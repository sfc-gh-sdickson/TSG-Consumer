/*===========================================================================
  TSG Consumer Partners - Step 9: Create Cortex Agent
  Script: 09_create_tsg_agent.sql

  Prerequisites: Run ALL scripts 01-08 first
  Creates the TSG_AGENT Cortex Agent with all tools configured
===========================================================================*/

USE ROLE ACCOUNTADMIN;
USE DATABASE TSG_INTELLIGENCE;
USE SCHEMA AGENT;
USE WAREHOUSE TSG_WH;

CREATE OR REPLACE AGENT TSG_INTELLIGENCE.AGENT.TSG_AGENT
  COMMENT = 'TSG Consumer Partners Intelligence Agent - Portfolio analytics, brand insights, revenue forecasting, and strategic decision support'
  PROFILE = '{"display_name": "TSG Consumer Intelligence", "avatar": "briefcase", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 360
      tokens: 32000

  instructions:
    response: >
      You are the TSG Consumer Partners Intelligence Assistant. You help investment professionals
      analyze portfolio company performance, brand health, revenue trends, and market opportunities.
      Always provide data-driven insights with specific numbers and actionable recommendations.
      Format financial figures with dollar signs and appropriate units (M for millions, B for billions).
      When presenting comparisons, use tables or structured lists for clarity.
      Cite the data source (which tool) used for each insight.
    orchestration: >
      Route questions as follows:
      - Revenue, financial performance, investment returns, margins: Use portfolio_performance_analyst or revenue_growth_analyst
      - Brand health, NPS, sentiment, social metrics: Use brand_analytics_analyst
      - Website traffic, conversion, eCommerce, ROAS, CAC: Use ecommerce_digital_analyst
      - Supply chain, operations, fulfillment, inventory: Use operational_efficiency_analyst
      - Strategy documents, playbooks, best practices: Use brand_strategy_search
      - Market research, competitive intelligence, trends: Use market_research_search
      - Portfolio company background, deal context: Use portfolio_knowledge_search
      - LTV predictions, brand value scoring: Use get_ltv_scores
      - Churn risk, at-risk companies: Use get_churn_risk
      - Revenue forecasts, growth projections: Use get_forecasts
      - Market opportunities, TAM analysis: Use get_opportunities
      For complex questions, use multiple tools and synthesize the results.
    system: >
      You are a private equity consumer brand intelligence system for TSG Consumer Partners.
      TSG Consumer Partners is a leading private equity firm focused exclusively on the consumer sector.
      The portfolio includes 12 active consumer brands across Food & Beverage, Apparel & Accessories,
      Health & Beauty, Pet Care, Home & Living, Outdoor & Recreation, and Entertainment sectors.
      Always maintain professional tone appropriate for investment committee and board presentations.
      Never disclose sensitive deal terms or projected IRR/MOIC unless specifically asked.
    sample_questions:
      - question: "Which portfolio companies have the strongest revenue growth?"
        answer: "I'll analyze revenue growth across all portfolio companies using the financial data."
      - question: "What are the brand health trends for PureGlow Beauty?"
        answer: "Let me pull up the brand metrics including NPS, sentiment, and social engagement for PureGlow."
      - question: "Which companies are at highest risk of underperformance?"
        answer: "I'll run the churn risk analysis to identify companies with declining metrics."
      - question: "What does our market research say about the functional beverage category?"
        answer: "Let me search our market research documents for functional beverage insights."
      - question: "Compare eCommerce performance across the apparel brands"
        answer: "I'll pull digital analytics for UrbanPulse, CloudStep, and GreenThread."
      - question: "What are the revenue forecasts for next year?"
        answer: "I'll generate revenue growth forecasts based on historical trends and market conditions."

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "portfolio_performance_analyst"
        description: "Answers questions about portfolio company financial performance including revenue, margins, EBITDA, investment returns, deal multiples, and profitability metrics across sectors and time periods"
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "brand_analytics_analyst"
        description: "Answers questions about brand health metrics including brand awareness, sentiment, NPS, social media followers, engagement, share of voice, brand equity, customer satisfaction, market size, and competitive position"
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "revenue_growth_analyst"
        description: "Answers questions about revenue growth trends and channel performance including DTC, wholesale, Amazon, subscription channel revenue, margins, units sold, return rates, and repeat purchase rates"
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ecommerce_digital_analyst"
        description: "Answers questions about eCommerce and digital marketing performance including website traffic, conversion rates, AOV, cart abandonment, email metrics, ROAS, organic traffic, mobile traffic, CAC, and LTV/CAC ratio"
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "operational_efficiency_analyst"
        description: "Answers questions about operational efficiency including inventory turnover, DSO, supply chain scores, fulfillment rates, on-time delivery, COGS, SGA, capex, working capital, and cash conversion"
    - tool_spec:
        type: "cortex_search"
        name: "brand_strategy_search"
        description: "Searches brand strategy documents, value creation plans, marketing playbooks, and portfolio review reports for strategic insights and best practices"
    - tool_spec:
        type: "cortex_search"
        name: "market_research_search"
        description: "Searches market research reports for competitive intelligence, market sizing, consumer trends, and category analysis across portfolio company sectors"
    - tool_spec:
        type: "cortex_search"
        name: "portfolio_knowledge_search"
        description: "Searches portfolio company descriptions and investment deal notes for background context on companies, deal rationale, and strategic positioning"
    - tool_spec:
        type: "generic"
        name: "get_ltv_scores"
        description: "Returns brand lifetime value (LTV) scores for all active portfolio companies. Scores are calculated from revenue trajectory, brand equity, growth rates, NPS, and market conditions. Returns company name, sector, LTV score, tier (Platinum/Gold/Silver/Bronze), and component metrics."
        input_schema:
          type: "object"
          properties: {}
    - tool_spec:
        type: "generic"
        name: "get_churn_risk"
        description: "Returns churn risk scores for all active portfolio companies. Identifies companies at risk of underperformance based on declining NPS, low satisfaction, negative revenue growth, and high DSO. Returns risk level (High/Medium/Low) and key risk factors."
        input_schema:
          type: "object"
          properties: {}
    - tool_spec:
        type: "generic"
        name: "get_forecasts"
        description: "Returns revenue growth forecasts for all active portfolio companies. Forecasts blend historical growth trends, market growth rates, and brand momentum. Returns current revenue, forecast growth, forecast revenue, confidence level, and growth outlook."
        input_schema:
          type: "object"
          properties: {}
    - tool_spec:
        type: "generic"
        name: "get_opportunities"
        description: "Returns market opportunity scores for all active portfolio companies. Evaluates TAM, market growth, competitive position, digital conversion, and customer economics. Returns opportunity score, key opportunities, and consumer trends."
        input_schema:
          type: "object"
          properties: {}

  tool_resources:
    portfolio_performance_analyst:
      semantic_view: "TSG_INTELLIGENCE.ANALYTICS.SV_PORTFOLIO_PERFORMANCE"
    brand_analytics_analyst:
      semantic_view: "TSG_INTELLIGENCE.ANALYTICS.SV_BRAND_ANALYTICS"
    revenue_growth_analyst:
      semantic_view: "TSG_INTELLIGENCE.ANALYTICS.SV_REVENUE_GROWTH"
    ecommerce_digital_analyst:
      semantic_view: "TSG_INTELLIGENCE.ANALYTICS.SV_ECOMMERCE_DIGITAL"
    operational_efficiency_analyst:
      semantic_view: "TSG_INTELLIGENCE.ANALYTICS.SV_OPERATIONAL_EFFICIENCY"
    brand_strategy_search:
      search_service: "TSG_INTELLIGENCE.ANALYTICS.BRAND_STRATEGY_SEARCH"
      max_results: "5"
      title_column: "TITLE"
    market_research_search:
      search_service: "TSG_INTELLIGENCE.ANALYTICS.MARKET_RESEARCH_SEARCH"
      max_results: "5"
      title_column: "CATEGORY"
    portfolio_knowledge_search:
      search_service: "TSG_INTELLIGENCE.ANALYTICS.PORTFOLIO_KNOWLEDGE_SEARCH"
      max_results: "5"
      title_column: "COMPANY_NAME"
    get_ltv_scores:
      type: "function"
      identifier: "TSG_INTELLIGENCE.MODELS.AGENT_GET_LTV_SCORES"
      execution_environment:
        type: "warehouse"
        warehouse: "TSG_WH"
    get_churn_risk:
      type: "function"
      identifier: "TSG_INTELLIGENCE.MODELS.AGENT_GET_CHURN_RISK"
      execution_environment:
        type: "warehouse"
        warehouse: "TSG_WH"
    get_forecasts:
      type: "function"
      identifier: "TSG_INTELLIGENCE.MODELS.AGENT_GET_FORECASTS"
      execution_environment:
        type: "warehouse"
        warehouse: "TSG_WH"
    get_opportunities:
      type: "function"
      identifier: "TSG_INTELLIGENCE.MODELS.AGENT_GET_OPPORTUNITIES"
      execution_environment:
        type: "warehouse"
        warehouse: "TSG_WH"
  $$;
