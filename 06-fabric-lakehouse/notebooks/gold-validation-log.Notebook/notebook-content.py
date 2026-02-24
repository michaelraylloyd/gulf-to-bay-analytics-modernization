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
# BLOCK 1 — IMPORTS + SETUP
# -------------------------------------------------------------------
from datetime import datetime

# Tables to validate
gold_tables = [
    "dim_product",
    "fact_sales",
    "exceptions_fact_sales"
]

log_table = "gold_pipeline_log"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 2 — ROW COUNT VALIDATION
# -------------------------------------------------------------------
# Collect row counts for each Gold table.
# This is the primary daily validation step.
# -------------------------------------------------------------------

row_counts = {}

for table in gold_tables:
    try:
        df = spark.table(table)
        count = df.count()
        row_counts[table] = count
        print(f"[ROWCOUNT] {table}: {count}")
    except Exception as e:
        row_counts[table] = None
        print(f"[ROWCOUNT][ERROR] Could not read {table}: {e}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 3 — EXCEPTION COUNT VALIDATION
# -------------------------------------------------------------------
# Exceptions table is expected to exist and contain only rows that
# failed business rules in the Gold modeling notebook.
# -------------------------------------------------------------------

exception_table = "exceptions_fact_sales"

try:
    exception_count = spark.table(exception_table).count()
    print(f"[EXCEPTIONS] {exception_table}: {exception_count}")
except Exception as e:
    exception_count = None
    print(f"[EXCEPTIONS][ERROR] Could not read {exception_table}: {e}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 4 — SCHEMA SANITY CHECK (OPTIONAL)
# -------------------------------------------------------------------
# Ensures each table has at least one column and is readable.
# This is intentionally lightweight for daily pipeline runs.
# -------------------------------------------------------------------

schema_issues = []

for table in gold_tables:
    try:
        schema = spark.table(table).schema
        if len(schema) == 0:
            schema_issues.append((table, "Empty schema"))
            print(f"[SCHEMA][ERROR] {table} has an empty schema.")
        else:
            print(f"[SCHEMA] {table} schema OK ({len(schema)} columns)")
    except Exception as e:
        schema_issues.append((table, str(e)))
        print(f"[SCHEMA][ERROR] Could not read schema for {table}: {e}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 5 — BUILD VALIDATION SUMMARY
# -------------------------------------------------------------------
# Determines overall status for the pipeline log.
# -------------------------------------------------------------------

status = "SUCCESS"

# If any table failed to load or had no row count
if any(v is None for v in row_counts.values()):
    status = "FAILED"

# If schema issues were detected
if len(schema_issues) > 0:
    status = "FAILED"

# If exception count is None, fail
if exception_count is None:
    status = "FAILED"

print(f"[SUMMARY] Pipeline validation status: {status}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 6 — WRITE LOG ENTRY
# -------------------------------------------------------------------
# Writes a structured log entry to the Gold log table.
# -------------------------------------------------------------------

# Ensure log table exists
spark.sql(f"""
    CREATE TABLE IF NOT EXISTS {log_table} (
        run_timestamp string,
        process       string,
        status        string,
        table_count   int,
        exception_count int,
        schema_issue_count int
    )
""")

run_timestamp = datetime.utcnow().isoformat()
process_name = "gold_validation_log"
table_count = len(gold_tables)
schema_issue_count = len(schema_issues)

log_df = spark.createDataFrame(
    [
        (
            run_timestamp,
            process_name,
            status,
            table_count,
            exception_count,
            schema_issue_count
        )
    ],
    [
        "run_timestamp",
        "process",
        "status",
        "table_count",
        "exception_count",
        "schema_issue_count"
    ]
)

log_df.write.mode("append").insertInto(log_table)

print(f"[LOG] Wrote validation log entry: status={status}, exceptions={exception_count}, schema_issues={schema_issue_count}")

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
