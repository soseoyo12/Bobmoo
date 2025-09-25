# -*- coding: utf-8 -*-
from __future__ import annotations
from typing import Any, Tuple
import re
from jsonschema import validate as _validate, Draft7Validator
from jsonschema.exceptions import ValidationError
from .schema import load_standard_schema


def coerce_price(value: Any) -> Any:
    if isinstance(value, (int, float)):
        return value
    if isinstance(value, str):
        digits = re.sub(r"[^0-9]", "", value)
        return int(digits) if digits else value
    return value


def normalize_hours(value: Any) -> Any:
    if not isinstance(value, str):
        return value
    v = value.replace("~", "-")
    v = re.sub(r"\s+", "", v)
    # naive: ensure HH:MM-HH:MM if possible
    m = re.findall(r"(\d{1,2}):(\d{2})", v)
    if len(m) == 2:
        return f"{m[0][0].zfill(2)}:{m[0][1]}-{m[1][0].zfill(2)}:{m[1][1]}"
    return value


def auto_fix(payload: dict) -> dict:
    fixed = dict(payload)
    for caf in fixed.get("cafeterias", []) or []:
        hours = caf.get("hours") or {}
        for k in ("breakfast", "lunch", "dinner"):
            if k in hours and hours[k]:
                hours[k] = normalize_hours(hours[k])
        meals = caf.get("meals") or {}
        for mkey in ("breakfast", "lunch", "dinner"):
            arr = meals.get(mkey) or []
            for item in arr:
                if "price" in item:
                    item["price"] = coerce_price(item["price"])
    return fixed


def validate_or_fix(payload: dict) -> Tuple[bool, Any]:
    schema = load_standard_schema()
    validator = Draft7Validator(schema)
    errors = sorted(validator.iter_errors(payload), key=lambda e: e.path)
    if not errors:
        return True, payload
    fixed = auto_fix(payload)
    errors_after = sorted(validator.iter_errors(fixed), key=lambda e: e.path)
    if not errors_after:
        return True, fixed
    return False, errors_after