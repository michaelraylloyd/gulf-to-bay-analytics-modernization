print("RUNNING FILE:", __file__)

# ============================================================
# Bronze Ingestion Script — Parquet Edition (Windows‑Safe)
# Deterministic raw → bronze ingestion with schema enforcement
# ============================================================

import json
from pathlib import Path
from pyspark.sql import SparkSession
from pyspark.sql.types import (
    StructType, StructField, StringType, IntegerType, DoubleType, TimestampType
)
from pyspark.sql.functions import current_timestamp


# ------------------------------------------------------------
# 1. Resolve repo‑relative paths (Windows‑safe)
# ------------------------------------------------------------
def get_repo_root() -> Path:
    # <repo>/15-lakehouse-expansion/nb/bronze_ingestion/ingest_sales_batch.py
    return Path(__file__).resolve().parents[3]


def resolve_repo_path(relative_or_absolute: str) -> Path:
    p = Path(relative_or_absolute)
    if p.is_absolute():
        return p
    return (get_repo_root() / p).resolve()


# ------------------------------------------------------------
# 2. Initialize Spark (Windows‑safe, no Delta)
# ------------------------------------------------------------
def init_spark() -> SparkSession:
    return (
        SparkSession.builder
        .appName("bronze_sales_ingestion")
        .master("local[*]")

        # Windows Hadoop native I/O bypass
        .config("spark.hadoop.io.native.lib.available", "false")
        .config("spark.hadoop.fs.file.impl.disable.cache", "true")
        .config("spark.speculation", "false")

        .getOrCreate()
    )


# ------------------------------------------------------------
# 3. Load ingestion configuration (JSON)
# ------------------------------------------------------------
def load_config(config_path: Path) -> dict:
    with config_path.open("r", encoding="utf-8") as f:
        return json.load(f)


# ------------------------------------------------------------
# 4. Define Bronze schema (schema‑on‑read)
# ------------------------------------------------------------
BRONZE_SCHEMA = StructType([
    StructField("order_id",        StringType(),    True),
    StructField("customer_id",     StringType(),    True),
    StructField("product_id",      StringType(),    True),
    StructField("quantity",        IntegerType(),   True),
    StructField("unit_price",      DoubleType(),    True),
    StructField("order_timestamp", TimestampType(), True),
])


# ------------------------------------------------------------
# 5. Read raw data with schema enforcement
# ------------------------------------------------------------
def read_raw(spark: SparkSession, cfg: dict):
    source_format = cfg["source"]["format"]
    source_path = resolve_repo_path(cfg["source"]["path"])

    print("\n=== SOURCE PATH RESOLVED ===")
    print(source_path)

    reader = (
        spark.read
        .format(source_format)
        .schema(BRONZE_SCHEMA)
    )

    if "options" in cfg["source"]:
        for k, v in cfg["source"]["options"].items():
            reader = reader.option(k, v)

    df = reader.load(str(source_path))

    print("\n=== RAW DATAFRAME SCHEMA ===")
    df.printSchema()

    print("\n=== RAW DATAFRAME COUNT ===")
    print(df.count())

    print("\n=== RAW DATAFRAME SAMPLE ===")
    df.show(5, truncate=False)

    return df


# ------------------------------------------------------------
# 6. Apply Bronze metadata columns
# ------------------------------------------------------------
def apply_metadata(df):
    print("\n=== APPLYING METADATA COLUMNS ===")
    return (
        df.withColumn("ingestion_timestamp", current_timestamp())
          .withColumn("source_file", current_timestamp().cast("string"))
    )


# ------------------------------------------------------------
# 7. Write Bronze output (Parquet via Pandas — Windows‑safe)
# ------------------------------------------------------------
def write_bronze(df, cfg: dict):
    target_path = resolve_repo_path(cfg["target"]["path"])
    print("\n=== TARGET PATH RESOLVED ===")
    print(target_path)

    print("\n=== CONVERTING TO PANDAS DATAFRAME ===")

    # Convert ALL timestamp columns to string
    timestamp_cols = [f.name for f in df.schema.fields if isinstance(f.dataType, TimestampType)]
    df_fixed = df
    for col_name in timestamp_cols:
        df_fixed = df_fixed.withColumn(col_name, df_fixed[col_name].cast("string"))

    pdf = df_fixed.toPandas()

    # Ensure directory exists
    target_path.mkdir(parents=True, exist_ok=True)
    output_file = target_path / "part-00000.parquet"

    print("\n=== WRITING BRONZE OUTPUT VIA PANDAS (WINDOWS-SAFE) ===")
    pdf.to_parquet(output_file, index=False)

    print("\n=== WRITE COMPLETE ===")

    # Write Parquet using Pandas/pyarrow (bypasses Hadoop native I/O)py
    print("\n=== WRITING BRONZE OUTPUT VIA PANDAS (WINDOWS-SAFE) ===")
    pdf.to_parquet(output_file, index=False)

    print("\n=== WRITE COMPLETE ===")


# ------------------------------------------------------------
# Entrypoint (CLI + orchestration)
# ------------------------------------------------------------
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Run Bronze sales ingestion (repo‑relative config)."
    )
    parser.add_argument(
        "--config",
        type=str,
        default="15-lakehouse-expansion/nb/bronze_ingestion/ingestion_config.json",
        help="Repo‑relative or absolute path to ingestion config JSON."
    )

    args = parser.parse_args()

    config_path = resolve_repo_path(args.config)
    cfg = load_config(config_path)

    spark = init_spark()
    try:
        df_raw = read_raw(spark, cfg)
        df_bronze = apply_metadata(df_raw)
        write_bronze(df_bronze, cfg)
    finally:
        spark.stop()