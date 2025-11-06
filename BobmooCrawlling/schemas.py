from __future__ import annotations

from typing import List
from pydantic import BaseModel, Field


class Course(BaseModel):
    course: str
    mainMenu: str
    price: int

class Meals(BaseModel):
    breakfast: List[Course] = Field(default_factory=list)
    lunch: List[Course] = Field(default_factory=list)
    dinner: List[Course] = Field(default_factory=list)

__all__ = [
    "Course",
    "Hours",
    "Meals",
    "Cafeteria",
    "DailyMenu",
]
