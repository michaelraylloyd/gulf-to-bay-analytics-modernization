# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "b5ee0884-d947-49b7-8553-dce07876d43d",
# META       "default_lakehouse_name": "GTB_Sales_Lakehouse",
# META       "default_lakehouse_workspace_id": "ec08f9a7-88d7-41b1-853d-1cc65782b70c",
# META       "known_lakehouses": [
# META         {
# META           "id": "b5ee0884-d947-49b7-8553-dce07876d43d"
# META         }
# META       ]
# META     }
# META   }
# META }

# MARKDOWN ********************

# # Gold Layer — Dimensional Modeling (Star Schema)
# 
# The Gold layer transforms clean Silver data into a dimensional star schema optimized for analytics, BI, and semantic modeling.
# 
# This layer:
# 
# - Builds conformed dimensions (Customer, Product)
# - Builds a clean FactSales table
# - Enforces join integrity
# - Routes join failures into exception tables
# - Uses surrogate keys (optional, enabled here)
# - Uses a deterministic TRUNCATE-based kill-and-fill pattern
# 
# ## Pipeline steps
# 
# 1. Ensure Gold and Gold exception tables exist.
# 2. `TRUNCATE` all Gold and exception tables.
# 3. Load Silver tables.
# 4. Build dimensions with surrogate keys.
# 5. Build FactSales with validated foreign keys.
# 6. Route join failures into exception tables.
# 7. Append clean rows into Gold tables.
# 8. Append exception rows into exception tables.
# 9. Print row counts for validation.

# PARAMETERS CELL ********************

# PARAMETERS
# (Lakehouse Notebooks ignore this, but it keeps the structure consistent.)

# ============================================================
# FABRIC Metadata Diagnostic
# ============================================================

import os

fabric_keys = sorted([k for k in os.environ.keys() if "FABRIC" in k])
print("FABRIC environment variables detected:", fabric_keys)

# ============================================================
# Execution Context (captured at notebook start)
# ============================================================

from datetime import datetime
import uuid

# Unique run identifier for this notebook execution
run_id = str(uuid.uuid4())

# Pipeline → Notebook parameters (Lakehouse Notebooks do NOT receive these)
pipeline_name = spark.conf.get("pipeline_name", "unknown_pipeline")
notebook_name = spark.conf.get("notebook_name", "unknown_notebook")
pipeline_run_id = spark.conf.get("pipeline_run_id", "unknown_run")

# True start time of the notebook
start_time = datetime.utcnow()

print("run_id:", run_id)
print("pipeline_name:", pipeline_name)
print("notebook_name:", notebook_name)
print("pipeline_run_id:", pipeline_run_id)
print("start_time:", start_time)

# ============================================================
# Notebook Start Log
# ============================================================

from pyspark.sql import Row

start_log = Row(
    notebook_run_id = run_id,
    pipeline_run_id = pipeline_run_id,
    notebook_name   = notebook_name,
    status          = "Started",
    start_time      = start_time,
    error_message   = None
)

spark.createDataFrame([start_log]) \
     .write \
     .format("delta") \
     .mode("append") \
     .saveAsTable("fact_notebook_runs")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# Gold Modeling — Star Schema Build (Kill and Fill)
# -------------------------------------------------------------------

from pyspark.sql.functions import col, monotonically_increasing_id

# -------------------------------------------------------------------
# 1. Ensure Gold + exception tables exist
# -------------------------------------------------------------------

spark.sql("""
    CREATE TABLE IF NOT EXISTS dim_customer (
          customer_sk     bigint
        , customer_id     string
        , first_name      string
        , last_name       string
        , address1        string
        , address2        string
        , city            string
        , state_province  string
        , country         string
        , postal_code     string
    ) USING DELTA
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS dim_product (
          product_sk      bigint
        , product_id      string
        , product_name    string
        , product_number  string
        , color           string
        , standard_cost   float
        , list_price      float
        , size            string
        , weight          float
        , category        string
        , subcategory     string
    ) USING DELTA
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS fact_sales (
          sales_sk        bigint
        , order_id        string
        , order_date      string
        , customer_sk     bigint
        , product_sk      bigint
        , quantity        int
        , unit_price      float
        , discount        float
        , line_total      float
    ) USING DELTA
""")

# Exception tables
spark.sql("""
    CREATE TABLE IF NOT EXISTS exceptions_fact_sales (
          order_id        string
        , order_date      string
        , customer_id     string
        , product_id      string
        , quantity        int
        , unit_price      float
        , discount        float
        , line_total      float
        , reason          string
    ) USING DELTA
""")

