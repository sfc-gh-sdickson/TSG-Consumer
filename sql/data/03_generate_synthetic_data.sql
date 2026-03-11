/*===========================================================================
  TSG Consumer Partners — Step 3: Synthetic Data Generation
  Script: 03_generate_synthetic_data.sql
  
  Prerequisites: Run 01 and 02 scripts first
  Generates realistic test data for all tables
===========================================================================*/

USE ROLE ACCOUNTADMIN;
USE DATABASE TSG_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE TSG_WH;

INSERT INTO PORTFOLIO_COMPANIES (COMPANY_NAME, SECTOR, SUB_SECTOR, INVESTMENT_DATE, INVESTMENT_AMOUNT, OWNERSHIP_STAKE, STATUS, HEADQUARTERS, EMPLOYEE_COUNT, FOUNDED_YEAR, DESCRIPTION)
VALUES
    ('BrightLeaf Organics', 'Food & Beverage', 'Organic Foods', '2019-03-15', 85000000, 62.5, 'Active', 'Austin, TX', 1200, 2012, 'Premium organic snack and meal brand targeting health-conscious millennials with clean-label products distributed across 15,000+ retail locations.'),
    ('UrbanPulse Athletics', 'Apparel & Accessories', 'Athleisure', '2020-07-22', 120000000, 55.0, 'Active', 'Los Angeles, CA', 850, 2015, 'DTC-first athleisure brand known for sustainable materials and inclusive sizing, expanding into wholesale partnerships with major retailers.'),
    ('PureGlow Beauty', 'Health & Beauty', 'Clean Beauty', '2021-01-10', 65000000, 70.0, 'Active', 'New York, NY', 450, 2017, 'Clean beauty brand with patented formulations, strong social media presence, and rapid DTC growth with 40% repeat purchase rate.'),
    ('TailWag Pet Co', 'Pet Care', 'Premium Pet Food', '2018-11-05', 95000000, 58.0, 'Active', 'Denver, CO', 680, 2014, 'Premium pet nutrition brand with subscription model, veterinary partnerships, and expansion into pet wellness supplements.'),
    ('FrostBite Beverages', 'Food & Beverage', 'Functional Beverages', '2022-04-18', 110000000, 51.0, 'Active', 'Miami, FL', 520, 2018, 'Functional beverage brand specializing in enhanced hydration and energy drinks with zero sugar, targeting Gen Z consumers.'),
    ('NestCraft Home', 'Home & Living', 'Home Decor', '2020-09-30', 75000000, 65.0, 'Active', 'Portland, OR', 380, 2016, 'Artisan-inspired home decor and furnishing brand with strong eCommerce presence and growing retail partnerships.'),
    ('VitalKids Nutrition', 'Food & Beverage', 'Kids Nutrition', '2021-06-14', 55000000, 72.0, 'Active', 'Chicago, IL', 290, 2019, 'Organic kids nutrition brand offering snacks, supplements, and meal kits designed with pediatric nutritionists.'),
    ('CloudStep Footwear', 'Apparel & Accessories', 'Footwear', '2019-12-01', 140000000, 48.0, 'Active', 'Nashville, TN', 1100, 2013, 'Comfort-first footwear brand with patented cushioning technology, strong retail presence, and growing international expansion.'),
    ('GreenThread Basics', 'Apparel & Accessories', 'Sustainable Fashion', '2022-08-20', 45000000, 75.0, 'Active', 'San Francisco, CA', 210, 2020, 'Sustainable basics brand using recycled materials and transparent supply chain, with strong Gen Z and millennial appeal.'),
    ('SunRise Supplements', 'Health & Beauty', 'Dietary Supplements', '2020-02-28', 90000000, 60.0, 'Active', 'Scottsdale, AZ', 560, 2015, 'Science-backed dietary supplement brand with subscription model, clinical studies, and pharmacy distribution network.'),
    ('WildTrail Outdoors', 'Outdoor & Recreation', 'Outdoor Gear', '2018-05-10', 105000000, 52.0, 'Active', 'Boulder, CO', 920, 2011, 'Premium outdoor gear and apparel brand known for durability and sustainability, with loyal community of outdoor enthusiasts.'),
    ('PixelPlay Interactive', 'Entertainment', 'Kids Entertainment', '2023-01-15', 60000000, 68.0, 'Active', 'Seattle, WA', 340, 2019, 'Digital entertainment and educational toy brand with AR/VR integration, subscription boxes, and strong licensing partnerships.');

