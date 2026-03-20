from datetime import datetime
from models import EquipmentRequestResponse


def normalize_equipment_request(raw: dict) -> EquipmentRequestResponse:
    """Normalize a raw Dataverse record into the clean API-facing model."""

    # Primary key (GUID)
    record_id = raw.get("cr1d7_equipmentrequestsid")

    # Convert Dataverse datetime → Python date
    request_date_raw = raw.get("cr1d7_requestdate")
    request_date = None
    if request_date_raw:
        request_date = datetime.fromisoformat(
            request_date_raw.replace("Z", "+00:00")
        ).date()

    return EquipmentRequestResponse(
        id=record_id,
        approval_stage=raw.get("cr1d7_approvalstage"),
        equipment_type=raw.get("cr1d7_equipmenttype"),
        estimated_cost=raw.get("cr1d7_estimatedcost"),
        justification=raw.get("cr1d7_justification"),
        quantity=raw.get("cr1d7_quantity"),
        request_date=request_date,
        requested_by=raw.get("cr1d7_requestedby"),
        status=raw.get("cr1d7_status"),
        is_archived=raw.get("cr1d7_isarchived"),
        notes=raw.get("cr1d7_notes"),
        new_column=raw.get("cr1d7_newcolumn"),
        created_on=raw.get("createdon"),
        modified_on=raw.get("modifiedon"),
        owner_id=raw.get("_ownerid_value"),
    )