# Snowflake Cost Data API Integration Guide
## For TSG Consumer Partners — Pulling Cost Data Into Your Monitoring App

This guide covers how to pull Snowflake cost/consumption data into your existing monitoring application (alongside AWS and OpenAI spend) via API.

---

## Option 1: Snowflake REST API (SQL API)

Best for: Apps that can make HTTP calls and parse JSON responses.

### How It Works
Your app sends SQL queries to Snowflake's SQL API endpoint and gets results back as JSON.

### Authentication

```bash
# Generate a JWT or use key-pair authentication
# Base URL: https://<your_account>.snowflakecomputing.com/api/v2/statements
```

### Example: Get Weekly Cost Summary via REST

```bash
curl -X POST \
  'https://<account>.snowflakecomputing.com/api/v2/statements' \
  -H 'Authorization: Bearer <jwt_token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "statement": "SELECT warehouse_name, ROUND(SUM(credits_used), 2) AS credits, ROUND(SUM(credits_used) * 3.00, 2) AS cost_usd FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP()) GROUP BY warehouse_name ORDER BY credits DESC",
    "timeout": 60,
    "warehouse": "WH_DEAL_SOURCING",
    "role": "ACCOUNTADMIN"
  }'
```

### Response Format (JSON)

```json
{
  "data": [
    ["WH_DEAL_SOURCING", 42.5, 127.50],
    ["WH_ML_TRAINING", 28.3, 84.90]
  ],
  "resultSetMetaData": {
    "numRows": 2,
    "format": "jsonv2"
  }
}
```

---

## Option 2: Python Connector (Recommended for Python/Streamlit Apps)

Best for: If your monitoring app is built in Python.

### Install

```bash
pip install snowflake-connector-python
```

### Example: Pull Cost Data

```python
import snowflake.connector
import json

# Connect using key-pair auth (no password needed)
conn = snowflake.connector.connect(
    account='<your_account>',
    user='TSG_API_SERVICE_USER',
    private_key_file='/path/to/rsa_key.p8',
    warehouse='WH_DEAL_SOURCING',
    role='COST_READER'  # custom role with minimal privileges
)

def get_weekly_costs():
    """Returns cost data as a list of dicts for your monitoring app."""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT
            warehouse_name,
            ROUND(SUM(credits_used), 2) AS credits,
            ROUND(SUM(credits_used) * 3.00, 2) AS cost_usd
        FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
        WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
        GROUP BY warehouse_name
        ORDER BY credits DESC
    """)
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]

def get_ai_token_costs():
    """Returns AI/Cortex token spend."""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT
            DATE_TRUNC('day', start_time)::DATE AS usage_date,
            service_type,
            name AS function_name,
            SUM(credits_used) AS credits_consumed
        FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY
        WHERE service_type = 'AI_SERVICES'
          AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
        GROUP BY 1, 2, 3
        ORDER BY usage_date DESC
    """)
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]

# Example: Format for your monitoring app
costs = get_weekly_costs()
ai_costs = get_ai_token_costs()
print(json.dumps({"snowflake_compute": costs, "snowflake_ai": ai_costs}, indent=2))
```

---

## Option 3: JDBC/ODBC Connector

Best for: Java, .NET, or BI tools that support standard database connectors.

### JDBC Connection String

```
jdbc:snowflake://<account>.snowflakecomputing.com/?warehouse=WH_DEAL_SOURCING&role=COST_READER
```

### ODBC DSN Configuration

```ini
[SnowflakeCost]
Driver      = SnowflakeDSIIDriver
Server      = <account>.snowflakecomputing.com
Database    = SNOWFLAKE
Schema      = ACCOUNT_USAGE
Warehouse   = WH_DEAL_SOURCING
Role        = COST_READER
Authenticator = SNOWFLAKE_JWT
```

---

## Option 4: Snowflake Snowpark (for complex transformations)

Best for: When you need to join Snowflake cost data with other data before sending to your app.

```python
from snowflake.snowpark import Session

session = Session.builder.configs({
    "account": "<your_account>",
    "user": "TSG_API_SERVICE_USER",
    "private_key_file": "/path/to/rsa_key.p8",
    "warehouse": "WH_DEAL_SOURCING",
    "role": "COST_READER"
}).create()

# Query and transform
cost_df = session.sql("""
    SELECT
        'snowflake' AS platform,
        'compute' AS cost_category,
        ROUND(SUM(credits_used) * 3.00, 2) AS cost_usd,
        CURRENT_DATE() AS report_date
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
""").to_pandas()

# Now combine with your AWS/OpenAI data in your app
print(cost_df)
```

---

## Security Best Practices for API Access

### Create a Dedicated Service User

```sql
-- Create a role with read-only access to cost data
CREATE ROLE IF NOT EXISTS COST_READER;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE COST_READER;
GRANT USAGE ON WAREHOUSE WH_DEAL_SOURCING TO ROLE COST_READER;

-- Create a service user for the API
CREATE USER IF NOT EXISTS TSG_API_SERVICE_USER
  DEFAULT_ROLE = COST_READER
  DEFAULT_WAREHOUSE = WH_DEAL_SOURCING
  RSA_PUBLIC_KEY = '<your_public_key>';  -- key-pair auth, no password

GRANT ROLE COST_READER TO USER TSG_API_SERVICE_USER;
```

### Generate Key-Pair (one-time setup)

```bash
# Generate private key
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt

# Generate public key
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub

# Set the public key on the service user (in Snowflake)
# ALTER USER TSG_API_SERVICE_USER SET RSA_PUBLIC_KEY='<contents of rsa_key.pub>';
```

---

## Unified Cost Dashboard Data Model

Here's a suggested JSON schema to unify Snowflake + AWS + OpenAI in your monitoring app:

```json
{
  "report_date": "2026-08-24",
  "period": "last_7_days",
  "platforms": {
    "snowflake": {
      "compute_cost_usd": 213.40,
      "storage_cost_usd": 46.00,
      "ai_credits_cost_usd": 31.20,
      "total_usd": 290.60,
      "breakdown": [
        {"category": "deal-sourcing-tool", "cost_usd": 127.50},
        {"category": "ml-models", "cost_usd": 84.90},
        {"category": "ai-services", "cost_usd": 31.20}
      ]
    },
    "aws": { "total_usd": "..." },
    "openai": { "total_usd": "..." }
  }
}
```

---

## Next Steps

1. **Tell me what your monitoring app is built in** — I'll point you to the exact connector and help wire it up
2. **I'll create the service user and role** in your Snowflake account with the right permissions
3. **We can test it end-to-end** in a 30-min working session

---

*— Stephen Dickson (stephen.dickson@snowflake.com)*