INSERT INTO BRAND_METRICS (COMPANY_ID, METRIC_DATE, BRAND_AWARENESS, BRAND_SENTIMENT, NET_PROMOTER_SCORE, SOCIAL_FOLLOWERS, SOCIAL_ENGAGEMENT, SHARE_OF_VOICE, BRAND_EQUITY_INDEX, CUSTOMER_SAT_SCORE)
SELECT
    c.COMPANY_ID,
    DATEADD('month', seq.seq, '2023-01-01')::DATE AS METRIC_DATE,
    ROUND(40 + (c.COMPANY_ID * 3.7 + seq.seq * 0.8) + UNIFORM(-5, 5, RANDOM()), 2) AS BRAND_AWARENESS,
    ROUND(55 + (c.COMPANY_ID * 2.1 + seq.seq * 0.5) + UNIFORM(-8, 8, RANDOM()), 2) AS BRAND_SENTIMENT,
    ROUND(20 + (c.COMPANY_ID * 2.5 + seq.seq * 0.6) + UNIFORM(-10, 10, RANDOM()), 1) AS NET_PROMOTER_SCORE,
    ROUND(50000 + (c.COMPANY_ID * 15000) + (seq.seq * 3000) + UNIFORM(-5000, 10000, RANDOM())) AS SOCIAL_FOLLOWERS,
    ROUND(2.5 + (c.COMPANY_ID * 0.3 + seq.seq * 0.1) + UNIFORM(-1.0, 1.5, RANDOM()), 2) AS SOCIAL_ENGAGEMENT,
    ROUND(5 + (c.COMPANY_ID * 1.2 + seq.seq * 0.3) + UNIFORM(-3, 3, RANDOM()), 2) AS SHARE_OF_VOICE,
    ROUND(500 + (c.COMPANY_ID * 50 + seq.seq * 15) + UNIFORM(-50, 80, RANDOM()), 2) AS BRAND_EQUITY_INDEX,
    ROUND(65 + (c.COMPANY_ID * 1.5 + seq.seq * 0.4) + UNIFORM(-5, 5, RANDOM()), 2) AS CUSTOMER_SAT_SCORE
FROM PORTFOLIO_COMPANIES c
CROSS JOIN (SELECT ROW_NUMBER() OVER (ORDER BY seq4()) - 1 AS seq FROM TABLE(GENERATOR(ROWCOUNT => 30))) seq
WHERE DATEADD('month', seq.seq, '2023-01-01')::DATE <= '2025-12-31';

INSERT INTO REVENUE_DATA (COMPANY_ID, FISCAL_YEAR, FISCAL_QUARTER, REVENUE, GROSS_PROFIT, EBITDA, NET_INCOME, GROSS_MARGIN, EBITDA_MARGIN, REVENUE_GROWTH_YOY, CHANNEL, REGION)
SELECT
    c.COMPANY_ID,
    yr.yr AS FISCAL_YEAR,
    qtr.qtr AS FISCAL_QUARTER,
    ROUND((c.INVESTMENT_AMOUNT * 0.15 / 4) * (1 + (yr.yr - 2022) * 0.12 + UNIFORM(-0.05, 0.10, RANDOM())), 2) AS REVENUE,
    ROUND((c.INVESTMENT_AMOUNT * 0.15 / 4) * (1 + (yr.yr - 2022) * 0.12) * (0.45 + UNIFORM(-0.05, 0.10, RANDOM())), 2) AS GROSS_PROFIT,
    ROUND((c.INVESTMENT_AMOUNT * 0.15 / 4) * (1 + (yr.yr - 2022) * 0.12) * (0.18 + UNIFORM(-0.03, 0.05, RANDOM())), 2) AS EBITDA,
    ROUND((c.INVESTMENT_AMOUNT * 0.15 / 4) * (1 + (yr.yr - 2022) * 0.12) * (0.08 + UNIFORM(-0.02, 0.04, RANDOM())), 2) AS NET_INCOME,
    ROUND(45 + UNIFORM(-5, 10, RANDOM()), 2) AS GROSS_MARGIN,
    ROUND(18 + UNIFORM(-3, 5, RANDOM()), 2) AS EBITDA_MARGIN,
    ROUND(8 + UNIFORM(-5, 15, RANDOM()), 2) AS REVENUE_GROWTH_YOY,
    ch.channel AS CHANNEL,
    rg.region AS REGION
