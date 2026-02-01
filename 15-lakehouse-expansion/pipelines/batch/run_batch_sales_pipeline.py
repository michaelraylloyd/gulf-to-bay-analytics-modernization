# ============================================================
# Batch Pipeline Orchestrator
# Executes Bronze → Silver → Gold in deterministic sequence
# ============================================================

import subprocess
import sys
from pathlib import Path


# ------------------------------------------------------------
# 1. Resolve repo root (Windows‑safe)
# ------------------------------------------------------------
# This file lives at:
#   <repo_root>/pipelines/batch/run_batch_sales_pipeline.py
#
# So repo_root = parents[2]
#   run_batch_sales_pipeline.py → batch → pipelines → repo_root
# ------------------------------------------------------------

def get_repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


# ------------------------------------------------------------
# 2. Resolve script + config paths for each layer
# ------------------------------------------------------------
def bronze_paths():
    repo = get_repo_root()
    script = repo / "nb" / "bronze_ingestion" / "ingest_sales_batch.py"
    config = repo / "nb" / "bronze_ingestion" / "ingestion_config.json"
    return script, config


def silver_paths():
    repo = get_repo_root()
    script = repo / "nb" / "silver_transformation" / "transform_sales_silver.py"
    config = repo / "nb" / "silver_transformation" / "silver_config.json"
    return script, config


def gold_paths():
    repo = get_repo_root()
    script = repo / "nb" / "gold_modeling" / "model_sales_gold.py"
    config = repo / "nb" / "gold_modeling" / "modeling_config.json"
    return script, config


# ------------------------------------------------------------
# 3. Build commands (Python‑native execution)
# ------------------------------------------------------------
def build_cmd(script: Path, config: Path) -> list[str]:
    return [
        sys.executable,
        str(script),
        "--config",
        str(config)
    ]


# ------------------------------------------------------------
# 4. Execute Bronze ingestion
# ------------------------------------------------------------
def run_bronze():
    script, config = bronze_paths()
    subprocess.check_call(build_cmd(script, config))


# ------------------------------------------------------------
# 5. Execute Silver transformation
# ------------------------------------------------------------
def run_silver():
    script, config = silver_paths()
    subprocess.check_call(build_cmd(script, config))


# ------------------------------------------------------------
# 6. Execute Gold modeling
# ------------------------------------------------------------
def run_gold():
    script, config = gold_paths()
    subprocess.check_call(build_cmd(script, config))


# ------------------------------------------------------------
# 7. Entrypoint (full pipeline execution)
# ------------------------------------------------------------
if __name__ == "__main__":
    run_bronze()
    run_silver()
    run_gold()