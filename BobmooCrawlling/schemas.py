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


class MealRecord(BaseModel):
    """DB `meal` 테이블 인서트용으로 사용하는 납작한(one-row) 레코드 모델."""
    date: str
    school: str
    cafeteria_name: str
    meal_type: str
    course: str
    mainMenu: str
    price: int


__all__ = [
    "Course",
    "Meals",
    "MealRecord",
]
