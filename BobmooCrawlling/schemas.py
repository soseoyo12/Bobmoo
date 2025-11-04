from __future__ import annotations

from typing import List
from pydantic import BaseModel, Field


class Course(BaseModel):
    course: str
    mainMenu: str
    price: int


class Hours(BaseModel):
    breakfast: str
    lunch: str
    dinner: str


class Meals(BaseModel):
    breakfast: List[Course] = Field(default_factory=list)
    lunch: List[Course] = Field(default_factory=list)
    dinner: List[Course] = Field(default_factory=list)


class Cafeteria(BaseModel):
    name: str
    hours: Hours
    meals: Meals


class DailyMenu(BaseModel):
    date: str
    school: str
    cafeterias: List[Cafeteria]


__all__ = [
    "Course",
    "Hours",
    "Meals",
    "Cafeteria",
    "DailyMenu",
]
