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
    ('ATI Restoration', 'Home Services', 'Restoration Services', '2016-09-15', 175000000, 55.0, 'Active', 'Orange, CA', 3200, 2012, 'National leader in property restoration and environmental services specializing in fire, water, mold, and storm damage remediation across residential and commercial properties with operations in 40+ states.'),
    ('Crumbl Cookies', 'Food & Beverage', 'Specialty Bakery', '2022-01-20', 200000000, 40.0, 'Active', 'Lindon, UT', 5000, 2017, 'Fastest-growing cookie company in the US with a rotating weekly menu, viral social media presence, and 900+ franchise locations. Known for its pink box packaging and innovative flavor drops that generate massive consumer engagement.'),
    ('Thrive Pet Healthcare', 'Pet Care', 'Veterinary Services', '2018-06-10', 300000000, 58.0, 'Active', 'Austin, TX', 8500, 2006, 'One of the largest veterinary-led pet healthcare platforms in the US, operating 400+ veterinary clinics and emergency hospitals. Focused on accessible, community-based veterinary care with a tech-enabled operating model.'),
    ('Saltair', 'Health & Beauty', 'Personal Care', '2023-03-05', 50000000, 65.0, 'Active', 'Los Angeles, CA', 120, 2021, 'Clean body care brand offering clinically effective products at accessible price points. Built with dermatologist-backed formulations and strong DTC and retail presence through Target, Ulta, and Amazon.'),
    ('Wrench Group', 'Home Services', 'HVAC & Plumbing', '2019-11-01', 250000000, 52.0, 'Active', 'Atlanta, GA', 4500, 2015, 'Leading residential home services platform specializing in HVAC, plumbing, and electrical services. Operates across 15+ markets through a buy-and-build strategy with strong recurring revenue from maintenance contracts.'),
    ('DUDE Wipes', 'Consumer Products', 'Personal Hygiene', '2022-07-15', 100000000, 60.0, 'Active', 'Chicago, IL', 85, 2012, 'Disruptive personal hygiene brand that pioneered the men''s flushable wipes category. Known for irreverent branding and humor-driven marketing. Distributed in 40,000+ retail doors including Walmart, Target, and Costco.'),
    ('Legacy.com', 'Digital Media', 'Online Memorials', '2017-04-22', 125000000, 62.0, 'Active', 'Evanston, IL', 280, 1998, 'The world''s largest obituary and memorial website, partnering with 1,500+ newspapers and funeral homes. Reaches 40M+ monthly visitors and provides a platform for celebrating lives through online tributes and memorial donations.'),
    ('Mavis Tire', 'Automotive Services', 'Tire & Auto Service', '2018-03-10', 450000000, 50.0, 'Active', 'Millwood, NY', 9000, 1972, 'One of the largest independent tire and automotive service chains in the US with 1,300+ locations across 26 states. Full-service offerings include tires, brakes, oil changes, and general repairs with strong consumer loyalty.'),
    ('Power Stop', 'Automotive Parts', 'Performance Brakes', '2019-08-20', 130000000, 55.0, 'Active', 'Burr Ridge, IL', 420, 2001, 'Leading eCommerce-first aftermarket brake parts brand offering performance and daily-driver brake kits. Dominant Amazon presence with strong DTC growth and expanding wholesale distribution through AutoZone and O''Reilly.'),
    ('Radiance Holdings', 'Health & Beauty', 'Med Spa & Aesthetics', '2021-02-15', 180000000, 57.0, 'Active', 'Scottsdale, AZ', 2200, 2018, 'Multi-brand med spa and aesthetics platform offering Botox, fillers, laser treatments, and wellness services. Operates 100+ locations with a technology-driven customer experience and strong recurring revenue model.'),
    ('Revolut Ltd', 'Fintech', 'Digital Banking', '2023-06-01', 150000000, 15.0, 'Active', 'London, UK', 8000, 2015, 'Global fintech super-app with 40M+ customers offering banking, crypto, trading, insurance, and travel services. Expanding US operations with a focus on premium subscription tiers and business banking.'),
    ('Super Star Car Wash', 'Automotive Services', 'Car Wash', '2020-10-05', 200000000, 53.0, 'Active', 'Phoenix, AZ', 2800, 1997, 'Leading express car wash platform in the Southwest US with 100+ locations. Subscription-based membership model drives 70%+ recurring revenue. Rapidly expanding through new builds and acquisitions across Arizona, Texas, and Colorado.');

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
    (1, '2025-01-15', 'Property Restoration Services', 85000000000, 6.2, 85000000000, 25000000000, 3500000000, 'Market Leader', 'SERVPRO, ServiceMaster, Paul Davis Restoration, Belfor', 'Climate-driven demand increasing frequency and severity of restoration events', 'ATI Restoration is well-positioned as a national leader in property restoration. Climate change is accelerating demand for fire, water, and storm damage services. The company''s scale and geographic coverage provide competitive advantages in insurance carrier relationships and response times. Key growth vector is expansion into new geographies and adjacencies like environmental services.', 'IBISWorld'),
    (2, '2025-02-10', 'Specialty Bakery & Cookies', 12000000000, 9.8, 45000000000, 12000000000, 2500000000, 'Category Creator', 'Insomnia Cookies, Last Crumb, Levain Bakery, Nothing Bundt Cakes', 'Limited-time offerings and social media virality driving bakery category disruption', 'Crumbl Cookies has redefined the specialty bakery category with its rotating weekly menu model and viral social media strategy. With 900+ franchise locations and TikTok as a primary marketing engine, Crumbl has built a cultural brand. The franchise model provides capital-light growth. Key risks include franchise saturation and consumer fatigue with limited-time offers.', 'Technomic'),
    (3, '2025-03-05', 'Veterinary Services', 55000000000, 8.5, 55000000000, 20000000000, 5000000000, 'Strong Challenger', 'Mars Veterinary (VCA, Banfield), NVA, Pathway Vet Alliance, PetVet Care', 'Pet humanization driving spend on veterinary care; demand outpacing supply of veterinarians', 'Thrive Pet Healthcare operates 400+ clinics and is one of the largest vet-led platforms in the US. The pet humanization mega-trend continues to drive increased spending on preventive and specialty care. The veterinarian shortage creates both an opportunity (pricing power) and challenge (recruiting). Telehealth and tech-enabled operations are key differentiators.', 'APPA'),
    (4, '2025-01-28', 'Clean Personal Care', 22000000000, 11.5, 80000000000, 22000000000, 800000000, 'Emerging Leader', 'Native, Dr. Squatch, Necessaire, Dove, Olay', 'Consumers trading up to clean, dermatologist-backed body care at mass price points', 'Saltair has found a white-space position in the clean body care market — clinical efficacy at accessible prices. Strong traction at Target and Ulta with DTC providing high-margin incremental revenue. The brand has a loyal following among millennial and Gen Z consumers. Key growth drivers are new product categories (hair, face) and international expansion.', 'Circana'),
    (5, '2024-11-15', 'Residential Home Services', 120000000000, 7.0, 500000000000, 120000000000, 8000000000, 'Platform Leader', 'Service Experts, Home Depot Services, Neighborly, Mr. Rooter', 'Aging housing stock and climate extremes driving HVAC and plumbing demand', 'Wrench Group is a leading residential services platform with strong positioning in HVAC, plumbing, and electrical. The aging US housing stock and increasing climate extremes create sustained demand. The buy-and-build strategy has delivered significant scale. Recurring revenue from maintenance contracts provides revenue visibility. Key focus is operational integration and technician recruitment.', 'Statista'),
    (6, '2025-01-05', 'Flushable Wipes & Personal Hygiene', 5200000000, 8.0, 18000000000, 5200000000, 600000000, 'Category Pioneer', 'Cottonelle, Charmin, Goodwipes, Burt''s Bees', 'Men''s personal care and hygiene products growing as stigma decreases', 'DUDE Wipes created the men''s flushable wipes category and dominates it with irreverent branding and humor-driven marketing. Distribution across 40,000+ retail doors provides massive reach. The brand has successfully expanded into body wipes, shower wipes, and deodorants. Key opportunities include international expansion and women''s line extension.', 'Nielsen IQ'),
    (7, '2025-02-20', 'Digital Memorial & Obituary Services', 3500000000, 4.0, 15000000000, 3500000000, 1500000000, 'Market Leader', 'Dignity Memorial, FuneralOne, Echovita, Tributes.com', 'Digital memorialization becoming standard; growing interest in legacy preservation', 'Legacy.com is the dominant digital platform for obituaries and memorials with 40M+ monthly visitors. The business benefits from strong newspaper and funeral home partnerships. The shift from print to digital obituaries is a secular tailwind. Revenue diversification into memorial donations, flowers, and premium tributes is expanding monetization. The sticky B2B relationships provide defensibility.', 'IBISWorld'),
    (8, '2025-02-14', 'Tire & Auto Service', 150000000000, 3.5, 150000000000, 65000000000, 12000000000, 'Top 3 National', 'Discount Tire, Goodyear Auto Service, Firestone, Pep Boys, Meineke', 'Vehicle miles traveled recovering post-pandemic; average vehicle age at record 12.5 years', 'Mavis Tire is one of the largest independent tire and auto service chains with 1,300+ locations. The aging US vehicle fleet (avg. 12.5 years) drives sustained demand for maintenance and tire replacement. Scale provides purchasing power and brand recognition. Greenfield expansion and tuck-in acquisitions continue to drive growth. Key challenge is technician labor availability.', 'SEMA'),
    (9, '2025-03-01', 'Aftermarket Brake Parts', 14000000000, 5.5, 70000000000, 14000000000, 2000000000, 'eCommerce Leader', 'Akebono, Wagner, Bosch, ACDelco, EBC Brakes', 'DIY auto maintenance growing as consumers seek value; eCommerce penetration accelerating', 'Power Stop has built a dominant eCommerce-first position in aftermarket brakes. The brand ranks #1 on Amazon in brake kits and is expanding wholesale through AutoZone and O''Reilly. The DIY auto maintenance trend and aging vehicle fleet are structural tailwinds. The direct-to-consumer model provides higher margins than traditional aftermarket distribution. Product expansion into rotors and calipers is incremental.', 'Grand View Research'),
    (10, '2025-01-20', 'Med Spa & Aesthetics', 28000000000, 14.0, 100000000000, 28000000000, 3500000000, 'Platform Builder', 'Ideal Image, LaserAway, SkinSpirit, AesthetiCare', 'Non-surgical aesthetics normalizing across demographics; GLP-1 treatments expanding market', 'Radiance Holdings is building a leading multi-brand med spa platform. The aesthetics market is one of the fastest-growing in consumer health, driven by normalization across age groups and genders. GLP-1 weight loss treatments are expanding the addressable market for body contouring. The recurring revenue model (Botox maintenance, memberships) provides excellent visibility. Key focus is standardizing operations across 100+ locations.', 'American Med Spa Association'),
    (11, '2024-12-10', 'Digital Banking & Fintech', 120000000000, 15.0, 1200000000000, 120000000000, 5000000000, 'Global Disruptor', 'Chime, Monzo, N26, Wise, Cash App, Nubank', 'Consumers demanding all-in-one financial super-apps; subscription banking gaining traction', 'Revolut has built a global fintech platform with 40M+ customers across 38 countries. The super-app model (banking, crypto, trading, insurance, travel) creates high engagement and cross-sell opportunities. Premium subscription tiers drive strong unit economics. US expansion represents the largest growth opportunity. Key challenge is navigating regulatory complexity across multiple markets.', 'CB Insights'),
    (12, '2025-02-05', 'Express Car Wash', 15000000000, 10.0, 35000000000, 15000000000, 2000000000, 'Regional Leader', 'Mister Car Wash, Take 5, Zips, Whistle Express, Quick Quack', 'Subscription-based car wash memberships driving recurring revenue and customer loyalty', 'Super Star Car Wash is a leading express car wash platform in the Southwest with 100+ locations. The subscription membership model drives 70%+ recurring revenue with strong retention. The express format (3-minute automated wash) provides high throughput and labor efficiency. Expansion through new builds and acquisitions in Arizona, Texas, and Colorado. The fragmented car wash market offers significant consolidation opportunity.', 'IBISWorld');

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
    (1, '2016-09-15', 'Platform Acquisition', 'Closed', 318000000, 175000000, 55.0, 350000000, 2.8, 10.5, 20.0, 2.5, 7.0, 'Strategic sale to insurance carrier or PE', 'National scale in restoration services. Climate risk tailwind drives demand growth. Insurance carrier relationships provide defensible revenue base. Geographic expansion into underserved markets is the primary growth lever.'),
    (2, '2022-01-20', 'Growth Equity', 'Closed', 500000000, 200000000, 40.0, 550000000, 6.5, 28.0, 30.0, 3.5, 5.0, 'IPO or strategic sale', 'Franchise-model provides capital-light scaling. Viral social media engine generates organic demand. Rotating weekly menu creates urgency and repeat visits. Comparable to fast-casual franchises at a premium multiple.'),
    (3, '2018-06-10', 'Platform Acquisition', 'Closed', 517000000, 300000000, 58.0, 570000000, 3.5, 14.0, 22.0, 2.8, 6.0, 'Strategic sale to pet health conglomerate or PE secondary', 'Vet-led model differentiates from corporate-owned competitors. Pet humanization mega-trend is structural. Tech-enabled operations reduce costs. Clinic density strategy creates referral networks and emergency coverage.'),
    (4, '2023-03-05', 'Majority Buyout', 'Closed', 76900000, 50000000, 65.0, 82000000, 8.0, 35.0, 35.0, 4.0, 4.0, 'Sale to strategic beauty or consumer conglomerate', 'Early-stage but fast-growing clean body care brand. Retail distribution through Target and Ulta validated product-market fit. DTC and Amazon channels provide high-margin revenue. Category expansion into hair and face care is the primary growth vector.'),
    (5, '2019-11-01', 'Platform Acquisition', 'Closed', 480700000, 250000000, 52.0, 530000000, 2.5, 11.0, 21.0, 2.6, 6.0, 'Strategic sale or PE secondary', 'Residential services platform with recurring maintenance revenue. Buy-and-build strategy proven with 15+ successful tuck-ins. Aging housing stock creates sustained demand. Technician training academy addresses labor shortage.'),
    (6, '2022-07-15', 'Majority Buyout', 'Closed', 166600000, 100000000, 60.0, 180000000, 5.0, 20.0, 25.0, 3.0, 5.0, 'Strategic sale to CPG company', 'Category creator with dominant brand awareness. Humor-driven marketing is highly efficient. 40K+ retail doors provide massive distribution. Extension into adjacent personal care categories (body wipes, deodorant) drives growth.'),
    (7, '2017-04-22', 'Platform Acquisition', 'Closed', 201600000, 125000000, 62.0, 220000000, 3.5, 13.0, 18.0, 2.3, 7.0, 'Strategic sale or PE secondary', 'Dominant digital memorial platform with 40M+ monthly visitors. Print-to-digital obituary shift is secular tailwind. Sticky newspaper and funeral home partnerships. Revenue diversification through memorial donations and premium tributes.'),
    (8, '2018-03-10', 'Growth Equity', 'Closed', 900000000, 450000000, 50.0, 1000000000, 2.2, 9.0, 18.0, 2.2, 6.0, 'IPO', '1,300+ location scale provides purchasing power and brand recognition. Aging vehicle fleet (avg 12.5 years) drives sustained maintenance demand. Greenfield and tuck-in expansion model is repeatable. Labor and real estate are key operational challenges.'),
    (9, '2019-08-20', 'Majority Buyout', 'Closed', 236300000, 130000000, 55.0, 260000000, 4.0, 16.0, 24.0, 2.8, 5.0, 'Strategic sale to auto parts conglomerate', 'eCommerce-first aftermarket brake leader. #1 on Amazon in brake kits. DIY auto maintenance trend and aging fleet are tailwinds. Wholesale expansion through AutoZone and O''Reilly is additive. Product expansion into rotors and calipers.'),
    (10, '2021-02-15', 'Platform Acquisition', 'Closed', 315700000, 180000000, 57.0, 350000000, 5.5, 22.0, 28.0, 3.2, 5.0, 'IPO or strategic sale to healthcare company', 'Fastest-growing segment in consumer health. Non-surgical aesthetics normalizing across demographics. GLP-1 treatments expanding addressable market. Membership model provides recurring revenue. Standardizing operations across 100+ locations is key value creation lever.'),
    (11, '2023-06-01', 'Growth Equity', 'Closed', 1000000000, 150000000, 15.0, 1100000000, 9.0, 50.0, 25.0, 3.0, 5.0, 'IPO', 'Global fintech super-app with 40M+ customers. Multi-product platform (banking, crypto, trading, insurance) drives high engagement. Premium subscriptions improve unit economics. US expansion is the largest growth vector. Regulatory navigation across 38 countries is key risk.'),
    (12, '2020-10-05', 'Platform Acquisition', 'Closed', 377300000, 200000000, 53.0, 420000000, 3.8, 15.0, 23.0, 2.8, 5.0, 'Strategic sale or PE secondary', 'Subscription membership model drives 70%+ recurring revenue. Express format provides high throughput and labor efficiency. Southwest US footprint with expansion runway. Fragmented market offers consolidation opportunity. New builds and tuck-in acquisitions are the dual growth engines.');

