from __future__ import annotations

import re
from typing import Dict, List, Tuple

from schemas import Meal, DayMeals


KCAL_RE = re.compile(r"(\d{2,4})\s*kcal", re.IGNORECASE)


def _clean_lines(text: str) -> List[str]:
    # HTML이 들어오면 태그를 대충 제거
    text = re.sub(r"<[^>]+>", "\n", text)
    # 불릿/아이콘 제거
    text = re.sub(r"[•\-*▶️▪️·]+\s*", "", text)
    lines = [re.sub(r"\s+", " ", ln).strip() for ln in text.splitlines()]
    return [ln for ln in lines if ln]


def _split_sections(lines: List[str]) -> Dict[str, List[str]]:
    # 섹션 헤더 후보
    headers = [
        ("breakfast", ["아침", "조식", "Breakfast"]),
        ("lunchA", ["점심A", "중식A", "점A"]),
        ("lunchB", ["점심B", "중식B", "점B"]),
        ("snack", ["간편식", "플러스바", "식간", "주말 점심 간편식"]),
        ("lunch", ["점심", "중식", "Lunch"]),
        ("dinner", ["저녁", "석식", "Dinner"]),
    ]

    indices: List[Tuple[str, int]] = []
    for idx, ln in enumerate(lines):
        token = ln.replace(" ", "")
        for key, names in headers:
            if any(token.startswith(name) for name in names):
                indices.append((key, idx))
                break

    if not indices:
        return {}

    # 구간화
    sections: Dict[str, List[str]] = {}
    for i, (key, start) in enumerate(indices):
        end = indices[i + 1][1] if i + 1 < len(indices) else len(lines)
        sections[key] = lines[start:end]
    return sections


def _extract_meal(lines: List[str]) -> Meal:
    joined = " ".join(lines)
    kcal_match = KCAL_RE.search(joined)
    kcal = int(kcal_match.group(1)) if kcal_match else None

    # 항목 라인(첫줄 타이틀/헤더 제거)
    body = lines[1:] if lines else []
    items: List[str] = []
    notes: List[str] = []
    for ln in body:
        # 칼로리 표기는 건너뜀
        if KCAL_RE.search(ln):
            continue
        # 라벨성 짧은 단어는 notes로 분리
        if any(tag in ln for tag in ["우유", "샐러드", "소스", "후식", "단무지", "김치", "주스"]):
            notes.append(ln)
            continue
        items.append(ln)

    return Meal(items=items, kcal=kcal, notes=notes)


def parse_day_text(text: str, weekend: bool = False) -> DayMeals:
    lines = _clean_lines(text)
    sections = _split_sections(lines)

    # 주말은 점심/저녁만 보장. 그래도 섹션 탐지 실패 시 빈 값 유지
    if weekend:
        lunch_lines = sections.get("lunchA") or sections.get("lunch") or []
        dinner_lines = sections.get("dinner") or []
        return DayMeals(
            breakfast=None,
            lunchA=_extract_meal(lunch_lines) if lunch_lines else None,
            lunchB=None,
            snack=_extract_meal(sections.get("snack", [])) if sections.get("snack") else None,
            dinner=_extract_meal(dinner_lines) if dinner_lines else None,
        )

    # 평일: 아침/점심A/점심B/저녁을 최대한 채움
    return DayMeals(
        breakfast=_extract_meal(sections.get("breakfast", [])) if sections.get("breakfast") else None,
        lunchA=_extract_meal(sections.get("lunchA", [])) if sections.get("lunchA") else None,
        lunchB=_extract_meal(sections.get("lunchB", [])) if sections.get("lunchB") else None,
        snack=_extract_meal(sections.get("snack", [])) if sections.get("snack") else None,
        dinner=_extract_meal(sections.get("dinner", [])) if sections.get("dinner") else None,
    )


__all__ = ["parse_day_text"]

