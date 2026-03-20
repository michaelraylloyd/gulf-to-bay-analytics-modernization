from fastapi import APIRouter
from models import (
    EquipmentRequestCreate,
    EquipmentRequestUpdate,
    EquipmentRequestResponse
)
from services import (
    get_list,
    get_by_id,
    create,
    update,
    delete
)
from normalization import normalize_equipment_request

router = APIRouter(prefix="/equipment-requests", tags=["Equipment Requests"])


# -----------------------------
# GET LIST
# -----------------------------
@router.get("/", response_model=list[EquipmentRequestResponse])
async def list_equipment_requests():
    print(">>> list_equipment_requests CALLED", flush=True)
    raw_records = await get_list()

    # Print raw Dataverse record BEFORE normalization
    if raw_records:
        print(">>> RAW RECORD SAMPLE:", raw_records[0], flush=True)
    else:
        print(">>> RAW RECORD SAMPLE: NO RECORDS", flush=True)

    return [normalize_equipment_request(r) for r in raw_records]


# -----------------------------
# GET BY ID
# -----------------------------
@router.get("/{record_id}", response_model=EquipmentRequestResponse)
async def get_equipment_request(record_id: str):
    raw = await get_by_id(record_id)
    return normalize_equipment_request(raw)


# -----------------------------
# CREATE
# -----------------------------
@router.post("/", response_model=str)
async def create_equipment_request(payload: EquipmentRequestCreate):
    dv_payload = payload.dict(exclude_none=True)
    entity_id = await create(dv_payload)
    return entity_id


# -----------------------------
# UPDATE (PATCH)
# -----------------------------
@router.patch("/{record_id}")
async def update_equipment_request(record_id: str, payload: EquipmentRequestUpdate):
    dv_payload = payload.dict(exclude_none=True)
    await update(record_id, dv_payload)
    return {"updated": True}


# -----------------------------
# DELETE
# -----------------------------
@router.delete("/{record_id}")
async def delete_equipment_request(record_id: str):
    await delete(record_id)
    return {"deleted": True}