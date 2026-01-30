# silver-transform.py

This script performs deterministic refinement of Bronze data into the Silver layer. It mirrors the logic defined in the Silver transformation notebook, applying schema enforcement, normalization, deduplication, and derived field creation. All environment‑specific values are externalized through configuration to ensure consistent execution across development and automated pipeline environments.

# ============================================================
# Silver Transformation Script
# Deterministic Bronze → Silver refinement
# ============================================================

import json
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, trim, current_timestamp
from pyspark.sql.types import (
    StructType, StructField, StringType, IntegerType, DoubleType, TimestampType
)

# ------------------------------------------------------------
# 1. Initialize Spark
# ------------------------------------------------------------
spark = SparkSession.builder.getOrCreate()

# ------------------------------------------------------------
# 2. Load configuration
# ------------------------------------------------------------
config_path = "/Workspace/Repos/silver/silver-transform-config.json"

with open(config_path, "r") as f:
    config = json.load(f)

bronze_path = config["paths"]["bronze"]
silver_path = config["paths"]["silver"]
silver_mode = config["write"]["mode"]
schema_file = config["schema"]["file"]

# ------------------------------------------------------------
# 3. Load Silver schema
# ------------------------------------------------------------
with open(schema_file, "r") as f:
    schema_json = json.load(f)

silver_schema = StructType([
    StructField("order_id", StringType(), True),
    StructField("customer_id", StringType(), True),
    StructField("product_id", StringType(), True),
    StructField("quantity", IntegerType(), True),
    StructField("unit_price", DoubleType(), True),
    StructField("order_timestamp", TimestampType(), True),
    StructField("total_amount", DoubleType(), True)
])

# ------------------------------------------------------------
# 4. Read Bronze data
# ------------------------------------------------------------
df_bronze = (
    spark.read
         .format("delta")
         .load(bronze_path)
)

# ------------------------------------------------------------
# 5. Apply deterministic Silver transformations
# ------------------------------------------------------------

# Clean and normalize fields
df_clean = (
    df_bronze
        .withColumn("order_id", trim(col("order_id")))
        .withColumn("customer_id", trim(col("customer_id")))
        .withColumn("product_id", trim(col("product_id")))
        .withColumn("quantity", col("quantity").cast("int"))
        .withColumn("unit_price", col("unit_price").cast("double"))
        .withColumn("total_amount", col("quantity") * col("unit_price"))
)

# Deduplicate records
df_deduped = df_clean.dropDuplicates(["order_id", "product_id", "order_timestamp"])

# Enforce Silver schema
df_silver = spark.createDataFrame(df_deduped.rdd, silver_schema)

# ------------------------------------------------------------
# 6. Write to Silver
# ------------------------------------------------------------
(
    df_silver.write
             .format("delta")
             .mode(silver_mode)
             .save(silver_path)
)

# ------------------------------------------------------------
# 7. Confirmation
# ------------------------------------------------------------
print("Silver transformation completed successfully.")