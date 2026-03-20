import httpx
from fastapi import HTTPException
from auth import get_token

BASE_URL = "https://org7ad35dcc.crm.dynamics.com/api/data/v9.2"
ENTITY_SET = "cr1d7_equipmentrequestses"


# -----------------------------
# GET LIST
# -----------------------------
async def get_list():
    token = await get_token()
    url = f"{BASE_URL}/{ENTITY_SET}"

    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json"
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers)

    if response.status_code != 200:
        raise HTTPException(response.status_code, response.text)

    return response.json().get("value", [])


# -----------------------------
# GET BY ID
# -----------------------------
async def get_by_id(record_id: str):
    token = await get_token()
    url = f"{BASE_URL}/{ENTITY_SET}({record_id})"

    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json"
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers)

    if response.status_code != 200:
        raise HTTPException(response.status_code, response.text)

    return response.json()


# -----------------------------
# CREATE
# -----------------------------
async def create(payload: dict):
    token = await get_token()
    url = f"{BASE_URL}/{ENTITY_SET}"

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(url, headers=headers, json=payload)

    if response.status_code not in (200, 204):
        raise HTTPException(response.status_code, response.text)

    return response.headers.get("OData-EntityId")


# -----------------------------
# UPDATE (PATCH)
# -----------------------------
async def update(record_id: str, payload: dict):
    token = await get_token()
    url = f"{BASE_URL}/{ENTITY_SET}({record_id})"

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "If-Match": "*"
    }

    async with httpx.AsyncClient() as client:
        response = await client.patch(url, headers=headers, json=payload)

    if response.status_code not in (200, 204):
        raise HTTPException(response.status_code, response.text)

    return True


# -----------------------------
# DELETE
# -----------------------------
async def delete(record_id: str):
    token = await get_token()
    url = f"{BASE_URL}/{ENTITY_SET}({record_id})"

    headers = {
        "Authorization": f"Bearer {token}",
        "If-Match": "*"
    }

    async with httpx.AsyncClient() as client:
        response = await client.delete(url, headers=headers)

    if response.status_code not in (200, 204):
        raise HTTPException(response.status_code, response.text)

    return True