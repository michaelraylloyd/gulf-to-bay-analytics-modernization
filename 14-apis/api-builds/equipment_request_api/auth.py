import httpx
import time

TENANT_ID = "a4326a58-f7d9-444d-b3aa-b09027e5e866"
CLIENT_ID = "d3eb65b0-7f7f-4790-b54d-71591b36e42f"
CLIENT_SECRET = "0Fx8Q~jfWjQpPcB34i9xufNcz64CvV_2wiaG5bcH"
RESOURCE = "https://org7ad35dcc.crm.dynamics.com"

TOKEN_URL = f"https://login.microsoftonline.com/a4326a58-f7d9-444d-b3aa-b09027e5e866/oauth2/v2.0/token"

_cached_token = None
_cached_expiry = 0


async def get_token():
    global _cached_token, _cached_expiry

    # Reuse token if still valid
    if _cached_token and time.time() < _cached_expiry:
        return _cached_token

    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "client_credentials",
        "scope": f"{RESOURCE}/.default"
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(TOKEN_URL, data=data)
        response.raise_for_status()
        token_data = response.json()

    _cached_token = token_data["access_token"]
    _cached_expiry = time.time() + token_data["expires_in"] - 60

    return _cached_token