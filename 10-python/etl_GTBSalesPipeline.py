import pandas as pd
import sqlalchemy as sa
from sqlalchemy.engine import URL
from dotenv import load_dotenv
import os

# ---------------------------------------------------------
# Load environment variables explicitly from config.env
# ---------------------------------------------------------
load_dotenv("config.env")

server = os.getenv("SQL_SERVER")
database = os.getenv("SQL_DATABASE")
username = os.getenv("SQL_USERNAME")
password = os.getenv("SQL_PASSWORD")

print("Loaded environment variables:")
print("  SERVER  :", server)
print("  DATABASE:", database)
print("  USERNAME:", username)
print("  PASSWORD:", "(hidden)")  # don't print the real password

# ---------------------------------------------------------
# Build connection URL for SQLAlchemy + pyodbc
# ---------------------------------------------------------
connection_url = URL.create(
    "mssql+pyodbc",
    username=username,
    password=password,
    host=server,
    database=database,
    query={"driver": "ODBC Driver 17 for SQL Server"}
)

engine = sa.create_engine(connection_url)

# ---------------------------------------------------------
# Verify which database Python actually connected to
# ---------------------------------------------------------
with engine.connect() as conn:
    result = conn.execute(sa.text("SELECT DB_NAME()"))
    active_db = result.scalar()
    print("\nPython is actually connected to database:", active_db)

# ---------------------------------------------------------
# Test query
# ---------------------------------------------------------
query = "SELECT TOP 10 * FROM Sales.SalesOrderHeader"

df = pd.read_sql(query, engine)
print("\nQuery results:")
print(df.head())