# -*- coding: utf-8 -*-
from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Dict, Any

from .fetcher import fetch_url
from .parser_bs4 import parse_bs4
from .normalizer import normalize_price, normalize_text, normalize_time_range
from .llm_client import call_gemini_25_flash
from .validator import validate_or_fix
from .parser_selenium import fetch_html_with_selenium


def _summarize_candidates(html: str) -> Dict[str, Any]:
    cands = parse_bs4(html)
    sections = []
    total_meals = 0
    for c in cands:
        section = {
            "nameHints": [c.name],
            "hours": {k: normalize_time_range(v) for k, v in (c.hours or {}).items()},
            "meals": {
                k: [
                    {
                        "course": m.course,
                        "mainMenu": normalize_text(m.mainMenu),
                        "price": normalize_price(m.price),
                    }
                    for m in arr
                ]
                for k, arr in (c.meals or {}).items()
            },
        }
        sections.append(section)
        for arr in section["meals"].values():
            total_meals += len(arr)
    return {"sections": sections, "_mealCount": total_meals}


def _extract_plaintext(html: str, limit: int = 6000) -> str:
    try:
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(html, "lxml")
        text = soup.get_text("\n", strip=True)
        # keep korean menu keywords dense
        text = "\n".join(line for line in text.splitlines() if line)
        return text[:limit]
    except Exception:
        return html[:limit]


def _load_example_json() -> Dict[str, Any] | None:
    try:
        base = Path(__file__).resolve().parent.parent
        path = base / "jsonExample.json"
        if path.exists():
            return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None
    return None


def _coerce_llm_output(payload: Dict[str, Any], meta: Dict[str, Any] | None = None) -> Dict[str, Any]:
    data = dict(payload) if isinstance(payload, dict) else {}
    meta = meta or {}
    # Top-level school
    if "school" not in data and "schoolName" in data:
        data["school"] = data.pop("schoolName")
    if "school" not in data:
        schools = meta.get("schoolCandidates") or []
        if schools:
            data["school"] = schools[0]
    if "date" not in data:
        dates = meta.get("dateCandidates") or []
        if dates:
            data["date"] = dates[0]
    if "cafeterias" not in data and "restaurants" in data:
        data["cafeterias"] = data.pop("restaurants")
    if not isinstance(data.get("cafeterias"), list):
        data["cafeterias"] = []

    cafeterias = data.get("cafeterias")
    if isinstance(cafeterias, list):
        new_list = []
        for caf in cafeterias:
            if not isinstance(caf, dict):
                continue
            caf2 = dict(caf)
            # Rename keys
            if "hours" not in caf2 and "operatingHours" in caf2:
                caf2["hours"] = caf2.pop("operatingHours")
            if "meals" not in caf2 and "menus" in caf2:
                caf2["meals"] = caf2.pop("menus")
            # Ensure required container types
            if not isinstance(caf2.get("hours"), dict):
                caf2["hours"] = {}
            meals = caf2.get("meals")
            if isinstance(meals, list):
                # If LLM returned a flat list, assume lunch by default
                caf2["meals"] = {"lunch": meals}
                meals = caf2["meals"]
            if not isinstance(meals, dict):
                caf2["meals"] = {}
                meals = caf2["meals"]
            # Remove non-schema keys
            for k in ["type", "category", "notes"]:
                caf2.pop(k, None)

            # Normalize meals entries keys
            if isinstance(meals, dict):
                for period, arr in list(meals.items()):
                    if not isinstance(arr, list):
                        meals[period] = []
                        continue
                    new_arr = []
                    for item in arr:
                        if not isinstance(item, dict):
                            continue
                        item2 = dict(item)
                        # common alt fields
                        if "mainMenu" not in item2:
                            for alt in ("menu", "name", "dish"):
                                if alt in item2:
                                    item2["mainMenu"] = item2.pop(alt)
                                    break
                        if "course" not in item2:
                            item2["course"] = item2.get("courseLabel", "A")
                            item2.pop("courseLabel", None)
                        # price may be nested or string -> keep as is; validator will coerce
                        new_arr.append(item2)
                    meals[period] = new_arr
            new_list.append(caf2)
        data["cafeterias"] = new_list

    return data


def _extract_candidates_from_text(raw_html: str) -> Dict[str, Any]:
    text = raw_html
    # naive school detection
    schools = []
    if "인하대학교" in text:
        schools.append("인하대학교")
    # date detection (YYYY-MM-DD)
    import re
    dates = []
    for m in re.finditer(r"(20\d{2})[-.](\d{1,2})[-.](\d{1,2})", text):
        y, mo, d = m.group(1), m.group(2).zfill(2), m.group(3).zfill(2)
        dates.append(f"{y}-{mo}-{d}")
    return {"schoolCandidates": schools, "dateCandidates": dates}


def _ensure_out_dir(base: Path) -> None:
    base.mkdir(parents=True, exist_ok=True)


def transform_from_url(url: str, *, out_dir: str | os.PathLike[str] = "out") -> Dict[str, Any]:
    # Step 1: fetch
    fetched = fetch_url(url)

    # Step 2: bs4 parse and summarize (보조), 그리고 전체 HTML 전달 준비
    summary = _summarize_candidates(fetched.text)
    meta = _extract_candidates_from_text(fetched.text)

    # Step 3: LLM call - 전체 HTML과 예시 JSON을 함께 제공
    system_prompt = "너는 대학 식단 데이터 변환기다. 표준 스키마로만 JSON을 출력해라."
    example_json = _load_example_json()
    payload = {
        **meta,
        "pageHtml": fetched.text,
        "pageText": _extract_plaintext(fetched.text),
        # 참고용으로 섹션 요약도 같이 제공
        "sections": summary.get("sections", []),
    }
    if example_json is not None:
        payload["exampleJson"] = example_json
    llm_json = call_gemini_25_flash(system_prompt, payload)
    llm_json = _coerce_llm_output(llm_json, meta)

    # Step 4: validate
    ok, result = validate_or_fix(llm_json)
    if not ok:
        # trigger selenium fallback when empty or invalid
        sel = fetch_html_with_selenium(url, wait_selector=None, timeout=15, headless=True)
        summary2 = _summarize_candidates(sel.html)
        meta2 = _extract_candidates_from_text(sel.html)
        example_json2 = _load_example_json()
        payload2 = {
            **meta2,
            "pageHtml": sel.html,
            "pageText": _extract_plaintext(sel.html),
            "sections": summary2.get("sections", []),
        }
        if example_json2 is not None:
            payload2["exampleJson"] = example_json2
        llm_json = call_gemini_25_flash(system_prompt, payload2)
        llm_json = _coerce_llm_output(llm_json, meta2)
        ok, result = validate_or_fix(llm_json)
        if not ok:
            raise RuntimeError(f"Validation failed after selenium fallback: {result}")

    data = result

    # Step 5: persist
    school = normalize_text(data.get("school")) or "unknown"
    date = normalize_text(data.get("date")) or "unknown-date"
    out_base = Path(out_dir) / school
    _ensure_out_dir(out_base)
    out_path = out_base / f"{date}.json"
    out_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    return data