FROM PORTFOLIO_COMPANIES c
CROSS JOIN (SELECT $1 AS yr FROM VALUES (2022), (2023), (2024), (2025)) yr
CROSS JOIN (SELECT $1 AS qtr FROM VALUES ('Q1'), ('Q2'), ('Q3'), ('Q4')) qtr
CROSS JOIN (SELECT $1 AS channel FROM VALUES ('DTC eCommerce'), ('Wholesale Retail'), ('Amazon Marketplace')) ch
CROSS JOIN (SELECT $1 AS region FROM VALUES ('North America'), ('Europe'), ('Asia Pacific')) rg;

INSERT INTO DIGITAL_ANALYTICS (COMPANY_ID, METRIC_DATE, WEBSITE_TRAFFIC, UNIQUE_VISITORS, BOUNCE_RATE, CONVERSION_RATE, AVG_ORDER_VALUE, CART_ABANDON_RATE, EMAIL_OPEN_RATE, EMAIL_CLICK_RATE, PAID_ROAS, ORGANIC_TRAFFIC_PCT, MOBILE_TRAFFIC_PCT, CUSTOMER_ACQ_COST, LTV_CAC_RATIO, CHANNEL_NAME)
SELECT
    c.COMPANY_ID,
    DATEADD('month', seq.seq, '2023-01-01')::DATE AS METRIC_DATE,
    ROUND(100000 + (c.COMPANY_ID * 25000) + (seq.seq * 5000) + UNIFORM(-20000, 30000, RANDOM())) AS WEBSITE_TRAFFIC,
    ROUND((100000 + (c.COMPANY_ID * 25000) + (seq.seq * 5000)) * 0.65 + UNIFORM(-10000, 15000, RANDOM())) AS UNIQUE_VISITORS,
    ROUND(35 + UNIFORM(-10, 15, RANDOM()), 2) AS BOUNCE_RATE,
    ROUND(2.5 + (c.COMPANY_ID * 0.15) + UNIFORM(-0.8, 1.2, RANDOM()), 2) AS CONVERSION_RATE,
    ROUND(55 + (c.COMPANY_ID * 5) + UNIFORM(-15, 25, RANDOM()), 2) AS AVG_ORDER_VALUE,
    ROUND(68 + UNIFORM(-12, 8, RANDOM()), 2) AS CART_ABANDON_RATE,
    ROUND(22 + UNIFORM(-5, 8, RANDOM()), 2) AS EMAIL_OPEN_RATE,
    ROUND(3.5 + UNIFORM(-1.5, 2.5, RANDOM()), 2) AS EMAIL_CLICK_RATE,
    ROUND(3.2 + UNIFORM(-1.0, 2.5, RANDOM()), 2) AS PAID_ROAS,
    ROUND(40 + UNIFORM(-10, 20, RANDOM()), 2) AS ORGANIC_TRAFFIC_PCT,
    ROUND(62 + UNIFORM(-8, 12, RANDOM()), 2) AS MOBILE_TRAFFIC_PCT,
    ROUND(25 + (c.COMPANY_ID * 2) + UNIFORM(-8, 12, RANDOM()), 2) AS CUSTOMER_ACQ_COST,
    ROUND(3.0 + UNIFORM(-0.5, 2.0, RANDOM()), 2) AS LTV_CAC_RATIO,
    ch.channel_name AS CHANNEL_NAME
FROM PORTFOLIO_COMPANIES c
CROSS JOIN (SELECT ROW_NUMBER() OVER (ORDER BY seq4()) - 1 AS seq FROM TABLE(GENERATOR(ROWCOUNT => 30))) seq
CROSS JOIN (SELECT $1 AS channel_name FROM VALUES ('Organic Search'), ('Paid Search'), ('Social Media'), ('Email'), ('Direct')) ch
WHERE DATEADD('month', seq.seq, '2023-01-01')::DATE <= '2025-12-31';

