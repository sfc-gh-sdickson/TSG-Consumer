# Snowflake Intelligence Agent Project Template

## Purpose
TSG Consumer Partners invests in brands you know and love, because we love them too. Our flexible approach allows us to make minority or majority investments in established companies looking to grow beyond their previous successes.

## Customer details
Brand Building
For 40 years, we’ve been a trusted partner in building brands people love. As the first private equity fund to focus exclusively on the consumer sector, we have a proven track record in partnering with founders and management teams to grow great ideas into household names.

Consumer Insights
To understand current and future customers, we conduct market and consumer research to help our partner companies make informed decisions on product development, marketing performance, distribution strategies, and more.

Product Innovation
At the core of every brand is product, and with our partnership our brands have innovated new products, expanded hero franchises, developed profitable private labels, innovated in their categories, and launched into new ones.

Digital Strategy
Our unique competencies are unparalleled in digital strategy and eCommerce. Our in-house team and network of advisors from blue-chip firms such as Amazon, Google, and Facebook, help partner companies increase digital fluency and expand their digital footprints.

Channel Strategy
From finding more profitable retail partners to launching eCommerce platforms to expanding global distribution, we work with our partner companies to optimize and maximize their existing channels as well as break into new ones.   

Operations
Allowing our companies to focus on building world-class products and services, we consult on aspects of internal process and operations management that help the business scale sustainably. Our team has experience in supply chain, financial reporting, project management, and more.

---

## Customer Configuration

**To create a new project, replace these variables throughout:**

| Variable | Description | Example (GoDaddy) |
|----------|-------------|-------------------|
| `{CUSTOMER_NAME}` | Customer name | TSG |
| `{CUSTOMER_SUBSIDIARY}` | Subsidiary name | TSG Consumer
| `{CUSTOMER_NAME_UPPER}` | Uppercase for SQL objects | TSG |
| `{DATABASE_NAME}` | Main database name | TSG_INTELLIGENCE |
| `{WAREHOUSE_NAME}` | Warehouse name | TSG_WH |
| `{AGENT_NAME}` | Agent identifier | TSG_AGENT |
| `{BUSINESS_DOMAIN}` | Customer's business focus | Consumer Brand Building |
| `{WEB_PRESENCE}`  | Web Address | https://www.tsgconsumer.com/

---

## Project Instructions

```Build a complete Snowflake Intelligence architecture and implementation plan for the TSG Consumer.

The proposed architecture is a modern, streaming-first Scalable ELT Pipeline designed for near real-time data availability, scalability, and maintainability.

(Note: All project images should be SVG graphics)
 This Project should encompass all aspects of the details identified on their website.

## Agent Project Structure

```
/
├── README.md                           # Project overview and setup instructions
├── docs/
│   ├── AGENT_SETUP.md                 # Step-by-step agent configuration guide
│   ├── DEPLOYMENT_SUMMARY.md          # Current deployment status
│   ├── questions.md                   # 30+ complex test questions
│   └── images/
│       ├── architecture.svg           # System architecture diagram
│       ├── deployment_flow.svg        # Deployment workflow diagram
│       └── ml_models.svg              # ML pipeline visualization
├── notebooks/
│   └── 07_ml_models.ipynb      # ML model training (optional)
└── sql/
    ├── setup/
    │   ├── 01_database_and_schema.sql # Database, schemas, warehouse
    │   └── 02_create_tables.sql       # All table definitions
    ├── data/
    │   └── 03_generate_synthetic_data.sql # Test data generation
    ├── views/
    │   ├── 04_create_views.sql        # Analytical views
    │   └── 05_create_semantic_views.sql # Semantic views for Cortex Analyst
    ├── search/
    │   └── 06_create_cortex_search.sql # Cortex Search services
    ├── models/
    │   └── 08_ml_model_functions.sql  # ML prediction views and agent functions
    └── agent/
        └── 09_create_financial_agent.sql # Agent creation script
