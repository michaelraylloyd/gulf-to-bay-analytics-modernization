import json
import time
import random
import datetime
import requests
from azure.identity import InteractiveBrowserCredential

INGEST_URL = (
    "https://ingest-trd-3s3hzrram55v1knr1d.z3.kusto.fabric.microsoft.com"
    "/v1/rest/ingest/RoboticsEventhouse/RawTelemetry?streamFormat=json"
)

credential = InteractiveBrowserCredential()
token = credential.get_token("https://kusto.kusto.windows.net/.default").token

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json",
    "x-ms-kusto-streaming-ingest": "true",
    "x-ms-kusto-mapping": "RawTelemetry_mapping"
}

while True:
    event = {
        "deviceId": f"robot-{random.randint(1,5)}",
        "temperature": round(random.uniform(65, 95), 2),
        "rpm": random.randint(800, 2000),
        "battery": random.randint(20, 100),
        "timestamp": datetime.datetime.now(datetime.UTC).isoformat()
    }

    response = requests.post(INGEST_URL, headers=headers, data=json.dumps(event), timeout=10)
    print(response.status_code, response.text)

    time.sleep(1)