INSERT INTO MARKET_RESEARCH (COMPANY_ID, RESEARCH_DATE, CATEGORY, MARKET_SIZE_USD, MARKET_GROWTH_RATE, TAM_USD, SAM_USD, SOM_USD, COMPETITIVE_POSITION, KEY_COMPETITORS, CONSUMER_TREND, INSIGHT_SUMMARY, SOURCE)
VALUES
    (1, '2025-01-15', 'Organic Snacks', 12500000000, 8.5, 45000000000, 18000000000, 2500000000, 'Strong Challenger', 'KIND, RXBar, Clif Bar, Nature Valley', 'Clean label demand growing 12% annually', 'BrightLeaf is well-positioned in the fast-growing organic snack category. The brand has achieved strong distribution gains and consumer loyalty is above category average. Key risk is private label competition from major retailers.', 'Nielsen IQ'),
    (2, '2025-02-10', 'Athleisure Apparel', 350000000000, 7.2, 350000000000, 85000000000, 5000000000, 'Emerging Leader', 'Lululemon, Nike, Athleta, Vuori, Alo Yoga', 'Sustainability and inclusivity driving purchase decisions', 'UrbanPulse has differentiated through inclusive sizing and sustainable materials. The DTC model provides margin advantage but wholesale expansion is needed for scale. The athleisure market shows no signs of slowing.', 'Euromonitor'),
    (3, '2025-01-28', 'Clean Beauty', 11200000000, 12.3, 580000000000, 25000000000, 1800000000, 'Niche Leader', 'Drunk Elephant, The Ordinary, Tatcha, Glossier', 'Ingredient transparency is the #1 purchase driver', 'PureGlow has exceptional repeat purchase metrics and social media engagement. The clean beauty segment continues to outpace overall beauty growth. International expansion represents the largest untapped opportunity.', 'NPD Group'),
    (4, '2025-03-05', 'Premium Pet Food', 42000000000, 6.8, 42000000000, 15000000000, 3200000000, 'Market Leader', 'Blue Buffalo, Wellness, Orijen, Farmers Dog', 'Pet humanization trend accelerating premium spend', 'TailWag has built a strong subscription base and veterinary channel. The pet humanization mega-trend continues to drive premiumization. Expansion into wellness supplements is a high-margin growth vector.', 'Packaged Facts'),
    (5, '2025-02-20', 'Functional Beverages', 170000000000, 9.1, 170000000000, 35000000000, 2100000000, 'Fast Mover', 'Celsius, Liquid IV, Poppi, Olipop, Prime', 'Gen Z driving zero-sugar functional beverage adoption', 'FrostBite has captured Gen Z attention with viral social marketing. The functional beverage category is one of the fastest-growing in CPG. Distribution expansion and retail velocity improvements are key priorities.', 'SPINS'),
    (6, '2024-11-15', 'Home Decor', 195000000000, 4.2, 195000000000, 40000000000, 1500000000, 'Challenger', 'West Elm, CB2, Anthropologie Home, Article', 'Millennials investing in home as experience space', 'NestCraft has strong eCommerce metrics but faces headwinds from housing market softness. The brand aesthetic resonates well with 28-40 demographics. Retail partnership strategy should focus on experiential showrooms.', 'Statista'),
    (7, '2025-01-05', 'Kids Nutrition', 8500000000, 10.5, 28000000000, 8500000000, 800000000, 'Early Mover', 'GoGo SqueeZ, Annie''s, Happy Baby, Once Upon a Farm', 'Parents prioritizing clean-label nutrition for children', 'VitalKids is in a rapidly growing niche with limited competition from established brands. The pediatric nutritionist endorsement strategy provides credibility. Expansion into school and daycare channels represents significant opportunity.', 'IRI'),
    (8, '2025-02-14', 'Comfort Footwear', 85000000000, 5.5, 400000000000, 85000000000, 8500000000, 'Strong Challenger', 'Hoka, On Running, Allbirds, New Balance', 'Comfort and performance converging in footwear', 'CloudStep has strong brand loyalty and repeat purchase rates. The patented cushioning technology provides defensible differentiation. International expansion, particularly in Asia, is the largest growth opportunity.', 'NPD Group'),
    (9, '2025-03-01', 'Sustainable Fashion', 7800000000, 15.2, 1700000000000, 35000000000, 900000000, 'Pioneer', 'Everlane, Pact, Reformation, Pangaia', 'Circular economy and supply chain transparency as key differentiators', 'GreenThread is positioned at the intersection of two mega-trends: sustainability and basics/essentials. The transparent supply chain narrative resonates strongly with Gen Z. Scale challenges remain in maintaining unit economics.', 'ThredUp Resale Report'),
    (10, '2025-01-20', 'Dietary Supplements', 165000000000, 7.8, 165000000000, 45000000000, 4500000000, 'Established Player', 'Nature Made, Garden of Life, Ritual, Athletic Greens', 'Clinical validation becoming table stakes for premium supplements', 'SunRise has differentiated through clinical studies and pharmacy distribution. The subscription model provides revenue visibility. The supplement market is increasingly crowded but science-backed brands are gaining share.', 'Grand View Research'),
    (11, '2024-12-10', 'Outdoor Gear', 22000000000, 5.0, 120000000000, 22000000000, 3500000000, 'Heritage Brand', 'Patagonia, REI Co-op, Arc''teryx, The North Face', 'Outdoor participation rates elevated post-pandemic', 'WildTrail benefits from sustained outdoor participation rates. The brand community is highly engaged and provides organic growth. Sustainability credentials are strong and align with the outdoor consumer ethos.', 'Outdoor Industry Association'),
    (12, '2025-02-05', 'Kids Entertainment', 32000000000, 11.0, 150000000000, 32000000000, 1200000000, 'Innovator', 'LEGO, Nintendo, Roblox, Mattel', 'AR/VR and digital-physical convergence in play', 'PixelPlay is at the forefront of the phygital play trend. The AR integration provides differentiation from traditional toy companies. Subscription boxes provide recurring revenue. Licensing partnerships are a key growth lever.', 'The NPD Group');

