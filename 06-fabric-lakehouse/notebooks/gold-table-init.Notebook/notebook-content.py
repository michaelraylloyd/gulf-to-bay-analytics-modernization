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

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 1 — GOLD TABLE SCHEMA METADATA
# -------------------------------------------------------------------
# Single source of truth for all Gold-layer table definitions.
# Each key is a table name, and each value is an ordered mapping
# of column names to Spark SQL data types.
# -------------------------------------------------------------------

tables = {
    "dim_product": {
        "product_sk": "bigint",
        "product_id": "string",
        "product_name": "string",
        "product_number": "string",
        "color": "string",
        "standard_cost": "float",
        "list_price": "float",
        "size": "string",
        "weight": "float",
        "category": "string",
        "subcategory": "string"
    },
    "fact_sales": {
        "sales_sk": "bigint",
        "order_id": "string",
        "order_date": "string",
        "customer_sk": "bigint",
        "product_sk": "bigint",
        "quantity": "int",
        "unit_price": "float",
        "discount": "float",
        "line_total": "float"
    },
    "exceptions_fact_sales": {
        "order_id": "string",
        "order_date": "string",
        "customer_id": "string",
        "product_id": "string",
        "quantity": "int",
        "unit_price": "float",
        "discount": "float",
        "line_total": "float",
        "reason": "string"
    }
}

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 2 — GOLD TABLE GENERATOR (DROP + CREATE)
# -------------------------------------------------------------------
# Kill-and-fill pattern:
# - DROP TABLE IF EXISTS <table>
# - CREATE TABLE <table> (...) from metadata
# Guarantees deterministic schema and wipes drift.
# -------------------------------------------------------------------

for table_name, columns in tables.items():

    # Drop existing table if present
    spark.sql(f"DROP TABLE IF EXISTS {table_name}")

    # Build column definitions from metadata
    col_defs = ",\n    ".join([f"{col} {dtype}" for col, dtype in columns.items()])

    # Create the table using Spark SQL types
    spark.sql(f"""
        CREATE TABLE {table_name} (
            {col_defs}
        )
    """)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 3 — CONFIRMATION OUTPUT
# -------------------------------------------------------------------
# Simple console confirmation for notebook and pipeline runs.
# -------------------------------------------------------------------