# -------------------------------------------------------------------
# 2. TRUNCATE Gold + exception tables
# -------------------------------------------------------------------

for tbl in [
    "dim_customer",
    "dim_product",
    "fact_sales",
    "exceptions_fact_sales"
]:
    spark.sql(f"TRUNCATE TABLE {tbl}")

# -------------------------------------------------------------------
# 3. Load Silver
# -------------------------------------------------------------------

silver_customers = spark.table("silver_customers")
silver_products  = spark.table("silver_products")
silver_sales     = spark.table("silver_sales")

# -------------------------------------------------------------------
# 4. Build Dimensions (with surrogate keys)
# -------------------------------------------------------------------

dim_customer_df = (
    silver_customers
        .withColumn("customer_sk", monotonically_increasing_id())
        .select(
            "customer_sk",
            "customer_id",
            "first_name",
            "last_name",
            "address1",
            "address2",
            "city",
            "state_province",
            "country",
            "postal_code"
        )
)

dim_product_df = (
    silver_products
        .withColumn("product_sk", monotonically_increasing_id())
        .select(
            "product_sk",
            "product_id",
            "product_name",
            "product_number",
            "color",
            "standard_cost",
            "list_price",
            "size",
            "weight",
            "category",
            "subcategory"
        )
)

# -------------------------------------------------------------------
# 5. Build FactSales with validated foreign keys
# -------------------------------------------------------------------

# Join to dimensions
fact_joined = (
    silver_sales.alias("s")
        .join(dim_customer_df.alias("c"), col("s.customer_id") == col("c.customer_id"), "left")
        .join(dim_product_df.alias("p"), col("s.product_id") == col("p.product_id"), "left")
)

# Identify join failures
exceptions_fact_sales_df = fact_joined.filter(
    col("c.customer_sk").isNull() | col("p.product_sk").isNull()
).select(
    "s.order_id",
    "s.order_date",
    "s.customer_id",
    "s.product_id",
    "s.quantity",
    "s.unit_price",
    "s.discount",
    "s.line_total",
    (
        col("c.customer_sk").isNull().cast("string")
        .alias("reason")
    )
)

# Keep only successful rows
fact_sales_df = fact_joined.filter(
    col("c.customer_sk").isNotNull() & col("p.product_sk").isNotNull()
).withColumn(
    "sales_sk", monotonically_increasing_id()
).select(
    "sales_sk",
    "s.order_id",
    "s.order_date",
    "c.customer_sk",
    "p.product_sk",
    "s.quantity",
    "s.unit_price",
    "s.discount",
    "s.line_total"
)

# -------------------------------------------------------------------
# 6. Append clean + exception rows
# -------------------------------------------------------------------

dim_customer_df.write.insertInto("dim_customer")
dim_product_df.write.insertInto("dim_product")
fact_sales_df.write.insertInto("fact_sales")
exceptions_fact_sales_df.write.insertInto("exceptions_fact_sales")

# -------------------------------------------------------------------
# 7. Validate counts
# -------------------------------------------------------------------

for tbl in [
    "dim_customer",
    "dim_product",
    "fact_sales",
    "exceptions_fact_sales"
]:
    print(tbl, spark.table(tbl).count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# ============================================================
# Standard Fabric Logging Block (schema-safe)
# ============================================================

from pyspark.sql.types import StructType, StructField, StringType, TimestampType

# Explicit schema for the notebook-level logging table
log_schema = StructType([
    StructField("run_id", StringType(), False),
    StructField("pipeline_name", StringType(), True),
    StructField("notebook_name", StringType(), True),
    StructField("pipeline_run_id", StringType(), True),
    StructField("status", StringType(), True),
    StructField("start_time", TimestampType(), True),
    StructField("end_time", TimestampType(), True),
    StructField("error_message", StringType(), True)
])

try:
    # If all notebook logic above succeeded
    status = "success"
    error_message = None

except Exception as e:
    # If this cell itself throws an exception
    status = "failure"
    error_message = str(e)
    raise

finally:
    # Always capture end time
    end_time = datetime.utcnow()

    log_row = [{
        "run_id": run_id,
        "pipeline_name": pipeline_name,
        "notebook_name": notebook_name,
        "pipeline_run_id": pipeline_run_id,
        "status": status,
        "start_time": start_time,
        "end_time": end_time,
        "error_message": error_message
    }]

    log_df = spark.createDataFrame(log_row, schema=log_schema)

    (
        log_df.write
            .format("delta")
            .mode("append")
            .saveAsTable("fact_notebook_runs")
    )

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
