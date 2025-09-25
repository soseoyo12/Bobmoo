# -*- coding: utf-8 -*-
from __future__ import annotations

import re
from typing import Optional


def normalize_price(value: str | int | float | None) -> Optional[int]:
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return int(value)
    digits = re.sub(r"[^0-9]", "", str(value))
    return int(digits) if digits else None


def normalize_time_range(value: str | None) -> Optional[str]:
    if not value:
        return None
    v = str(value).replace("~", "-")
    v = re.sub(r"\s+", "", v)
    m = re.findall(r"(\d{1,2}):(\d{2})", v)
    if len(m) >= 2:
        a, b = m[0], m[1]
        return f"{a[0].zfill(2)}:{a[1]}-{b[0].zfill(2)}:{b[1]}"
    return None


def normalize_text(value: str | None) -> str:
    if not value:
        return ""
    text = re.sub(r"\s+", " ", str(value)).strip()
    return text

