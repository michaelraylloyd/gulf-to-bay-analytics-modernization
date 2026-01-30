import json
import pandas as pd

def load_expectations(path):
    with open(path, "r") as f:
        return json.load(f)

def run_checks(df, expectations):
    results = []

    for check in expectations["checks"]:
        ctype = check["type"]
        column = check.get("column")

        if ctype == "not_null":
            failed = df[df[column].isnull()]
            results.append({
                "check": f"not_null_{column}",
                "passed": failed.empty,
                "failed_rows": len(failed)
            })

        elif ctype == "type":
            expected = check["expected"]
            actual = df[column].dtype.name
            results.append({
                "check": f"type_{column}",
                "passed": expected in actual,
                "actual_type": actual
            })

        elif ctype == "range":
            min_val = check.get("min")
            failed = df[df[column] < min_val]
            results.append({
                "check": f"range_{column}",
                "passed": failed.empty,
                "failed_rows": len(failed)
            })

        elif ctype == "unique":
            duplicates = df[df[column].duplicated()]
            results.append({
                "check": f"unique_{column}",
                "passed": duplicates.empty,
                "failed_rows": len(duplicates)
            })

        elif ctype == "row_count_min":
            min_rows = check["min"]
            results.append({
                "check": "row_count_min",
                "passed": len(df) >= min_rows,
                "row_count": len(df)
            })

    return results

def run_dq(table_df, expectations_path):
    expectations = load_expectations(expectations_path)
    results = run_checks(table_df, expectations)
    return results