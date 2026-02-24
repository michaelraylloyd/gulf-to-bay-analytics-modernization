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

# # US Census — Florida County Population Ingestion
# 
# This notebook demonstrates how to ingest data from the U.S. Census Data API using an API key, normalize the JSON response, and persist the results as a tabular dataset.
# 
# **Dataset:** 2020 Population Estimates Program (PEP) — total population by county  
# **Geography:** All counties in Florida (state FIPS = 12)  
# **API:** `https://api.census.gov/data/2020/pep/population`
# 
# The workflow:
# 
# 1. Configure the Census API endpoint, query parameters, and API key.
# 2. Call the API and retrieve county-level population data for Florida.
# 3. Convert the JSON response into a pandas DataFrame and clean column names.
# 4. Save the result as a local CSV file (`us_census_fl_county_population.csv`) for use in the GTB modernization portfolio.
# 5. (Later) Lift this pattern into Fabric and write the data into a Lakehouse Delta table.

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

# step_1.py — Call US Census API for Florida county population (ACS5)

import requests

CENSUS_API_KEY = "d6e29150e8ff61ccb87a6e3248f1bfff78970db5"

BASE_URL = "https://api.census.gov/data/2022/acs/acs5"

url = (
    f"{BASE_URL}"
    f"?get=NAME,B01003_001E"
    f"&for=county:*"
    f"&in=state:12"
    f"&key={CENSUS_API_KEY}"
)

response = requests.get(url)
response.raise_for_status()

print("Status:", response.status_code)
print("Preview:", response.text[:200])

data = response.json()
data[:5]

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# step_2.py — Convert Census JSON response to pandas DataFrame

import pandas as pd

# 'data' comes from step_1
header = data[0]
rows = data[1:]

df = pd.DataFrame(rows, columns=header)

# Normalize column names for consistency and Fabric compatibility
df = df.rename(columns={
    "NAME": "county_name",
    "B01003_001E": "population",
    "state": "state_fips",
    "county": "county_fips"
})

# Explicit typing (important for Spark later)
df["population"] = df["population"].astype(int)
df["state_fips"] = df["state_fips"].astype(str)
df["county_fips"] = df["county_fips"].astype(str)

df.head()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# step_3 — Convert pandas → Spark and write to Delta

# Convert pandas DataFrame to Spark DataFrame
df_spark = spark.createDataFrame(df)

# Write to Delta table in the Lakehouse
(
    df_spark.write
        .format("delta")
        .mode("overwrite")
        .saveAsTable("us_census_fl_county_population")
)

df_spark.show(5)

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
