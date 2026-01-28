import pyodbc
from sqlalchemy import create_engine
from urllib.parse import quote_plus

def build_odbc_conn_str(server, database, user, password):
    return (
        "Driver={ODBC Driver 17 for SQL Server};"
        f"Server=tcp:{server},1433;"
        f"Database={database};"
        f"Uid={user};"
        f"Pwd={password};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=30;"
    )

def get_pyodbc_connection(server, database, user, password):
    conn_str = build_odbc_conn_str(server, database, user, password)
    return pyodbc.connect(conn_str)

def get_sqlalchemy_engine(server, database, user, password):
    odbc_str = build_odbc_conn_str(server, database, user, password)
    encoded = quote_plus(odbc_str)
    return create_engine(f"mssql+pyodbc:///?odbc_connect={encoded}")
