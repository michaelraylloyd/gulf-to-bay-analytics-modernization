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

# # Silver Layer — Standardization and Type Enforcement
# 
# The Silver layer refines raw Bronze data into clean, typed, and analytics‑ready tables. It applies deterministic cleanup, enforces schema fidelity, and surfaces data quality issues without breaking the pipeline.
# 
# This layer:
# 
# - Trims and normalizes all string fields  
# - Enforces numeric types using a safe, lineage‑stable cast helper  
# - Routes failed casts into Silver exception tables  
# - Preserves row‑level fidelity for debugging and junior‑friendly querying  
# 
# A **TRUNCATE‑based kill‑and‑fill pattern** ensures deterministic, repeatable runs:
# 
# - Silver and exception tables persist permanently  
# - Each run clears them with `TRUNCATE TABLE`  
# - Clean rows append into Silver tables  
# - Failed casts append into exception tables  
# 
# ## Pipeline steps
# 
# 1. Ensure Silver and Silver exception tables exist (schema derived from Bronze).  
# 2. `TRUNCATE` all Silver and exception tables.  
# 3. Load Bronze tables.  
# 4. Trim and normalize all string columns.  
# 5. Enforce numeric types using a safe cast helper.  
# 6. Route failed casts into exception tables.  
# 7. Append clean rows into Silver tables.  
# 8. Append exception rows into exception tables.  
# 9. Print row counts for quick validation.


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
# Silver Transformations — Kill and Fill Using TRUNCATE
# -------------------------------------------------------------------

from pyspark.sql.functions import col, trim
from pyspark.sql.types import IntegerType, FloatType

# -------------------------------------------------------------------
# 1. Ensure Silver + exception tables exist (schema from Bronze)
# -------------------------------------------------------------------

spark.sql("""
    CREATE TABLE IF NOT EXISTS silver_customers
    USING DELTA AS
    SELECT * FROM bronze_customers WHERE 1 = 0
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS silver_products
    USING DELTA AS
    SELECT * FROM bronze_products WHERE 1 = 0
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS silver_sales
    USING DELTA AS
    SELECT * FROM bronze_sales WHERE 1 = 0
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS exceptions_silver_customers
    USING DELTA AS
    SELECT * FROM silver_customers WHERE 1 = 0
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS exceptions_silver_products
    USING DELTA AS
    SELECT * FROM silver_products WHERE 1 = 0
""")

spark.sql("""
    CREATE TABLE IF NOT EXISTS exceptions_silver_sales
    USING DELTA AS
    SELECT * FROM silver_sales WHERE 1 = 0
""")

# -------------------------------------------------------------------
# 2. TRUNCATE Silver + exception tables
# -------------------------------------------------------------------

for tbl in [
    "silver_customers", "exceptions_silver_customers",
    "silver_products",  "exceptions_silver_products",
    "silver_sales",     "exceptions_silver_sales"
]:
    spark.sql(f"TRUNCATE TABLE {tbl}")

# -------------------------------------------------------------------
# 3. Load Bronze
# -------------------------------------------------------------------

bronze_customers = spark.table("bronze_customers")
bronze_products  = spark.table("bronze_products")
bronze_sales     = spark.table("bronze_sales")

# -------------------------------------------------------------------
# 4. Helpers
# -------------------------------------------------------------------

def clean_strings(df):
    for c, t in df.dtypes:
        if t == "string":
            df = df.withColumn(c, trim(col(c)))
    return df


def enforce_numeric(df, colname, dtype):
    """
    Casts a column to a numeric type using a temporary column to avoid
    Spark analyzer lineage collisions.
    Returns:
      cleaned_df  - with column cast to dtype
      exceptions  - rows where cast failed (same schema as df)
    """

    # 1. Cast into a temporary column
    temp_col = f"{colname}__cast"
    df2 = df.withColumn(temp_col, col(colname).cast(dtype))

    # 2. Identify failed casts
    failed = df2.filter(
        col(colname).isNotNull() & col(temp_col).isNull()
    ).select(df.columns)

    # 3. Keep only successful rows
    cleaned = df2.filter(
        col(temp_col).isNotNull() | col(colname).isNull()
    ).drop(temp_col)

    # 4. Replace original column with casted version
    cleaned = cleaned.withColumn(colname, col(colname).cast(dtype))

    return cleaned, failed

# -------------------------------------------------------------------
# 5. Clean customers — trim only
# -------------------------------------------------------------------

silver_customers_df = clean_strings(bronze_customers)
exceptions_silver_customers_df = spark.createDataFrame([], silver_customers_df.schema)

# -------------------------------------------------------------------
# 6. Clean products — trim + enforce numeric
# -------------------------------------------------------------------

products = clean_strings(bronze_products)

products, ex_p1 = enforce_numeric(products, "standard_cost", FloatType())
products, ex_p2 = enforce_numeric(products, "list_price",   FloatType())
products, ex_p3 = enforce_numeric(products, "weight",       FloatType())

silver_products_df = products
exceptions_silver_products_df = ex_p1.unionByName(ex_p2).unionByName(ex_p3)

# -------------------------------------------------------------------
# 7. Clean sales — trim + enforce numeric
# -------------------------------------------------------------------

sales = clean_strings(bronze_sales)

sales, ex_s1 = enforce_numeric(sales, "quantity",   IntegerType())
sales, ex_s2 = enforce_numeric(sales, "unit_price", FloatType())
sales, ex_s3 = enforce_numeric(sales, "discount",   FloatType())
sales, ex_s4 = enforce_numeric(sales, "line_total", FloatType())

silver_sales_df = sales
exceptions_silver_sales_df = (
    ex_s1.unionByName(ex_s2)
         .unionByName(ex_s3)
         .unionByName(ex_s4)
)

# -------------------------------------------------------------------
# 8. Append clean + exception rows
# -------------------------------------------------------------------

silver_customers_df.write.insertInto("silver_customers")
silver_products_df.write.insertInto("silver_products")
silver_sales_df.write.insertInto("silver_sales")

exceptions_silver_customers_df.write.insertInto("exceptions_silver_customers")
exceptions_silver_products_df.write.insertInto("exceptions_silver_products")
exceptions_silver_sales_df.write.insertInto("exceptions_silver_sales")

# -------------------------------------------------------------------
# 9. Validate counts
# -------------------------------------------------------------------

for tbl in [
    "silver_customers", "exceptions_silver_customers",
    "silver_products",  "exceptions_silver_products",
    "silver_sales",     "exceptions_silver_sales"
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
