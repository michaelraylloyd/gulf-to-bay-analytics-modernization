import os
import pandas as pd
from dotenv import load_dotenv

from utils.db import get_pyodbc_connection, get_sqlalchemy_engine
from utils.metadata import load_table_list
from utils.logging_utils import configure_logging

load_dotenv()

SERVER = os.getenv("AZURE_SQL_SERVER")
DB_SOURCE = os.getenv("AZURE_SQL_DB_SOURCE")
DB_DEST = os.getenv("AZURE_SQL_DB_DEST")
USER = os.getenv("AZURE_SQL_USER")
PASSWORD = os.getenv("AZURE_SQL_PASSWORD")

log = configure_logging()

def copy_table(table_name):
    try:
        log.info(f"Copying table: {table_name}")

        src = get_pyodbc_connection(SERVER, DB_SOURCE, USER, PASSWORD)
        df = pd.read_sql(f"SELECT * FROM {table_name}", src)
        src.close()

        engine = get_sqlalchemy_engine(SERVER, DB_DEST, USER, PASSWORD)
        df.to_sql(table_name, engine, if_exists="replace", index=False)

        log.info(f"Copied {len(df)} rows from {table_name}")

    except Exception as e:
        log.error(f"Error copying {table_name}: {e}")
        raise

def run_stored_proc(proc_name):
    try:
        log.info(f"Running stored procedure: {proc_name}")

        conn = get_pyodbc_connection(SERVER, DB_SOURCE, USER, PASSWORD)
        cursor = conn.cursor()
        cursor.execute(f"EXEC {proc_name}")
        cursor.commit()
        conn.close()

        log.info(f"Stored procedure completed: {proc_name}")

    except Exception as e:
        log.error(f"Error running stored procedure {proc_name}: {e}")
        raise

if __name__ == "__main__":
    log.info("Pipeline started")

    tables = load_table_list()

    for table in tables:
        copy_table(table)

    run_stored_proc("dbo.usp_LoadMissingKeys")

    log.info("Pipeline complete")