INSERT INTO CHANNEL_PERFORMANCE (COMPANY_ID, FISCAL_YEAR, FISCAL_QUARTER, CHANNEL_TYPE, CHANNEL_REVENUE, CHANNEL_MARGIN, UNITS_SOLD, AVG_SELLING_PRICE, RETURN_RATE, CUSTOMER_COUNT, NEW_CUSTOMER_PCT, REPEAT_PURCHASE_RATE)
SELECT
    c.COMPANY_ID,
    yr.yr AS FISCAL_YEAR,
    qtr.qtr AS FISCAL_QUARTER,
    ch.channel_type AS CHANNEL_TYPE,
    ROUND((c.INVESTMENT_AMOUNT * 0.04 / 4) * ch.rev_mult * (1 + (yr.yr - 2022) * 0.10 + UNIFORM(-0.05, 0.08, RANDOM())), 2) AS CHANNEL_REVENUE,
    ROUND(ch.base_margin + UNIFORM(-3, 5, RANDOM()), 2) AS CHANNEL_MARGIN,
    ROUND(15000 * ch.rev_mult * (1 + (yr.yr - 2022) * 0.08) + UNIFORM(-2000, 3000, RANDOM())) AS UNITS_SOLD,
    ROUND(35 + (c.COMPANY_ID * 3) + UNIFORM(-5, 10, RANDOM()), 2) AS AVG_SELLING_PRICE,
    ROUND(8 + UNIFORM(-3, 5, RANDOM()), 2) AS RETURN_RATE,
    ROUND(5000 * ch.rev_mult + UNIFORM(-500, 1000, RANDOM())) AS CUSTOMER_COUNT,
    ROUND(25 + UNIFORM(-10, 15, RANDOM()), 2) AS NEW_CUSTOMER_PCT,
    ROUND(30 + UNIFORM(-8, 15, RANDOM()), 2) AS REPEAT_PURCHASE_RATE
FROM PORTFOLIO_COMPANIES c
CROSS JOIN (SELECT $1 AS yr FROM VALUES (2022), (2023), (2024), (2025)) yr
CROSS JOIN (SELECT $1 AS qtr FROM VALUES ('Q1'), ('Q2'), ('Q3'), ('Q4')) qtr
CROSS JOIN (
    SELECT $1 AS channel_type, $2 AS rev_mult, $3 AS base_margin
    FROM VALUES
        ('DTC Website', 1.0, 65),
        ('Amazon', 0.8, 42),
        ('Wholesale - Mass', 1.5, 35),
        ('Wholesale - Specialty', 0.6, 48),
        ('Subscription', 0.4, 72)
) ch;

