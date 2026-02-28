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

# # NOAA NWS Weather Ingestion
# 
# This notebook ingests forecast data from the National Weather Service (NWS) public API and prepares it for Lakehouse storage inside the GTB Fabric workspace. The workflow follows four steps:  
# 1. Convert latitude/longitude into an NWS gridpoint using the `/points` endpoint.  
# 2. Extract the forecast URL returned by the API.  
# 3. Retrieve the full forecast JSON for the identified gridpoint.  
# 4. Convert the forecast periods into a DataFrame and write the results into a Fabric Lakehouse table.
# 
# Once the notebook is attached to a Lakehouse, the final step uses Spark to write Delta-formatted data into the `Tables/noaa_forecast` folder, making the dataset queryable across Fabric, SQL endpoints, and Power BI.
# 
# This notebook serves as the first external API ingestion example in the GTB modernization project and establishes the pattern for future external API integrations.

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

import requests

headers = {"User-Agent": "GTB-Portfolio-Demo (michael@example.com)"}
url = "https://api.weather.gov/points/27.9378,-82.7925"

r = requests.get(url, headers=headers)
points = r.json()
points

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

forecast_url = points["properties"]["forecast"]
forecast_url

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

forecast = requests.get(forecast_url, headers=headers).json()
forecast

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

import pandas as pd
from pyspark.sql import SparkSession

# Build pandas DataFrame from forecast JSON
df = pd.DataFrame(forecast["properties"]["periods"])

# Drop unsupported columns for Delta write
df = df.drop(columns=["temperatureTrend", "probabilityOfPrecipitation"])

# Convert to Spark DataFrame
spark = SparkSession.builder.getOrCreate()
sdf = spark.createDataFrame(df)

# Overwrite the Delta table in the Lakehouse
sdf.write.format("delta").mode("overwrite").save("Tables/noaa_forecast")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

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
