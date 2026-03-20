import os
import httpx
import time

# Load secrets and configuration from environment variables
TENANT_ID = os.getenv("DATAVERSE_TENANT_ID")
CLIENT_ID = os.getenv("DATAVERSE_CLIENT_ID")
CLIENT_SECRET = os.getenv("DATAVERSE_CLIENT_SECRET")
RESOURCE = os.getenv("DATAVERSE_RESOURCE_URL")  # e.g. https://org7ad35dcc.crm.dynamics.com

# Construct token URL dynamically
TOKEN_URL = f"https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/token"

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