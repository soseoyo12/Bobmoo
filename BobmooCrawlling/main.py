from __future__ import annotations

import argparse
import configparser
import json
import os
from datetime import datetime, timedelta

from ai_api import ocr_image_text
from extract import parse_day_text
from image_cropper import crop_and_compose
from schemas import DailyMenu, Hours, Cafeteria


def run_pipeline(image_path: str, out_dir: str, week_start: str | None = None) -> list[str]:
    crops_dir = os.path.join(out_dir, "crops")
    os.makedirs(out_dir, exist_ok=True)

    crop_paths = crop_and_compose(image_path, crops_dir)

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

    output_paths: list[str] = []
    # for문 돌면서 월~일 요일마다 이미지 하나 분석
    for idx, crop_path in enumerate(crop_paths):
        is_weekend = idx >= 5  # 0..6 -> 토(5), 일(6)
        text = ocr_image_text(crop_path)
        meals = parse_day_text(text, weekend=is_weekend, price=fixed_price)
        
        date_str = ""
        if week_start and idx < 7:
            try:
                dt = datetime.fromisoformat(week_start) + timedelta(days=idx)
                date_str = str(dt.date())
            except Exception:
                date_str = ""
        
        # 최종 스키마 구조로 일자별 JSON 생성
        cafeteria = Cafeteria(
            name=cafeteria_name,
            hours=Hours(**hours),
            meals=meals,
        )
        
        daily_menu = DailyMenu(
            date=date_str or f"day{idx+1}",
            school=school,
            cafeterias=[cafeteria],
        )
        
        per_day_path = os.path.join(out_dir, f"{date_str or f'day{idx+1}'}.json")
        with open(per_day_path, "w", encoding="utf-8") as f:
            json.dump(daily_menu.model_dump(), f, ensure_ascii=False, indent=2)
        
        output_paths.append(per_day_path)
    
    return output_paths


def main():
    parser = argparse.ArgumentParser(description="주간 식단 PNG → JSON 추출")
    parser.add_argument("--image", required=True, help="주간 식단 PNG 경로")
    parser.add_argument("--out", default="out", help="출력 디렉터리")
    parser.add_argument("--week", default=None, help="주간 시작일(월) ISO 날짜, e.g. 2025-10-27")
    args = parser.parse_args()

    output_paths = run_pipeline(args.image, args.out, args.week)
    for path in output_paths:
        print(path)


if __name__ == "__main__":
    main()
