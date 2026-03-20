from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime


# -----------------------------
# CREATE MODEL
# -----------------------------
class EquipmentRequestCreate(BaseModel):
    approval_stage: Optional[int] = None
    equipment_type: Optional[int] = None
    estimated_cost: Optional[float] = None
    justification: Optional[str] = None
    quantity: Optional[int] = None
    request_date: Optional[date] = None
    requested_by: Optional[str] = None
    status: Optional[int] = None
    is_archived: Optional[bool] = None
    notes: Optional[str] = None
    new_column: Optional[str] = None


# -----------------------------
# UPDATE MODEL (PATCH)
# -----------------------------
class EquipmentRequestUpdate(BaseModel):
    approval_stage: Optional[int] = None
    equipment_type: Optional[int] = None
    estimated_cost: Optional[float] = None
    justification: Optional[str] = None
    quantity: Optional[int] = None
    request_date: Optional[date] = None
    requested_by: Optional[str] = None
    status: Optional[int] = None
    is_archived: Optional[bool] = None
    notes: Optional[str] = None
    new_column: Optional[str] = None


# -----------------------------
# RESPONSE MODEL
# -----------------------------
class EquipmentRequestResponse(BaseModel):
    id: str

    approval_stage: Optional[int] = None
    equipment_type: Optional[int] = None
    estimated_cost: Optional[float] = None
    justification: Optional[str] = None
    quantity: Optional[int] = None
    request_date: Optional[date] = None
    requested_by: Optional[str] = None
    status: Optional[int] = None
    is_archived: Optional[bool] = None
    notes: Optional[str] = None
    new_column: Optional[str] = None

    created_on: Optional[datetime] = None
    modified_on: Optional[datetime] = None
    owner_id: Optional[str] = None