INSERT INTO OPERATIONS_METRICS (COMPANY_ID, METRIC_DATE, INVENTORY_TURNOVER, DAYS_SALES_OUTSTANDING, SUPPLY_CHAIN_SCORE, FULFILLMENT_RATE, ON_TIME_DELIVERY, COGS_PCT_REVENUE, SGA_PCT_REVENUE, CAPEX, WORKING_CAPITAL, CASH_CONVERSION)
SELECT
    c.COMPANY_ID,
    DATEADD('quarter', seq.seq, '2022-01-01')::DATE AS METRIC_DATE,
    ROUND(6 + UNIFORM(-2, 4, RANDOM()), 2) AS INVENTORY_TURNOVER,
    ROUND(35 + UNIFORM(-10, 15, RANDOM()), 2) AS DAYS_SALES_OUTSTANDING,
    ROUND(72 + UNIFORM(-8, 15, RANDOM()), 2) AS SUPPLY_CHAIN_SCORE,
    ROUND(94 + UNIFORM(-5, 4, RANDOM()), 2) AS FULFILLMENT_RATE,
    ROUND(91 + UNIFORM(-6, 7, RANDOM()), 2) AS ON_TIME_DELIVERY,
    ROUND(52 + UNIFORM(-8, 8, RANDOM()), 2) AS COGS_PCT_REVENUE,
    ROUND(28 + UNIFORM(-5, 8, RANDOM()), 2) AS SGA_PCT_REVENUE,
    ROUND(c.INVESTMENT_AMOUNT * 0.02 + UNIFORM(-500000, 1000000, RANDOM()), 2) AS CAPEX,
    ROUND(c.INVESTMENT_AMOUNT * 0.08 + UNIFORM(-2000000, 3000000, RANDOM()), 2) AS WORKING_CAPITAL,
    ROUND(85 + UNIFORM(-10, 10, RANDOM()), 2) AS CASH_CONVERSION
FROM PORTFOLIO_COMPANIES c
CROSS JOIN (SELECT ROW_NUMBER() OVER (ORDER BY seq4()) - 1 AS seq FROM TABLE(GENERATOR(ROWCOUNT => 16))) seq
WHERE DATEADD('quarter', seq.seq, '2022-01-01')::DATE <= '2025-12-31';

INSERT INTO INVESTMENT_DEALS (COMPANY_ID, DEAL_DATE, DEAL_TYPE, DEAL_STAGE, VALUATION, INVESTMENT_AMOUNT, EQUITY_PCT, ENTERPRISE_VALUE, EV_REVENUE_MULTIPLE, EV_EBITDA_MULTIPLE, IRR_PROJECTED, MOIC_PROJECTED, HOLDING_PERIOD_YRS, EXIT_STRATEGY, NOTES)
VALUES
    (1, '2019-03-15', 'Platform Acquisition', 'Closed', 136000000, 85000000, 62.5, 150000000, 3.2, 12.5, 22.0, 2.8, 5.0, 'Strategic sale to major CPG company', 'Strong organic growth story. Distribution expansion into Whole Foods and Target a key value driver.'),
    (2, '2020-07-22', 'Growth Equity', 'Closed', 218000000, 120000000, 55.0, 240000000, 4.5, 18.0, 28.0, 3.2, 4.5, 'IPO or strategic sale', 'DTC-first model with emerging wholesale. Comparable to Vuori trajectory.'),
    (3, '2021-01-10', 'Majority Buyout', 'Closed', 92800000, 65000000, 70.0, 105000000, 5.2, 22.0, 25.0, 3.0, 5.0, 'Sale to strategic beauty conglomerate', 'Clean beauty premium valuations. Strong social-first acquisition strategy.'),
    (4, '2018-11-05', 'Platform Acquisition', 'Closed', 163700000, 95000000, 58.0, 180000000, 3.8, 14.0, 20.0, 2.5, 6.0, 'Strategic sale to pet industry leader', 'Pet humanization tailwind. Subscription model provides recurring revenue visibility.'),
    (5, '2022-04-18', 'Growth Equity', 'Closed', 215600000, 110000000, 51.0, 230000000, 5.8, 25.0, 30.0, 3.5, 4.0, 'IPO', 'Fastest-growing category in beverage. Viral marketing capability is a key asset.'),
    (6, '2020-09-30', 'Majority Buyout', 'Closed', 115300000, 75000000, 65.0, 125000000, 3.0, 15.0, 18.0, 2.2, 5.5, 'Sale to home goods conglomerate', 'eCommerce-native brand with retail expansion potential. Housing market cyclicality is a risk.'),
    (7, '2021-06-14', 'Majority Buyout', 'Closed', 76300000, 55000000, 72.0, 82000000, 4.8, 20.0, 26.0, 3.0, 5.0, 'Strategic sale to kids/family CPG company', 'White space in kids nutrition. Pediatric endorsement strategy is differentiating.'),
    (8, '2019-12-01', 'Growth Equity', 'Closed', 291600000, 140000000, 48.0, 320000000, 3.5, 13.0, 24.0, 2.8, 5.0, 'IPO', 'Patent-protected technology. International expansion is the key growth lever.'),
    (9, '2022-08-20', 'Majority Buyout', 'Closed', 60000000, 45000000, 75.0, 65000000, 6.5, 32.0, 32.0, 3.8, 4.0, 'Strategic sale to sustainable fashion group', 'High growth but early stage. Sustainability premium in valuations is strong.'),
    (10, '2020-02-28', 'Platform Acquisition', 'Closed', 150000000, 90000000, 60.0, 165000000, 3.3, 13.5, 21.0, 2.6, 5.5, 'Strategic sale to pharma/wellness company', 'Science-backed positioning commands premium. Pharmacy channel is defensible.'),
    (11, '2018-05-10', 'Platform Acquisition', 'Closed', 201900000, 105000000, 52.0, 220000000, 2.8, 11.0, 19.0, 2.3, 6.0, 'Strategic sale or secondary', 'Heritage brand with loyal community. Sustainability credentials drive brand equity.'),
    (12, '2023-01-15', 'Growth Equity', 'Closed', 88200000, 60000000, 68.0, 95000000, 7.0, 35.0, 35.0, 4.0, 4.0, 'Strategic sale to entertainment/toy conglomerate', 'Phygital play is emerging category. AR/VR integration is highly differentiated.');

