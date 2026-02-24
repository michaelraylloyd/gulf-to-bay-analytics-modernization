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

# # Bronze layer — truncate + exception logging
# 
# The Bronze layer ingests raw CSV files exactly as delivered, preserving source fidelity while capturing malformed rows into exception tables.
# 
# This notebook uses a deterministic **TRUNCATE-based kill-and-fill** pattern:
# 
# - Tables persist permanently
# - Each run clears them with `TRUNCATE TABLE`
# - Clean rows append into Bronze tables
# - Malformed rows append into exception tables
# - Schemas are explicitly defined
# - Exception tables include `_corrupt_record` for traceability
# - Logic is Fabric/Delta–native and transferable to other modern stacks
# 
# ## Pipeline steps
# 
# 1. Define schemas for `customers`, `products`, and `sales`.
# 2. Ensure Bronze and exception tables exist (schema-only, no CTAS).
# 3. `TRUNCATE` all Bronze and exception tables.
# 4. Read CSVs in PERMISSIVE mode with `_corrupt_record`.
# 5. Split clean vs malformed rows per file.
# 6. Append clean rows into Bronze tables.
# 7. Append malformed rows into exception tables.
# 8. Print row counts for quick validation.


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
# Bronze ingestion — kill and fill using TRUNCATE + exception logging
# -------------------------------------------------------------------

from pyspark.sql.types import (
    StructType, StructField, StringType, IntegerType, FloatType
)
from pyspark.sql.functions import col

# -------------------------------------------------------------------
# 1. Schemas
# -------------------------------------------------------------------

customers_schema = StructType([
    StructField("customer_id", StringType(), True),
    StructField("first_name", StringType(), True),
    StructField("last_name", StringType(), True),
    StructField("address1", StringType(), True),
    StructField("address2", StringType(), True),
    StructField("city", StringType(), True),
    StructField("state_province", StringType(), True),
    StructField("country", StringType(), True),
    StructField("postal_code", StringType(), True)
])

products_schema = StructType([
    StructField("product_id", StringType(), True),
    StructField("product_name", StringType(), True),
    StructField("product_number", StringType(), True),
    StructField("color", StringType(), True),
    StructField("standard_cost", FloatType(), True),
    StructField("list_price", FloatType(), True),
    StructField("size", StringType(), True),
    StructField("weight", FloatType(), True),
    StructField("category", StringType(), True),
    StructField("subcategory", StringType(), True)
])

sales_schema = StructType([
    StructField("order_id", StringType(), True),
    StructField("order_date", StringType(), True),
    StructField("customer_id", StringType(), True),
    StructField("product_id", StringType(), True),
    StructField("quantity", IntegerType(), True),
    StructField("unit_price", FloatType(), True),
    StructField("discount", FloatType(), True),
    StructField("line_total", FloatType(), True)
])

# -------------------------------------------------------------------
# 2. Create Bronze + exception tables IF NOT EXISTS (schema only)
# -------------------------------------------------------------------

spark.sql("""
    CREATE TABLE IF NOT EXISTS bronze_customers (
          customer_id      string
        , first_name       string
        , last_name        string
        , address1         string
        , address2         string
        , city             string
        , state_province   string
        , country          string
        , postal_code      string
    ) USING DELTA
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS bronze_products (
          product_id     string
        , product_name   string
        , product_number string
        , color          string
        , standard_cost  float
        , list_price     float
        , size           string
        , weight         float
        , category       string
        , subcategory    string
    ) USING DELTA
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS bronze_sales (
          order_id     string
        , order_date   string
        , customer_id  string
        , product_id   string
        , quantity     int
        , unit_price   float
        , discount     float
        , line_total   float
    ) USING DELTA
""")

# exception tables (include _corrupt_record)
spark.sql("""
    CREATE TABLE IF NOT EXISTS exceptions_customers (
          customer_id      string
        , first_name       string
        , last_name        string
        , address1         string
        , address2         string
        , city             string
        , state_province   string
        , country          string
        , postal_code      string
        , _corrupt_record  string
    ) USING DELTA
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS exceptions_products (
          product_id       string
        , product_name     string
        , product_number   string
        , color            string
        , standard_cost    float
        , list_price       float
        , size             string
        , weight           float
        , category         string
        , subcategory      string
        , _corrupt_record  string
    ) USING DELTA
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS exceptions_sales (
          order_id         string
        , order_date       string
        , customer_id      string
        , product_id       string
        , quantity         int
        , unit_price       float
        , discount         float
        , line_total       float
        , _corrupt_record  string
    ) USING DELTA
""")

# -------------------------------------------------------------------
# 3. TRUNCATE all Bronze + exception tables
# -------------------------------------------------------------------

for tbl in [
    "bronze_customers", "exceptions_customers",
    "bronze_products", "exceptions_products",
    "bronze_sales", "exceptions_sales"
]:
    spark.sql(f"TRUNCATE TABLE {tbl}")

# -------------------------------------------------------------------
# 4. Read CSVs with permissive mode and split clean vs exceptions
# -------------------------------------------------------------------

def read_with_exceptions(path, schema):
    df = (
        spark.read
             .schema(schema)
             .option("header", True)
             .option("mode", "PERMISSIVE")
             .option("columnNameOfCorruptRecord", "_corrupt_record")
             .csv(path)
    )

    # CASE A — _corrupt_record exists
    if "_corrupt_record" in df.columns:
        clean = df.filter(col("_corrupt_record").isNull()).drop("_corrupt_record")

        exception_schema = schema.add("_corrupt_record", StringType())
        exceptions = (
            df.filter(col("_corrupt_record").isNotNull())
              .select([col(c) for c in exception_schema.fieldNames()])
        )

    # CASE B — no _corrupt_record column (file fully clean)
    else:
        clean = df
        exception_schema = schema.add("_corrupt_record", StringType())
        exceptions = spark.createDataFrame([], exception_schema)

    return clean, exceptions

customers_df, exceptions_customers_df = read_with_exceptions("Files/customers.csv", customers_schema)
products_df, exceptions_products_df   = read_with_exceptions("Files/products.csv", products_schema)
sales_df, exceptions_sales_df         = read_with_exceptions("Files/sales.csv", sales_schema)

# -------------------------------------------------------------------
# 5. Append clean + exception rows
# -------------------------------------------------------------------

customers_df.write.insertInto("bronze_customers")
products_df.write.insertInto("bronze_products")
sales_df.write.insertInto("bronze_sales")

exceptions_customers_df.write.insertInto("exceptions_customers")
exceptions_products_df.write.insertInto("exceptions_products")
exceptions_sales_df.write.insertInto("exceptions_sales")

# -------------------------------------------------------------------
# 6. Validate counts
# -------------------------------------------------------------------

for tbl in [
    "bronze_customers", "exceptions_customers",
    "bronze_products", "exceptions_products",
    "bronze_sales", "exceptions_sales"
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
