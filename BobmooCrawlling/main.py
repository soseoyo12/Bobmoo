from __future__ import annotations

import argparse
import configparser
import json
import os
from datetime import datetime, timedelta

from ai_providers import GeminiProvider
from review.manager import ReviewManager, ReviewItem
from review.gui_manager import GUIReviewManager
from image_cropper import crop_and_compose
from schemas import Meals


def _meals_to_rows(meals: Meals, date_str: str, school: str, cafeteria_name: str, fixed_price: int) -> list[tuple]:
    """Meals를 DB 인서트용 튜플 리스트로 변환한다.

    포맷: (date, school, cafeteria_name, meal_type, course, mainMenu, price)
    meal_type ∈ {BREAKFAST, LUNCH, DINNER}
    price는 고정값(fixed_price)을 사용한다.
    """
    rows: list[tuple] = []
    for meal_type, courses in [("BREAKFAST", meals.breakfast), ("LUNCH", meals.lunch), ("DINNER", meals.dinner)]:
        for c in courses:
            rows.append((
                date_str,
                school,
                cafeteria_name,
                meal_type,
                c.course,
                c.mainMenu,
                fixed_price,
            ))
    return rows


def _escape_sql_string(value) -> str:
    """SQL 문자열 이스케이프 (작은따옴표를 두 개로 변환)"""
    if value is None:
        return "NULL"
    # 작은따옴표(')를 두 개('')로 변환하여 SQL injection 방지
    escaped = str(value).replace("'", "''")
    return f"'{escaped}'"


def _rows_to_sql(rows: list[tuple], table_name: str = "meal") -> str:
    """튜플 리스트를 SQL INSERT 문으로 변환한다.
    
    Args:
        rows: (date, school, cafeteria_name, meal_type, course, mainMenu, price) 형태의 튜플 리스트
        table_name: 테이블 이름 (기본값: "meal")
    
    Returns:
        SQL INSERT 문 문자열
    """
    if not rows:
        return ""
    
    processed_date = None
    sql_lines = [f"INSERT INTO {table_name} (date, school, cafeteria_name, meal_type, course, mainMenu, price) VALUES"]
    
    for i, row in enumerate(rows):
        # SQL injection 방지를 위해 값들을 이스케이프 처리
        date_val = _escape_sql_string(row[0]) if row[0] else "NULL"
        school_val = _escape_sql_string(row[1]) if row[1] else "NULL"
        cafeteria_val = _escape_sql_string(row[2]) if row[2] else "NULL"
        meal_type_val = _escape_sql_string(row[3]) if row[3] else "NULL"
        course_val = _escape_sql_string(row[4]) if row[4] else "NULL"
        mainMenu_val = _escape_sql_string(row[5]) if row[5] else "NULL"
        price_val = str(row[6]) if row[6] is not None else "NULL"
        
        # 날짜가 변경되면 주석 추가
        if not processed_date or processed_date != date_val:
            if processed_date:
                sql_lines.append("")
            sql_lines.append(f"-- {row[0]}")
            processed_date = date_val
        
        # 마지막 행이 아니면 콤마 추가
        comma = "," if i < len(rows) - 1 else ";"
        sql_lines.append(f"  ({date_val}, {school_val}, {cafeteria_val}, {meal_type_val}, {course_val}, {mainMenu_val}, {price_val}){comma}")
    
    return "\n".join(sql_lines)


