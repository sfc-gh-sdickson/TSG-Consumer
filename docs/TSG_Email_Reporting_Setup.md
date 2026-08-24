# Automated Email Cost Reporting Setup Guide
## For Drew Weilbacher — TSG Consumer Partners

This guide walks through setting up automated email reports so you receive Snowflake cost summaries on a schedule without needing to log into Snowflake.

---

## Option A: Scheduled Task + Email Notification (Simplest)

This runs a SQL query on a schedule and emails results.

### Step 1: Create the Cost Summary Query as a Stored Procedure

```sql
CREATE OR REPLACE PROCEDURE TSG_COST_REPORT()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  report_text STRING;
BEGIN
  -- Build the report
  SELECT LISTAGG(
    warehouse_name || ': ' || credits_used::VARCHAR || ' credits ($' || estimated_cost::VARCHAR || ')',
    '\n'
  ) INTO report_text
  FROM (
    SELECT
      warehouse_name,
      ROUND(SUM(credits_used), 2) AS credits_used,
      ROUND(SUM(credits_used) * 3.00, 2) AS estimated_cost  -- adjust rate
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
    GROUP BY warehouse_name
    ORDER BY credits_used DESC
  );

  RETURN report_text;
END;
$$;
```

### Step 2: Set Up Email Integration

```sql
-- Create an email notification integration
CREATE OR REPLACE NOTIFICATION INTEGRATION tsg_cost_email
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('dweilbacher@tsgconsumer.com', 'sheinz@tsgconsumer.com', 'rzhang@tsgconsumer.com');
```

### Step 3: Create the Scheduled Task

```sql
-- Weekly cost report — runs every Monday at 8am PT
CREATE OR REPLACE TASK tsg_weekly_cost_report
  WAREHOUSE = WH_DEAL_SOURCING   -- or whichever warehouse you prefer
  SCHEDULE = 'USING CRON 0 8 * * 1 America/Los_Angeles'
AS
CALL SYSTEM$SEND_EMAIL(
  'tsg_cost_email',
  'dweilbacher@tsgconsumer.com',
  'Weekly Snowflake Cost Report - TSG Consumer Partners',
  (CALL TSG_COST_REPORT()),
  'text/plain'
);

-- Enable the task
ALTER TASK tsg_weekly_cost_report RESUME;
```

### Customize the Schedule

| Schedule | CRON Expression |
|---|---|
| Every Monday 8am PT | `0 8 * * 1 America/Los_Angeles` |
| Daily at 8am PT | `0 8 * * * America/Los_Angeles` |
| First of every month | `0 8 1 * * America/Los_Angeles` |
| Every Friday at 5pm PT | `0 17 * * 5 America/Los_Angeles` |

---

## Option B: Cortex Agent in CoWork (Interactive Dashboard on Login)

No Snowflake login required — just open CoWork in a browser.

### How it works:
1. Navigate to CoWork (Snowflake's agent chat interface)
2. Pre-configured artifacts show cost dashboards automatically on login
3. You can ask natural language questions like:
   - "What's our Snowflake spend this week?"
   - "Which project used the most credits?"
   - "Show me AI token consumption trend"

### Setup:
This is configured through the CoWork admin interface. We can set up:
- Pre-built cost artifacts that display on every login
- A custom agent that knows your warehouse structure and tags
- Natural language access to all cost data

**I (Stephen) can configure this for you — just let me know if you'd prefer this over the email approach, or both.**

---

## Option C: Combined Approach (Recommended)

Best of both worlds:
1. **Weekly email** with a cost summary hits your inbox every Monday (Option A)
2. **CoWork dashboard** available anytime you want to drill deeper (Option B)
3. **Alert emails** triggered only when spend exceeds thresholds (via Resource Monitors — already covered in the Best Practices doc)

---

## What I Need From You to Set This Up

1. **Preferred schedule** — Weekly? Daily? Monthly?
2. **Recipients** — Just Drew, or also Sammy and Richie?
3. **Level of detail** — High-level summary (total spend + top warehouses) or granular (per-project, per-function)?
4. **CoWork access** — Want me to set up CoWork for you as well?

---

*Once you confirm preferences, I can have this running within a day.*

*— Stephen Dickson (stephen.dickson@snowflake.com)*