for table_name in tables.keys():
    print(f"[INIT] Created table: {table_name}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 4 — MAINTENANCE (OPTIONAL OPTIMIZE + ZORDER)
# -------------------------------------------------------------------
# Lightweight performance maintenance for Gold tables.
# - OPTIMIZE compacts small files.
# - ZORDER improves data skipping on common filter columns.
#
# NOTE:
# - Adjust ZORDER columns per table as needed.
# - Safe to no-op if OPTIMIZE/ZORDER not supported in environment.
# -------------------------------------------------------------------

zorder_columns = {
    "dim_product": ["product_id", "category"],
    "fact_sales": ["order_date", "customer_sk", "product_sk"],
    "exceptions_fact_sales": ["order_date", "customer_id", "product_id"]
}

for table_name in tables.keys():
    try:
        # Basic OPTIMIZE
        spark.sql(f"OPTIMIZE {table_name}")

        # Optional ZORDER if configured
        if table_name in zorder_columns and zorder_columns[table_name]:
            cols = ", ".join(zorder_columns[table_name])
            spark.sql(f"OPTIMIZE {table_name} ZORDER BY ({cols})")

        print(f"[MAINT] Optimized table: {table_name}")

    except Exception as e:
        # Non-fatal: log and continue
        print(f"[MAINT][WARN] Maintenance skipped for {table_name}: {e}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 5 — SCHEMA VALIDATION
# -------------------------------------------------------------------
# Validates that the physical table schema matches the metadata:
# - Same columns
# - Same data types (case-insensitive)
# - Same column order
#
# Any mismatch is printed as a warning. You can choose to:
# - raise an Exception to fail the pipeline, or
# - log and continue.
# -------------------------------------------------------------------

from pyspark.sql.types import StructType

def get_table_schema(table_name: str) -> StructType:
    return spark.table(table_name).schema

def normalize_dtype(dtype_str: str) -> str:
    return dtype_str.strip().lower()

validation_errors = []

for table_name, columns in tables.items():
    try:
        schema = get_table_schema(table_name)
        physical_cols = [(f.name, normalize_dtype(f.dataType.simpleString())) for f in schema]
        expected_cols = [(col, normalize_dtype(dtype)) for col, dtype in columns.items()]

        if physical_cols != expected_cols:
            validation_errors.append((table_name, physical_cols, expected_cols))
            print(f"[VALIDATION][ERROR] Schema mismatch for {table_name}")
        else:
            print(f"[VALIDATION] Schema OK for {table_name}")

    except Exception as e:
        validation_errors.append((table_name, str(e), None))
        print(f"[VALIDATION][ERROR] Could not validate {table_name}: {e}")

# Optional: fail hard if any validation errors
if validation_errors:
    print("[VALIDATION][SUMMARY] One or more tables failed schema validation.")
    # Uncomment to fail the notebook/pipeline:
    # raise Exception("Gold table schema validation failed. See logs above.")
else:
    print("[VALIDATION][SUMMARY] All Gold tables passed schema validation.")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# -------------------------------------------------------------------
# BLOCK 6 — LOGGING (GOLD INIT LOG TABLE)
# -------------------------------------------------------------------
# Writes a simple log entry to a Gold log table:
# - run_timestamp
# - status
# - table_count
# - validation_error_count
#
# This can be extended later with:
# - pipeline_run_id
# - user
# - environment
# -------------------------------------------------------------------

from datetime import datetime

log_table = "gold_pipeline_log"

# Ensure log table exists (idempotent)
spark.sql(f"""
    CREATE TABLE IF NOT EXISTS {log_table} (
        run_timestamp string,
        process       string,
        status        string,
        table_count   int,
        validation_error_count int
    )
""")

run_timestamp = datetime.utcnow().isoformat()
process_name = "gold_table_init"
status = "SUCCESS" if not validation_errors else "FAILED"
table_count = len(tables)
validation_error_count = len(validation_errors)

log_df = spark.createDataFrame(
    [
        (run_timestamp, process_name, status, table_count, validation_error_count)
    ],
    ["run_timestamp", "process", "status", "table_count", "validation_error_count"]
)

log_df.write.mode("append").insertInto(log_table)

print(f"[LOG] Wrote Gold init log entry: status={status}, tables={table_count}, validation_errors={validation_error_count}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# ============================================================
# Standard Fabric Logging Block (schema-safe)
# ============================================================

from datetime import datetime
import uuid
from pyspark.sql import Row
from pyspark.sql.types import StructType, StructField, StringType, TimestampType

# Capture metadata
run_id = str(uuid.uuid4())
pipeline_name = spark.conf.get("pipeline.name", "unknown_pipeline")
notebook_name = spark.conf.get("notebook.name", "unknown_notebook")
start_time = datetime.utcnow()

# Define schema explicitly (critical!)
log_schema = StructType([
    StructField("run_id", StringType(), False),
    StructField("pipeline_name", StringType(), True),
    StructField("notebook_name", StringType(), True),
    StructField("status", StringType(), True),
    StructField("start_time", TimestampType(), True),
    StructField("end_time", TimestampType(), True),
    StructField("error_message", StringType(), True)
])

try:
    # --------------------------------------------------------
    # PLACE YOUR NOTEBOOK LOGIC ABOVE THIS BLOCK
    # --------------------------------------------------------
    pass  # remove this once your notebook logic is above

    status = "success"
    error_message = None

except Exception as e:
    status = "failure"
    error_message = str(e)
    raise

finally:
    end_time = datetime.utcnow()

    log_row = [{
        "run_id": run_id,
        "pipeline_name": pipeline_name,
        "notebook_name": notebook_name,
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
            .saveAsTable("fabric_pipeline_logs")
    )

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
