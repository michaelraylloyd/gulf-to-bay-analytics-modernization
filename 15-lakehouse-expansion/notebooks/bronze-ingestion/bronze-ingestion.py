# ============================================================
# Bronze Ingestion Script
# Deterministic raw → bronze ingestion with schema enforcement
# ============================================================

import json
from pyspark.sql import SparkSession
from pyspark.sql.types import (
    StructType, StructField, StringType, IntegerType, DoubleType, TimestampType
)
from pyspark.sql.functions import current_timestamp

# ------------------------------------------------------------
# 1. Initialize Spark
# ------------------------------------------------------------
spark = SparkSession.builder.getOrCreate()

# ------------------------------------------------------------
# 2. Load configuration
# ------------------------------------------------------------
config_path = "/Workspace/Repos/bronze/bronze-ingestion-config.json"

with open(config_path, "r") as f:
    config = json.load(f)

source_format = config["source"]["format"]
source_path = config["source"]["path"]

target_format = config["target"]["format"]
target_path = config["target"]["path"]
target_mode = config["target"]["mode"]

schema_file = config["schema"]["file"]

# ------------------------------------------------------------
# 3. Load schema definition
# ------------------------------------------------------------
with open(schema_file, "r") as f:
    schema_json = json.load(f)

bronze_schema = StructType([
    StructField("order_id", StringType(), True),
    StructField("customer_id", StringType(), True),
    StructField("product_id", StringType(), True),
    StructField("quantity", IntegerType(), True),
    StructField("unit_price", DoubleType(), True),
    StructField("order_timestamp", TimestampType(), True)
])

# ------------------------------------------------------------
# 4. Read raw data with enforced schema
# ------------------------------------------------------------
df_raw = (
    spark.read
         .format(source_format)
         .schema(bronze_schema)
         .load(source_path)
)

# ------------------------------------------------------------
# 5. Add ingestion metadata
# ------------------------------------------------------------
df_bronze = (
    df_raw.withColumn("ingestion_timestamp", current_timestamp())
          .withColumn("source_file", current_timestamp().cast("string"))
)

# ------------------------------------------------------------
# 6. Write to Bronze as append-only Delta
# ------------------------------------------------------------
(
    df_bronze.write
             .format(target_format)
             .mode(target_mode)
             .save(target_path)
)

# ------------------------------------------------------------
# 7. Confirmation
# ------------------------------------------------------------
print("Bronze ingestion script completed successfully.")