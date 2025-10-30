from __future__ import annotations

import argparse
import configparser
import json
import os
from datetime import datetime, timedelta

from ai_api import ocr_image_text
from extract import parse_day_text
from image_cropper import crop_and_compose
from schemas import WeekMenu, DayMenu


def _infer_week_range(start_monday: str | None) -> str | None:
    if not start_monday:
        return None
    try:
        dt = datetime.fromisoformat(start_monday)
    except Exception:
        return None
    end = dt + timedelta(days=4)
    return f"{dt.date()}~{end.date()}"


def run_pipeline(image_path: str, out_dir: str, week_start: str | None = None) -> str:
    crops_dir = os.path.join(out_dir, "crops")
    os.makedirs(out_dir, exist_ok=True)

    crop_paths = crop_and_compose(image_path, crops_dir)
    weekdays_kr = ["월", "화", "수", "목", "금", "토", "일"]

    # config.ini 로드 (생활관 식당 고정 값)
    cfg = configparser.ConfigParser()
    cfg.read(os.path.join(os.path.dirname(__file__), "config.ini"), encoding="utf-8")
    school = cfg.get("settings", "school", fallback="인하대학교")
    cafeteria_name = cfg.get("settings", "cafeteria_name", fallback="생활관식당")
    fixed_price = cfg.getint("settings", "price", fallback=5600)
    hours = {
        "breakfast": cfg.get("hours", "breakfast", fallback="07:30-09:00"),
        "lunch": cfg.get("hours", "lunch", fallback="11:30-13:30"),
        "dinner": cfg.get("hours", "dinner", fallback="17:30-19:30"),
    }

    days: list[DayMenu] = []
    for idx, crop_path in enumerate(crop_paths):
        is_weekend = idx >= 5  # 0..6 -> 토(5), 일(6)
        text = ocr_image_text(crop_path)
        meals = parse_day_text(text, weekend=is_weekend)
        date_str = None
        if week_start and idx < 7:
            try:
                dt = datetime.fromisoformat(week_start) + timedelta(days=idx)
                date_str = str(dt.date())
            except Exception:
                date_str = None
        days.append(DayMenu(date=date_str, weekday=weekdays_kr[idx], meals=meals))

        # 백엔드 스키마(JSON)로도 일자별 파일 저장
        # meals -> 코스 배열로 매핑(A/B 강제, 가격은 고정값)
        def meal_to_courses(meal, course_label="A"):
            if meal is None:
                return []
            main_menu = ", ".join(meal.items) if meal.items else ""
            return [
                {"course": course_label, "mainMenu": main_menu, "price": fixed_price}
            ]

        backend_json = {
            "date": date_str or "",
            "school": school,
            "cafeterias": [
                {
                    "name": cafeteria_name,
                    "hours": hours,
                    "meals": {
                        "breakfast": meal_to_courses(meals.breakfast, "A"),
                        "lunch": (
                            meal_to_courses(meals.lunchA, "A") +
                            meal_to_courses(meals.lunchB, "B") +
                            meal_to_courses(meals.snack, "간편식")
                        ),
                        "dinner": meal_to_courses(meals.dinner, "A"),
                    },
                }
            ],
        }
        per_day_path = os.path.join(out_dir, f"{date_str or f'day{idx+1}'}.json")
        with open(per_day_path, "w", encoding="utf-8") as f:
            json.dump(backend_json, f, ensure_ascii=False, indent=2)

    data = WeekMenu(week_range=_infer_week_range(week_start), days=days)
    out_json = os.path.join(out_dir, f"menu_{(week_start or 'unknown')}.json")
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(data.model_dump(), f, ensure_ascii=False, indent=2)
    return out_json


def main():
    parser = argparse.ArgumentParser(description="주간 식단 PNG → JSON 추출")
    parser.add_argument("--image", required=True, help="주간 식단 PNG 경로")
    parser.add_argument("--out", default="out", help="출력 디렉터리")
    parser.add_argument("--week", default=None, help="주간 시작일(월) ISO 날짜, e.g. 2025-10-27")
    args = parser.parse_args()

    out_json = run_pipeline(args.image, args.out, args.week)
    print(out_json)


if __name__ == "__main__":
    main()