def run_pipeline(image_path: str, out_dir: str, week_start: str | None = None, review: bool = False, auto_open_image: bool = False, rows_only: bool = False, use_gui: bool = False):
    crops_dir = os.path.join(out_dir, "crops")
    os.makedirs(out_dir, exist_ok=True)

    crop_paths = crop_and_compose(image_path, crops_dir)

    # config.ini 로드 (생활관 식당 고정 값)
    cfg = configparser.ConfigParser()
    cfg.read(os.path.join(os.path.dirname(__file__), "config.ini"), encoding="utf-8")
    school = cfg.get("settings", "school", fallback="인하대학교")
    cafeteria_name = cfg.get("settings", "cafeteria_name", fallback="생활관식당")
    fixed_price = cfg.getint("settings", "price", fallback=5600)

    # GeminiProvider 인스턴스 생성 (다형성을 활용)
    provider = GeminiProvider()
    if review:
        reviewer = GUIReviewManager(auto_open_image=auto_open_image) if use_gui else ReviewManager(auto_open_image=auto_open_image)
    else:
        reviewer = None
    
    all_rows: list[tuple] = []
    # for문 돌면서 월~일 요일마다 이미지 하나 분석
    for idx, crop_path in enumerate(crop_paths):
        # GeminiProvider를 사용하여 이미지 분석 및 정규화
        # 다형성을 활용: analyze_and_normalize() 메서드가 자동으로 정규화 처리
        meals = provider.analyze_and_normalize(crop_path, fixed_price)
        print(f"[{provider.get_provider_name()}] {crop_path} 분석 완료")
        # print(meals)

        # 선택적 검토 단계
        if reviewer is not None:
            # 원시 JSON 문자열(저장을 위해) 생성
            raw_json = json.dumps(meals.model_dump(), ensure_ascii=False, indent=2)
            action, updated = reviewer.review(ReviewItem(image_path=crop_path, meals=meals, raw_json=raw_json))
            if action == "quit":
                break
            if action == "skip":
                # 이 날은 건너뜀
                continue
            if action == "retry":
                # 한 번 더 시도 후 다시 검토 루프로 들어감
                meals = provider.analyze_and_normalize(crop_path)
                # 두 번째 결과 바로 한번 더 검토
                raw_json = json.dumps(meals.model_dump(), ensure_ascii=False, indent=2)
                action2, updated2 = reviewer.review(ReviewItem(image_path=crop_path, meals=meals, raw_json=raw_json))
                if action2 in ("skip", "quit"):
                    if action2 == "quit":
                        break
                    else:
                        continue
                meals = updated2 or meals
            elif action == "approve":
                meals = updated or meals
        
        date_str = ""
        if week_start and idx < 7:
            try:
                dt = datetime.fromisoformat(week_start) + timedelta(days=idx)
                date_str = str(dt.date())
            except Exception:
                date_str = ""
        
        # DB 튜플 포맷 생성 및 sql 파일 저장
        rows = _meals_to_rows(meals, date_str or f"day{idx+1}", school, cafeteria_name, fixed_price)
        all_rows.extend(rows)
        # for r in rows:
        #     # ('2025-11-03', '인하대학교', '생활관식당', 'BREAKFAST', 'A', '함박스테이크, ...', 5600),
        #     print(repr(r) + ",")
    
    # 모든 rows를 SQL 파일로 저장
    if all_rows:
        sql_content = _rows_to_sql(all_rows)
        sql_file_path = os.path.join(out_dir, "insert.sql")
        with open(sql_file_path, "w", encoding="utf-8") as f:
            f.write(sql_content)
        print(f"\nSQL 파일이 저장되었습니다: {sql_file_path}")


def main():
    parser = argparse.ArgumentParser(description="주간 식단 PNG → JSON 추출")
    parser.add_argument("--image", required=True, help="주간 식단 PNG 경로")
    parser.add_argument("--out", default="out", help="출력 디렉터리")
    parser.add_argument("--week", default=None, help="주간 시작일(월) ISO 날짜, e.g. 2025-10-27")
    parser.add_argument("--review", action="store_true", help="검토 모드 활성화")
    parser.add_argument("--open-image", action="store_true", help="검토 시 이미지 자동 열기")
    parser.add_argument("--gui", action="store_true", help="GUI 모드로 검토 (--review와 함께 사용)")
    args = parser.parse_args()

    run_pipeline(
        args.image,
        args.out,
        args.week,
        review=args.review,
        auto_open_image=args.open_image,
        use_gui=args.gui,
    )

if __name__ == "__main__":
    main()
