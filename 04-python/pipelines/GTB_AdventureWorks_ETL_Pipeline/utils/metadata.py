import json

def load_table_list(path="tables.json"):
    with open(path) as f:
        return json.load(f)["tables"]