INSERT INTO BRAND_STRATEGY_DOCS (COMPANY_ID, TITLE, CATEGORY, CONTENT, AUTHOR, PUBLISH_DATE, TAGS)
VALUES
    (1, 'ATI Restoration - National Expansion and Insurance Carrier Strategy', 'Strategy', 'ATI Restoration National Growth Strategy. Key priorities include: 1) Expand geographic footprint into 5 new states targeting underserved markets with high catastrophe exposure. 2) Deepen insurance carrier relationships to become preferred vendor for top 10 national carriers. 3) Invest in technology platform for job management, estimating, and real-time project tracking. 4) Launch environmental services division for mold remediation and asbestos abatement. 5) Build training academy to address skilled labor shortage and reduce subcontractor dependency. The property restoration market is growing at 6.2% driven by climate-related events and aging infrastructure.', 'Investment Team', '2024-06-15', 'strategy, expansion, insurance, climate'),
    (2, 'Crumbl Cookies - Franchise Optimization and Brand Extension', 'Strategy', 'Crumbl Cookies Growth and Brand Extension Strategy. Key initiatives: 1) Optimize franchise unit economics through supply chain improvements and menu engineering. 2) Expand catering and corporate gifting channels for incremental revenue. 3) Launch CPG product line (packaged cookies in grocery) to extend brand into new occasions. 4) Scale loyalty/rewards program to increase visit frequency. 5) Evaluate international franchise expansion starting with Canada and UK. Crumbl has achieved cultural brand status with 70M+ social media followers and a weekly flavor drop model that creates urgency and virality.', 'Brand Strategy Team', '2024-08-20', 'franchise, CPG, social-media, brand-extension'),
    (3, 'Thrive Pet Healthcare - Clinic Density and Specialty Services', 'Strategy', 'Thrive Pet Healthcare Platform Growth Strategy. Key strategies: 1) Increase clinic density in top 20 DMAs to build referral networks and emergency coverage. 2) Add specialty and emergency services at hub locations to capture higher-acuity spend. 3) Deploy telehealth platform for triage and follow-up visits to reduce no-shows. 4) Invest in veterinary recruiting and retention through competitive compensation and career development. 5) Build data analytics capability for population health management and preventive care protocols. Thrive operates 400+ clinics and the vet shortage is creating both pricing power and recruiting challenges.', 'Operations Team', '2024-09-10', 'veterinary, platform, specialty, telehealth'),
    (4, 'Saltair - DTC Growth and Category Expansion', 'Marketing', 'Saltair Brand Growth and Category Expansion Strategy. Key priorities: 1) Scale DTC channel with subscription offering for core body care products. 2) Expand into hair care and facial care categories leveraging existing brand equity. 3) Deepen retail partnerships with Target, Ulta, and Sephora with exclusive product launches. 4) Build influencer and dermatologist advocacy program. 5) Evaluate international expansion starting with UK and Canada through digital channels. Saltair has achieved strong traction as a clean body care brand at accessible price points, resonating with millennial and Gen Z consumers seeking clinical efficacy without premium pricing.', 'Digital Marketing Team', '2024-07-25', 'DTC, clean-beauty, retail, category-expansion'),
    (5, 'Wrench Group - Buy-and-Build Integration Playbook', 'Operations', 'Wrench Group Acquisition Integration and Operational Excellence Playbook. Key initiatives: 1) Standardize back-office operations (CRM, scheduling, dispatch) across all acquired brands. 2) Launch centralized technician training academy to improve quality and reduce callbacks. 3) Scale maintenance contract program to 40% of revenue for recurring visibility. 4) Implement dynamic pricing based on demand, seasonality, and urgency. 5) Evaluate expansion into additional home services verticals (roofing, windows, insulation). Wrench Group has completed 15+ acquisitions and operational integration is the primary value creation lever.', 'Operations Team', '2024-10-05', 'buy-and-build, integration, home-services, recurring-revenue'),
    (NULL, 'TSG Consumer Portfolio - Annual Review 2024', 'Portfolio Review', 'TSG Consumer Partners 2024 Annual Portfolio Review. The portfolio delivered strong performance with aggregate revenue growth of 16% and EBITDA margin expansion of 120 bps. Key highlights: 1) Crumbl Cookies surpassed 900 franchise locations with same-store sales growth of 8%. 2) Thrive Pet Healthcare successfully integrated 50 new clinics and launched specialty services in 20 hub locations. 3) Mavis Tire expanded to 1,300+ locations with strong tire unit sales. 4) Super Star Car Wash membership base grew 35% year-over-year. 5) DUDE Wipes achieved 40,000+ retail doors with successful body wipe line extension. Areas of focus for 2025: Saltair needs to prove category expansion thesis, Legacy.com needs accelerated digital monetization, and Revolut US expansion requires regulatory clarity.', 'Managing Directors', '2025-01-15', 'annual-review, portfolio, performance'),
    (NULL, 'Consumer Services Platform Building Best Practices', 'Best Practices', 'Platform Building Playbook for Consumer Services. Based on TSG Consumer portfolio learnings across ATI Restoration, Wrench Group, Thrive Pet Healthcare, Mavis Tire, and Super Star Car Wash, key best practices include: 1) Standardize Before Scale - implement common technology and operating playbooks before aggressive M&A. 2) Recurring Revenue First - build membership, subscription, or maintenance contract revenue for visibility and valuation premium. 3) Talent as Competitive Moat - invest in training academies and career paths to address labor scarcity in services. 4) Hub-and-Spoke Density - build geographic density for brand awareness, cross-referrals, and operational efficiency. 5) Technology as Enabler - deploy scheduling, dispatch, and customer management platforms to improve utilization. 6) Consumer Experience Standardization - ensure consistent quality across locations. 7) Data-Driven Pricing - use demand signals and competitive data to optimize pricing and margins.', 'Operating Partners', '2024-12-01', 'platform-building, services, best-practices, recurring-revenue'),
    (NULL, 'Private Equity Value Creation in Consumer Brands', 'Thought Leadership', 'TSG Consumer Partners Approach to Value Creation. Our investment thesis centers on partnering with founder-led consumer brands and services platforms at inflection points. Key value creation levers: 1) Revenue Acceleration - expand distribution, launch new channels, enter new markets, scale franchise models. 2) Margin Improvement - optimize supply chain, improve procurement, standardize operations. 3) Organizational Build-Out - recruit experienced operators while preserving founder culture and brand DNA. 4) Brand Building - invest in brand equity through strategic marketing, social media, and consumer insights. 5) M&A and Bolt-On Strategy - acquire complementary brands, locations, and capabilities for platform building. 6) Data and Technology - implement analytics capabilities for pricing, operations, and customer management. 7) Recurring Revenue Models - build membership, subscription, and maintenance programs for revenue visibility and valuation premium. Our portfolio companies have delivered average revenue CAGR of 18% and average EBITDA expansion of 400+ bps during our holding period.', 'Senior Partners', '2025-02-01', 'value-creation, private-equity, thesis, platform-building');