INSERT INTO BRAND_STRATEGY_DOCS (COMPANY_ID, TITLE, CATEGORY, CONTENT, AUTHOR, PUBLISH_DATE, TAGS)
VALUES
    (1, 'BrightLeaf Organics - 100-Day Value Creation Plan', 'Strategy', 'BrightLeaf Organics 100-Day Value Creation Plan. Key priorities include: 1) Expand distribution to 20,000 retail doors by end of year through new partnerships with Kroger and Costco. 2) Launch new product line targeting keto-conscious consumers. 3) Optimize supply chain to improve gross margins by 200 bps through co-packing consolidation. 4) Build out DTC eCommerce with subscription offering. 5) Invest in brand building through influencer partnerships and sampling programs. The organic snack market is growing at 8.5% annually and BrightLeaf is well-positioned to capture share with its clean-label positioning and strong consumer loyalty metrics.', 'Investment Team', '2024-06-15', 'strategy, value-creation, distribution, DTC'),
    (2, 'UrbanPulse Athletics - DTC to Omnichannel Transformation', 'Strategy', 'UrbanPulse Athletics DTC to Omnichannel Strategy. The brand has achieved $180M in DTC revenue and is now expanding into wholesale. Key initiatives: 1) Launch wholesale program with Nordstrom and Dick''s Sporting Goods. 2) Maintain DTC margin advantage while building wholesale infrastructure. 3) Expand inclusive sizing range to capture underserved market segments. 4) Invest in sustainable material innovation to strengthen brand differentiation. 5) Build loyalty program to increase repeat purchase rate from 35% to 50%. The athleisure market is projected to reach $350B globally by 2027.', 'Brand Strategy Team', '2024-08-20', 'omnichannel, DTC, wholesale, sustainability'),
    (3, 'PureGlow Beauty - Social Commerce Playbook', 'Marketing', 'PureGlow Beauty Social Commerce and Community Strategy. The brand generates 65% of DTC revenue through social channels. Key strategies: 1) Scale TikTok Shop presence with creator-led content. 2) Launch community rewards program tied to UGC creation. 3) Expand influencer tier structure from macro to nano influencers. 4) Develop virtual try-on AR feature for key products. 5) Build email/SMS automation for post-purchase engagement. PureGlow has achieved a 40% repeat purchase rate, well above the clean beauty category average of 28%.', 'Digital Marketing Team', '2024-09-10', 'social-commerce, TikTok, community, DTC'),
    (4, 'TailWag Pet Co - Subscription Model Optimization', 'Operations', 'TailWag Pet Co Subscription Optimization Strategy. Current subscription penetration is 45% of revenue. Key initiatives: 1) Implement dynamic pricing based on pet age and dietary needs. 2) Add wellness supplement cross-sell to existing subscribers. 3) Reduce churn through predictive analytics and proactive outreach. 4) Partner with veterinary clinics for prescription diet referrals. 5) Launch pet health tracking app to increase engagement and data collection. The premium pet food subscription market is growing at 15% annually with high customer lifetime values.', 'Operations Team', '2024-07-25', 'subscription, pet-care, retention, cross-sell'),
    (5, 'FrostBite Beverages - Gen Z Marketing and Distribution Strategy', 'Marketing', 'FrostBite Beverages Gen Z Acquisition Strategy. The brand has achieved viral success through authentic social media content. Key strategies: 1) Scale college campus ambassador program to 500 campuses. 2) Secure convenience store distribution through McLane and Core-Mark partnerships. 3) Launch limited-edition flavor collaborations with cultural influencers. 4) Build gaming and esports sponsorship portfolio. 5) Develop sampling program targeting gyms and fitness studios. FrostBite has achieved 3x revenue growth in the past 12 months driven by social virality.', 'Growth Team', '2024-10-05', 'gen-z, distribution, viral-marketing, campus'),
    (NULL, 'TSG Consumer Portfolio - Annual Review 2024', 'Portfolio Review', 'TSG Consumer Partners 2024 Annual Portfolio Review. The portfolio delivered strong performance with aggregate revenue growth of 18% and EBITDA margin expansion of 150 bps. Key highlights: 1) BrightLeaf achieved profitability milestone with 15% EBITDA margins. 2) UrbanPulse wholesale launch exceeded expectations with $45M in first-year wholesale revenue. 3) FrostBite became the fastest-growing brand in the functional beverage category. 4) PureGlow international expansion in UK and France tracking ahead of plan. 5) TailWag subscription revenue hit $50M run rate. Areas of focus for 2025: NestCraft needs accelerated growth strategy, GreenThread unit economics require optimization, and PixelPlay needs to prove subscription box scalability.', 'Managing Directors', '2025-01-15', 'annual-review, portfolio, performance'),
    (NULL, 'Consumer Brand Digital Transformation Best Practices', 'Best Practices', 'Digital Transformation Playbook for Consumer Brands. Based on TSG Consumer portfolio learnings, key best practices include: 1) DTC First, Omnichannel Second - build brand and margin in DTC before wholesale expansion. 2) Data-Driven Personalization - leverage first-party data for personalized marketing and product recommendations. 3) Community Over Customers - build engaged communities that drive organic acquisition. 4) Supply Chain as Competitive Advantage - invest in supply chain technology and visibility. 5) Subscription and Recurring Revenue - implement subscription models where product velocity supports it. 6) Content Commerce Integration - blur the line between content and commerce for higher engagement. 7) International Expansion Sequencing - test with DTC in target markets before investing in local operations.', 'Operating Partners', '2024-12-01', 'digital-transformation, best-practices, DTC, omnichannel'),
    (NULL, 'Private Equity Value Creation in Consumer Brands', 'Thought Leadership', 'TSG Consumer Partners Approach to Value Creation. Our investment thesis centers on partnering with founder-led consumer brands at inflection points. Key value creation levers: 1) Revenue Acceleration - expand distribution, launch new channels, enter new markets. 2) Margin Improvement - optimize supply chain, improve procurement, reduce waste. 3) Organizational Build-Out - recruit experienced operators while preserving founder culture. 4) Brand Building - invest in brand equity through strategic marketing and consumer insights. 5) M&A and Bolt-On Strategy - acquire complementary brands and capabilities. 6) Data and Technology - implement analytics capabilities for decision-making. 7) ESG Integration - embed sustainability into operations and brand narrative. Our portfolio companies have delivered average revenue CAGR of 22% and average EBITDA expansion of 500+ bps during our holding period.', 'Senior Partners', '2025-02-01', 'value-creation, private-equity, thesis, ESG');
