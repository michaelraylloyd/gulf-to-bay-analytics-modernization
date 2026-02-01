print("RUNNING FILE:", __file__)

# ============================================================
# Silver Transformation Script — Windows‑Safe Parquet Edition
# Cleans, normalizes, deduplicates Bronze → Silver
# ============================================================

import json
from pathlib import Path
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, trim, upper, to_timestamp, current_timestamp
)
from pyspark.sql.types import (
    TimestampType,
    StructType, StructField,
    StringType, IntegerType, DoubleType
)

# ------------------------------------------------------------
# 1. Resolve repo‑relative paths (Windows‑safe)
# ------------------------------------------------------------
def get_repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def resolve_repo_path(relative_or_absolute: str) -> Path:
    p = Path(relative_or_absolute)
    if p.is_absolute():
        return p
    return (get_repo_root() / p).resolve()


# ------------------------------------------------------------
# 2. Initialize Spark (Windows‑safe)
# ------------------------------------------------------------
def init_spark() -> SparkSession:
    return (
        SparkSession.builder
        .appName("silver_sales_transform")
        .master("local[*]")
        .config("spark.hadoop.io.native.lib.available", "false")
        .config("spark.hadoop.fs.file.impl.disable.cache", "true")
        .config("spark.speculation", "false")
        .getOrCreate()
    )


# ------------------------------------------------------------
# 3. Load config JSON
# ------------------------------------------------------------
def load_config(config_path: Path) -> dict:
    with config_path.open("r", encoding="utf-8") as f:
        return json.load(f)


# ------------------------------------------------------------
# 4. Read Bronze Parquet via Pandas (Windows‑safe)
# ------------------------------------------------------------
def read_bronze(cfg: dict):
    bronze_path = resolve_repo_path(cfg["source"]["path"])
    print("\n=== BRONZE PATH RESOLVED ===")
    print(bronze_path)

    print("\n=== READING BRONZE VIA PANDAS (WINDOWS-SAFE) ===")
    pdf = pd.read_parquet(bronze_path)

    return pdf


# ------------------------------------------------------------
# 5. Explicit Bronze schema for Pandas → Spark conversion
# ------------------------------------------------------------
def bronze_schema():
    return StructType([
        StructField("order_id", StringType(), True),
        StructField("customer_id", StringType(), True),
        StructField("product_id", StringType(), True),
        StructField("quantity", IntegerType(), True),
        StructField("unit_price", DoubleType(), True),
        StructField("order_timestamp", StringType(), True),
        StructField("ingestion_timestamp", StringType(), True),
        StructField("source_file", StringType(), True)
    ])


# ------------------------------------------------------------
# 6. Convert Pandas → Spark (explicit schema)
# ------------------------------------------------------------
def pandas_to_spark(spark, pdf):
    print("\n=== CONVERTING PANDAS → SPARK DATAFRAME (EXPLICIT SCHEMA) ===")
    return spark.createDataFrame(pdf, schema=bronze_schema())


# ------------------------------------------------------------
# 7. Apply Silver transformations
# ------------------------------------------------------------
def transform_silver(df):
    print("\n=== APPLYING SILVER TRANSFORMATIONS ===")

    df = (
        df
        # Trim whitespace
        .withColumn("order_id", trim(col("order_id")))
        .withColumn("customer_id", trim(col("customer_id")))
        .withColumn("product_id", trim(col("product_id")))

        # Normalize casing
        .withColumn("order_id", upper(col("order_id")))
        .withColumn("customer_id", upper(col("customer_id")))
        .withColumn("product_id", upper(col("product_id")))

        # Convert timestamps back to real timestamps
        .withColumn("order_timestamp", to_timestamp("order_timestamp"))

        # Add Silver metadata
        .withColumn("silver_timestamp", current_timestamp())
    )

    # Deduplicate
    df = df.dropDuplicates(["order_id", "product_id", "order_timestamp"])

    return df


# ------------------------------------------------------------
# 8. Convert Spark → Pandas (normalize timestamps)
# ------------------------------------------------------------
def spark_to_pandas(df):
    print("\n=== CONVERTING SPARK → PANDAS (WINDOWS-SAFE) ===")

    timestamp_cols = [
        f.name for f in df.schema.fields
        if isinstance(f.dataType, TimestampType)
    ]

    df_fixed = df
    for col_name in timestamp_cols:
        df_fixed = df_fixed.withColumn(col_name, df_fixed[col_name].cast("string"))

    return df_fixed.toPandas()


# ------------------------------------------------------------
# 9. Write Silver Parquet via Pandas
# ------------------------------------------------------------
def write_silver(pdf, cfg: dict):
    target_path = resolve_repo_path(cfg["target"]["path"])
    print("\n=== SILVER TARGET PATH ===")
    print(target_path)

    target_path.mkdir(parents=True, exist_ok=True)
    output_file = target_path / "part-00000.parquet"

    print("\n=== WRITING SILVER VIA PANDAS (WINDOWS-SAFE) ===")
    pdf.to_parquet(output_file, index=False)

    print("\n=== WRITE COMPLETE ===")


# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Run Silver sales transformation (Windows‑safe)."
    )
    parser.add_argument(
        "--config",
        type=str,
        default="15-lakehouse-expansion/nb/silver_transform/silver_config.json",
        help="Repo‑relative or absolute path to Silver config JSON."
    )

    args = parser.parse_args()

    config_path = resolve_repo_path(args.config)
    cfg = load_config(config_path)

    spark = init_spark()
    try:
        bronze_pdf = read_bronze(cfg)
        bronze_sdf = pandas_to_spark(spark, bronze_pdf)
        silver_sdf = transform_silver(bronze_sdf)
        silver_pdf = spark_to_pandas(silver_sdf)
        write_silver(silver_pdf, cfg)
    finally:
        spark.stop()