```

---

## File Execution Order

**MUST be executed in this exact order:**

These are examples of what is required.  You may need to add more project defined project.  The documentation should have an SVG image showing the project flow.

1. `sql/setup/01_database_and_schema.sql`
2. `sql/setup/02_create_tables.sql`
3. `sql/data/03_generate_synthetic_data.sql`
4. `sql/views/04_create_views.sql`
5. `sql/views/05_create_semantic_views.sql`
6. `sql/search/06_create_cortex_search.sql`
7. `notebooks/07_ml_financial_models.ipynb`
8. `sql/models/08_ml_model_functions.sql`
9. `sql/agent/09_create_financial_agent.sql`

---

## Critical Syntax Reference

### Snowflake Agent YAML Specification (VERIFIED WORKING)

```yaml
CREATE OR REPLACE AGENT {AGENT_NAME}
  COMMENT = '{Customer} intelligence agent'
  PROFILE = '{"display_name": "{Customer} Assistant", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    response: "Response instructions..."
    orchestration: "Tool routing instructions..."
    system: "System role description..."
    sample_questions:
      - question: "Sample question?"
        answer: "How the agent should respond."

  tools:
    # Cortex Analyst (text-to-SQL)
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ToolName"
        description: "Description of what this tool does"

    # Cortex Search
    - tool_spec:
        type: "cortex_search"
        name: "SearchName"
        description: "Description of search capability"

    # Custom Function (generic)
    - tool_spec:
        type: "generic"
        name: "FunctionName"
        description: "Description of function output"

  tool_resources:
    # Cortex Analyst resource
    ToolName:
      semantic_view: "{DATABASE}.{SCHEMA}.{SEMANTIC_VIEW_NAME}"

    # Cortex Search resource
    SearchName:
      name: "{DATABASE}.{SCHEMA}.{SEARCH_SERVICE_NAME}"
      max_results: "10"
      title_column: "column_name"
      id_column: "id_column"

    # Custom Function resource
    FunctionName:
      type: "function"
      identifier: "{DATABASE}.{SCHEMA}.{FUNCTION_NAME}"
      execution_environment:
        type: "warehouse"
        warehouse: "{WAREHOUSE_NAME}"
  $$;
```

### SQL UDF Return Types (VERIFIED)

| Function Returns | Correct Return Type |
|------------------|---------------------|
| `ARRAY_AGG(...)` | `RETURNS ARRAY` |
| `OBJECT_CONSTRUCT(...)` | `RETURNS OBJECT` |
| Single scalar value | `RETURNS VARCHAR/NUMBER/etc` |

**DO NOT USE:**
- `RETURNS VARIANT` for `ARRAY_AGG` or `OBJECT_CONSTRUCT`
- `LANGUAGE SQL` clause in SQL UDFs

### SQL UDF Syntax (VERIFIED)

```sql
-- Correct syntax for scalar UDF returning ARRAY
CREATE OR REPLACE FUNCTION AGENT_GET_DATA()
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'key1', COLUMN1,
    'key2', COLUMN2
)) FROM (SELECT * FROM TABLE LIMIT 50)
$$;

-- Correct syntax for scalar UDF returning OBJECT
CREATE OR REPLACE FUNCTION AGENT_GET_SUMMARY()
RETURNS OBJECT
AS
$$
SELECT OBJECT_CONSTRUCT(
    'metric1', (SELECT COUNT(*) FROM TABLE1),
    'metric2', (SELECT AVG(COLUMN) FROM TABLE2)
)
$$;
```

---

## Lessons Learned (CRITICAL)

### 1. ALWAYS VERIFY SNOWFLAKE SYNTAX BEFORE WRITING CODE

**What went wrong:** Multiple syntax errors because I guessed at syntax instead of verifying against Snowflake documentation.

**Correct approach:**
- Use `snowflake_product_docs` tool to look up syntax BEFORE writing any SQL
- Use `system_instructions` tool for Cortex Agent, Analyst, and other Snowflake products
- Reference working examples (like Troon Intelligence Agent)

**Specific errors made:**
- Used `RETURNS VARIANT` instead of `RETURNS ARRAY` for `ARRAY_AGG`
- Used `RETURNS VARIANT` instead of `RETURNS OBJECT` for `OBJECT_CONSTRUCT`
- Used `LANGUAGE SQL` clause which is invalid for SQL UDFs
- Used `type: "procedure"` instead of `type: "function"` for agent tools
- Used `search_service:` instead of `name:` for Cortex Search resources
- Used JSON format instead of YAML for agent specification

### 2. COMPLETE ALL FILES BEFORE STOPPING

**What went wrong:** Generated partial files and stopped without completing the project, leaving merge conflicts and incomplete code.

**Correct approach:**
- Review ALL files in the project at the start
- Create a TODO list for every file that needs to be created/modified
- Do not mark a task complete until the file is verified to compile/run
- Verify file completeness before moving to the next task

### 3. NEVER GUESS - ASK OR RESEARCH

**What went wrong:** Made assumptions about:
- Agent YAML syntax
- SQL UDF return types
- Function naming conventions
- Tool resource configuration

**Correct approach:**
- If unsure about syntax, use documentation tools first
- If documentation is unclear, ask the user for clarification
- Reference working examples from similar projects
- Test small pieces of code before combining them

### 4. ASK QUESTIONS WHEN UNCLEAR

**What went wrong:** Proceeded with assumptions instead of asking for clarification on requirements.

**Questions to ask upfront:**
- What business domain/industry is this for?
- What specific ML models or predictions are needed?
- What data sources exist or need to be created?
- What sample questions should the agent answer?
- Are there any existing working examples to reference?

### 5. VERIFY GIT MERGE CONFLICTS

**What went wrong:** Left merge conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) in SQL files.

**Correct approach:**
- After any file operations, verify no merge conflicts exist
- Search for conflict markers before marking files complete
- Test SQL files compile before considering them done

---

## Component Templates

### Database Setup (01_database_and_schema.sql)

```sql
CREATE DATABASE IF NOT EXISTS {DATABASE_NAME};
USE DATABASE {DATABASE_NAME};

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

