from __future__ import annotations

from typing import List
from pydantic import BaseModel, Field


class Course(BaseModel):
    """한 끼 식단 내 개별 코스 정보를 표현한다."""
    course: str
    mainMenu: str
    price: int


class Meals(BaseModel):
    """요일별로 아침/점심/저녁 코스 목록을 보관한다."""
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
