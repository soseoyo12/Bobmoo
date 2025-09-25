# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass, field
from typing import List, Dict, Any
from bs4 import BeautifulSoup
import re


@dataclass
class MealCandidate:
    course: str
    mainMenu: str
    price: str


@dataclass
class CafeteriaCandidate:
    name: str
    hours: Dict[str, str] = field(default_factory=dict)
    meals: Dict[str, List[MealCandidate]] = field(default_factory=dict)


HOUR_KEYS = {
    "breakfast": ["조식", "아침", "breakfast"],
    "lunch": ["중식", "점심", "lunch"],
    "dinner": ["석식", "저녁", "dinner"],
}

NAME_HINTS = [
    ("생활관", "생활관식당"),
    ("기숙사", "생활관식당"),
    ("학생", "학생식당"),
    ("교직원", "교직원식당"),
]


def _extract_text(el) -> str:
    return re.sub(r"\s+", " ", el.get_text(" ", strip=True)) if el else ""


def parse_bs4(html: str) -> List[CafeteriaCandidate]:
    soup = BeautifulSoup(html, "lxml")

    # Heuristic: find sections by headings
    sections = []
    for heading in soup.select("h1, h2, h3, h4, h5, h6"):
        title = _extract_text(heading)
        if any(k in title for k, _ in NAME_HINTS):
            # capture following sibling block
            container = heading.find_next_sibling()
            sections.append((title, container))

    candidates: List[CafeteriaCandidate] = []

    for title, container in sections:
        mapped = None
        for k, v in NAME_HINTS:
            if k in title:
                mapped = v
                break
        caf = CafeteriaCandidate(name=mapped or title)

        # Hours: look for time patterns in container
        if container:
            text = _extract_text(container)
            for hk, keys in HOUR_KEYS.items():
                if any(key in text for key in keys):
                    m = re.search(r"(\d{1,2}:\d{2})\s*[~-]\s*(\d{1,2}:\d{2})", text)
                    if m:
                        caf.hours[hk] = f"{m.group(1)}-{m.group(2)}"

            # Meals: search tables and lists
            for table in container.select("table"):
                # naive parse rows: course, menu, price columns detection
                for tr in table.select("tr"):
                    cells = [_extract_text(td) for td in tr.select("th,td")]
                    if len(cells) < 2:
                        continue
                    row = " ".join(cells)
                    # detect meal period
                    period = None
                    for hk, keys in HOUR_KEYS.items():
                        if any(key in row for key in keys):
                            period = hk
                            break
                    # extract price
                    price = ""
                    m = re.search(r"([0-9][0-9,]*)\s*(원|￦)?", row)
                    if m:
                        price = m.group(1)
                    # extract course and menu
                    course = ""
                    if re.search(r"\bA\b|\bB\b|\bC\b", row):
                        m2 = re.search(r"\b([A-C])\b", row)
                        if m2:
                            course = m2.group(1)
                    mainMenu = cells[1] if len(cells) >= 2 else row
                    if period:
                        caf.meals.setdefault(period, []).append(
                            MealCandidate(course=course or "A", mainMenu=mainMenu, price=price)
                        )

            # List-based menus
            for ul in container.select("ul, ol"):
                for li in ul.select("li"):
                    text = _extract_text(li)
                    period = None
                    for hk, keys in HOUR_KEYS.items():
                        if any(key in text for key in keys):
                            period = hk
                            break
                    if not period:
                        continue
                    price = ""
                    m = re.search(r"([0-9][0-9,]*)\s*(원|￦)?", text)
                    if m:
                        price = m.group(1)
                    caf.meals.setdefault(period, []).append(
                        MealCandidate(course="A", mainMenu=text, price=price)
                    )

        candidates.append(caf)

    return candidates