CREATE OR REPLACE WAREHOUSE {WAREHOUSE_NAME} WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for {CUSTOMER_NAME} Intelligence Agent';

USE WAREHOUSE {WAREHOUSE_NAME};
```

### Cortex Search Service

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE {SEARCH_SERVICE_NAME}
  ON {text_column}
  ATTRIBUTES {attr1}, {attr2}, {attr3}
  WAREHOUSE = {WAREHOUSE_NAME}
  TARGET_LAG = '1 hour'
  COMMENT = 'Description of search service'
AS
  SELECT
    {columns}
  FROM {TABLE};
```

### Semantic View

```sql
CREATE OR REPLACE SEMANTIC VIEW {SEMANTIC_VIEW_NAME}
  COMMENT = 'Semantic view description'
AS
  SELECT
    {table}.{column} AS {alias}
      WITH SYNONYMS ('{synonym1}', '{synonym2}')
      COMMENT = '{Column description}',
    ...
  FROM {database}.{schema}.{table}
  ...;
```

---

## Checklist for New Projects

### Before Starting
- [ ] Confirm customer name and business domain
- [ ] Identify data sources (existing tables or need synthetic data)
- [ ] Determine ML models needed (LTV, churn, risk, etc.)
- [ ] Collect sample questions the agent should answer
- [ ] Get working example project for reference

### During Development
- [ ] Verify ALL SQL syntax against Snowflake docs before writing
- [ ] Test each SQL file compiles before moving to next
- [ ] Check for merge conflicts after any file operations
- [ ] Complete TODO list for every component

### Before Delivery
- [ ] Run all SQL files in order (01-08)
- [ ] Test agent creation succeeds
- [ ] Verify agent responds to sample questions
- [ ] Update documentation with customer-specific details
- [ ] Remove any placeholder values

---

## Reference Links

- Snowflake Agent Docs: `snowflake_product_docs` → "Cortex Agent"
- SQL UDF Reference: `snowflake_product_docs` → "CREATE FUNCTION SQL"
- Cortex Search: `snowflake_product_docs` → "CREATE CORTEX SEARCH SERVICE"
- Semantic Views: `snowflake_product_docs` → "CREATE SEMANTIC VIEW"

---

## Version History

- **v1.0** - Initial template based on previous Intelligence Agent project
- **Created:** March 2026
- **Lessons Learned:** Documented from previous project issues

---

## DO NOT:
1. Guess at syntax - VERIFY FIRST
2. Use `RETURNS VARIANT` for `ARRAY_AGG` or `OBJECT_CONSTRUCT`
3. Use `LANGUAGE SQL` in SQL UDFs
4. Use JSON format for Agent specification (use YAML)
5. Leave merge conflicts in files
6. Mark tasks complete before verifying they work
7. Assume you know Snowflake syntax without checking
8. Use text based graphics

## DO:
1. Use `snowflake_product_docs` before writing SQL
2. Use `system_instructions` for Cortex products
3. Reference working examples
4. Ask questions when requirements are unclear
5. Test each file compiles before moving on
6. Complete ALL files before stopping
7. Verify no merge conflicts exist
8. Always generate documentation
9. Always generate SVG images for the documentation.
10. Always generate all files and never placeholders
11. Always put this line of code at the top of all documentation: <img src="Snowflake_Logo.svg" width="200">
