# Snowflake Cost Management Best Practices
## Prepared for TSG Consumer Partners

---

## 1. Warehouse Strategy & Segmentation

The most impactful cost lever is compute (warehouses). We recommend segmenting warehouses by business unit or project to enable visibility, control, and future chargeback.

### Recommended Warehouse Structure

| Workload Type | Warehouse Size | Clustering | Use Case |
|---|---|---|---|
| High-concurrency (user-facing apps, BI) | XS–S, Multi-cluster (scales to 5) | AUTO | Many concurrent users/queries |
| Heavy processing (ML training, large transforms) | M–XL, Single cluster | STANDARD | Large batch jobs, model training |
| Dev/Test | XS | STANDARD | Experimentation (isolate from prod) |

### Setup Example

```sql
-- Create a warehouse for the deal-sourcing project
CREATE WAREHOUSE IF NOT EXISTS WH_DEAL_SOURCING
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 60          -- suspend after 60 seconds idle
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 3      -- multi-cluster for concurrency
  SCALING_POLICY = 'STANDARD'
  COMMENT = 'Deal-sourcing project compute';

-- Create a warehouse for ML model training
CREATE WAREHOUSE IF NOT EXISTS WH_ML_TRAINING
  WAREHOUSE_SIZE = 'XLARGE'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'ML model training - large batch workloads';
```

**Key settings:**
- `AUTO_SUSPEND = 60` — Aggressive suspend (60 sec) so you're not paying for idle time
- Separate dev/test from production so experimentation doesn't distort your cost baseline

---

## 2. Tagging for Cost Attribution

Tags let you group resources (warehouses, databases, etc.) so you can roll up costs by business unit, project, or cost center.

### Create and Apply Tags

```sql
-- Create a tag for project-level tracking
CREATE TAG IF NOT EXISTS cost_center
  COMMENT = 'Used to attribute costs to business units or projects';

CREATE TAG IF NOT EXISTS project
  COMMENT = 'Project-level cost attribution';

-- Apply tags to warehouses
ALTER WAREHOUSE WH_DEAL_SOURCING SET TAG cost_center = 'AI_Engineering';
ALTER WAREHOUSE WH_DEAL_SOURCING SET TAG project = 'deal-sourcing-tool';

ALTER WAREHOUSE WH_ML_TRAINING SET TAG cost_center = 'AI_Engineering';
ALTER WAREHOUSE WH_ML_TRAINING SET TAG project = 'ml-models';
```

### Query Costs by Tag

```sql
-- View credit usage rolled up by project tag
SELECT
    tag_value AS project,
    SUM(credits_used) AS total_credits,
    SUM(credits_used) * 3.00 AS estimated_cost  -- adjust multiplier to your rate
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES tr
JOIN SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY wm
  ON tr.object_name = wm.warehouse_name
WHERE tr.tag_name = 'PROJECT'
  AND wm.start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY tag_value
ORDER BY total_credits DESC;
```

---

## 3. Resource Monitors (Guardrails)

Resource monitors cap credit consumption and trigger alerts or auto-suspend before you overshoot budget.

### Setup Examples

```sql
-- Monitor for the entire account (monthly cap)
CREATE RESOURCE MONITOR account_monthly_monitor
  WITH CREDIT_QUOTA = 500  -- adjust to your budget
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75 PERCENT DO NOTIFY          -- email alert at 75%
    ON 90 PERCENT DO NOTIFY          -- email alert at 90%
    ON 100 PERCENT DO SUSPEND        -- suspend warehouses at 100%
    ON 110 PERCENT DO SUSPEND_IMMEDIATE;  -- hard kill at 110%

-- Apply to account
ALTER ACCOUNT SET RESOURCE_MONITOR = account_monthly_monitor;

-- Monitor for a specific warehouse (weekly cap)
CREATE RESOURCE MONITOR deal_sourcing_weekly
  WITH CREDIT_QUOTA = 50
  FREQUENCY = WEEKLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 80 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE WH_DEAL_SOURCING SET RESOURCE_MONITOR = deal_sourcing_weekly;
```

---

## 4. Storage Tracking

Storage is $23/compressed TB/month. Simple to track:

```sql
-- Storage by database
SELECT
    database_name,
    ROUND(SUM(average_database_bytes) / POWER(1024, 4), 3) AS storage_tb,
    ROUND(SUM(average_database_bytes) / POWER(1024, 4) * 23, 2) AS monthly_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY
WHERE usage_date = CURRENT_DATE() - 1
GROUP BY database_name
ORDER BY storage_tb DESC;
```

---

## 5. AI / Token Spend Monitoring

The built-in Cost Management dashboards don't yet show AI credit consumption (coming soon). In the meantime, you can query it directly:

```sql
-- AI credit usage by function type (last 30 days)
SELECT
    DATE_TRUNC('day', start_time) AS usage_date,
    service_type,                    -- e.g., 'AI_SERVICES'
    name AS function_name,           -- e.g., 'COMPLETE', 'TRANSLATE', 'EMBED'
    SUM(credits_used) AS credits_consumed
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY
WHERE service_type = 'AI_SERVICES'
  AND start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2, 3
ORDER BY usage_date DESC, credits_consumed DESC;

-- Alternatively, for more granular token-level detail:
SELECT
    DATE_TRUNC('day', start_time) AS usage_date,
    model_name,
    SUM(tokens_input) AS total_input_tokens,
    SUM(tokens_output) AS total_output_tokens,
    SUM(credits_used) AS total_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_USAGE_HISTORY
WHERE start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY usage_date DESC, total_credits DESC;
```

---

## 6. Cost Management Dashboard (Snowsight)

**Already built-in — no setup needed:**
1. Log into Snowsight
2. Go to **Admin → Cost Management**
3. You'll see spend broken down by warehouse, with trends over time

For custom dashboards, you can build a Streamlit app (see the repos I shared) or use the SQL above in Snowsight Dashboards.

---

## Quick-Start Checklist

- [ ] Create warehouses per project/business unit with aggressive auto-suspend (60s)
- [ ] Create tags (`cost_center`, `project`) and apply to all warehouses
- [ ] Set up resource monitors with notify + suspend thresholds
- [ ] Build a simple dashboard (Snowsight or Streamlit) for storage + compute + AI spend
- [ ] Decide on chargeback model (by tag rollup) when ready

---

*Questions? Reach out to Stephen Dickson (stephen.dickson@snowflake.com) or Ryan Weston (ryan.weston@snowflake.com).*
