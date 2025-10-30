from __future__ import annotations

from typing import List, Optional, Dict
from pydantic import BaseModel, Field


class Meal(BaseModel):
    items: List[str] = Field(default_factory=list)
    kcal: Optional[int] = None
    notes: List[str] = Field(default_factory=list)


class DayMeals(BaseModel):
    breakfast: Optional[Meal] = None
    lunchA: Optional[Meal] = None
    lunchB: Optional[Meal] = None
    snack: Optional[Meal] = None  # 플러스바/간편식
    dinner: Optional[Meal] = None


class DayMenu(BaseModel):
    date: Optional[str] = None
    weekday: str
    meals: DayMeals


class WeekMenu(BaseModel):
    campus: str = "인하대 생활관"
    week_range: Optional[str] = None
    days: List[DayMenu]


def get_json_schema() -> Dict:
    return WeekMenu.model_json_schema()


__all__ = [
    "Meal",
    "DayMeals",
    "DayMenu",
    "WeekMenu",
    "get_json_schema",
]
