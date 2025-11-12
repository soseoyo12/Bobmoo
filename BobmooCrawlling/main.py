from __future__ import annotations

import argparse
import configparser
import json
import os
import re
from datetime import datetime, timedelta
from pathlib import Path

from ai_providers import GeminiProvider
from review.manager import ReviewManager, ReviewItem
from review.gui_manager import GUIReviewManager
from image_cropper import crop_and_compose
from schemas import Meals, MealRecord


def _meals_to_meal_records(meals: Meals, date_str: str, school: str, cafeteria_name: str, fixed_price: int) -> list[MealRecord]:
    """Meals를 DB 인서트용 MealRecord 모델 리스트로 변환한다.

    Args:
        meals: 분석된 식단 데이터 (아침/점심/저녁 포함)
        date_str: 날짜 문자열 (예: "2025-11-10")
        school: 학교명
        cafeteria_name: 식당명
        fixed_price: 고정 가격값

    Returns:
        MealRecord 리스트 (각 식사 타입별 코스마다 하나의 레코드 생성)
    """
    meal_records: list[MealRecord] = []
    for meal_type, courses in [("BREAKFAST", meals.breakfast), ("LUNCH", meals.lunch), ("DINNER", meals.dinner)]:
        for course in courses:
            meal_records.append(MealRecord(
                date=date_str,
                school=school,
                cafeteria_name=cafeteria_name,
                meal_type=meal_type,
                course=course.course,
                mainMenu=course.mainMenu,
                price=fixed_price,
            ))
    return meal_records


def _escape_sql_string(value) -> str:
    """SQL 문자열 이스케이프 (작은따옴표를 두 개로 변환)"""
    if value is None:
        return "NULL"
    # 작은따옴표(')를 두 개('')로 변환하여 SQL injection 방지
    escaped = str(value).replace("'", "''")
    return f"'{escaped}'"


def _meal_records_to_sql(meal_records: list[MealRecord], table_name: str = "meal") -> str:
    """MealRecord 리스트를 SQL INSERT 문으로 변환한다.
    
    Args:
        meal_records: DB 인서트용 MealRecord 모델 리스트
        table_name: 테이블 이름 (기본값: "meal")
    
    Returns:
        SQL INSERT 문 문자열 (날짜별로 주석 구분)
    """
    if not meal_records:
        return ""
    
    processed_date = None
    sql_lines = [f"INSERT INTO {table_name} (date, school, cafeteria_name, meal_type, course, mainMenu, price) VALUES"]
    
    for idx, meal_record in enumerate(meal_records):
        # SQL injection 방지를 위해 값들을 이스케이프 처리
        date_val = _escape_sql_string(meal_record.date) if meal_record.date else "NULL"
        school_val = _escape_sql_string(meal_record.school) if meal_record.school else "NULL"
        cafeteria_val = _escape_sql_string(meal_record.cafeteria_name) if meal_record.cafeteria_name else "NULL"
        meal_type_val = _escape_sql_string(meal_record.meal_type) if meal_record.meal_type else "NULL"
        course_val = _escape_sql_string(meal_record.course) if meal_record.course else "NULL"
        mainMenu_val = _escape_sql_string(meal_record.mainMenu) if meal_record.mainMenu else "NULL"
        price_val = str(meal_record.price) if meal_record.price is not None else "NULL"
        
        # 날짜가 변경되면 주석 추가 (가독성 향상)
        if not processed_date or processed_date != date_val:
            if processed_date:
                sql_lines.append("")
            sql_lines.append(f"-- {meal_record.date}")
            processed_date = date_val
        
        # 마지막 레코드가 아니면 콤마 추가
        comma = "," if idx < len(meal_records) - 1 else ";"
        sql_lines.append(f"  ({date_val}, {school_val}, {cafeteria_val}, {meal_type_val}, {course_val}, {mainMenu_val}, {price_val}){comma}")
    
    return "\n".join(sql_lines)


def _extract_week_start_from_filename(image_path: str) -> str | None:
    """이미지 파일명에서 주간 시작일(월요일)을 추출한다.

    허용 포맷:
        - 2025-11-10.png
        - 2025_11_10.png
        - 20251110.png
    """
    stem = Path(image_path).stem
    match = re.search(r"(20\d{2})[-_]?(\d{2})[-_]?(\d{2})", stem)
    if not match:
        return None

    year, month, day = map(int, match.groups())
    try:
        return datetime(year, month, day).date().isoformat()
    except ValueError:
        return None


def run_pipeline(image_path: str, out_dir: str | None = None, review_mode: str = "none"):
    """
    주간 식단 이미지 분석 파이프라인을 실행한다.
    
    Args:
        image_path: 주간 식단 이미지 파일 경로 (필수)
        out_dir: 출력 디렉터리 (None이면 config.ini의 out_dir 사용)
        review_mode: 검토 모드 ("none", "cli", "cli-auto-open", "gui")
    """
    # config.ini 로드 (생활관 식당 고정 값)
    cfg = configparser.ConfigParser()
    cfg.read(os.path.join(os.path.dirname(__file__), "config.ini"), encoding="utf-8")
    if out_dir is None:
        out_dir = cfg.get("settings", "out_dir", fallback="out")

    crops_dir = os.path.join(out_dir, "crops")
    os.makedirs(out_dir, exist_ok=True)

    # 입력 주간 이미지를 요일별 개별 이미지로 분해
    crop_paths = crop_and_compose(image_path, crops_dir)
    # 파일명에서 월요일 날짜를 추출해 실제 날짜를 우선 사용
    week_start = _extract_week_start_from_filename(image_path)
    school = cfg.get("settings", "school", fallback="인하대학교")
    cafeteria_name = cfg.get("settings", "cafeteria_name", fallback="생활관식당")
    fixed_price = cfg.getint("settings", "price", fallback=5600)

    # GeminiProvider 인스턴스 생성 (다형성을 활용)
    provider = GeminiProvider()
    review_mode_normalized = review_mode.lower()
    if review_mode_normalized == "gui":
        reviewer = GUIReviewManager()
    elif review_mode_normalized in ("cli", "cli-auto-open"):
        auto_open_image = review_mode_normalized == "cli-auto-open"
        reviewer = ReviewManager(auto_open_image=auto_open_image)
    elif review_mode_normalized == "none":
        reviewer = None
    else:
        raise ValueError(f"지원하지 않는 review_mode 값입니다: {review_mode}")
    
    # 한 주치 식단 레코드를 누적할 리스트 (월~일 모든 요일의 MealRecord 포함)
    all_meal_records: list[MealRecord] = []
    
    # 월~일 요일마다 이미지를 하나씩 분석
    for idx, crop_path in enumerate(crop_paths):
        # GeminiProvider를 사용하여 이미지 분석 및 정규화
        # 다형성을 활용: analyze_and_normalize() 메서드가 자동으로 정규화 처리
        meals = provider.analyze_and_normalize(crop_path, fixed_price)
        print(f"[{provider.get_provider_name()}] {crop_path} 분석 완료")

        # 선택적 검토 단계 (review_mode가 "none"이 아닐 때만 실행)
        if reviewer is not None:
            # 원시 JSON 문자열(저장을 위해) 생성
            raw_json = json.dumps(meals.model_dump(), ensure_ascii=False, indent=2)
            action, updated = reviewer.review(ReviewItem(image_path=crop_path, meals=meals, raw_json=raw_json))
            # 검토자의 피드백을 액션별로 처리
            if action == "quit":
                break
            if action == "skip":
                # 이 날은 건너뜀
                continue
            if action == "retry":
                # 한 번 더 시도 후 다시 검토 루프로 들어감
                meals = provider.analyze_and_normalize(crop_path, fixed_price)
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
        
        # 파일명에서 추출한 주간 시작일(월요일)을 기준으로 실제 날짜 계산
        date_str = ""
        if week_start and idx < 7:
            try:
                dt = datetime.fromisoformat(week_start) + timedelta(days=idx)
                date_str = str(dt.date())
            except Exception:
                date_str = ""
        
        # Meals 모델을 MealRecord 리스트로 변환 (하루치 식단 → 여러 레코드)
        daily_meal_records = _meals_to_meal_records(meals, date_str or f"day{idx+1}", school, cafeteria_name, fixed_price)
        all_meal_records.extend(daily_meal_records)
    
    # 모든 MealRecord를 SQL 파일로 저장
    if all_meal_records:
        # 한 주에 해당하는 모든 MealRecord를 SQL INSERT 스크립트로 직렬화
        sql_content = _meal_records_to_sql(all_meal_records)
        sql_file_path = os.path.join(out_dir, f"{week_start.replace('-', '') if week_start else 'unknown'}_insert.sql")
        with open(sql_file_path, "w", encoding="utf-8") as f:
            f.write(sql_content)
        print(f"\nSQL 파일이 저장되었습니다: {sql_file_path}")


def main():
    parser = argparse.ArgumentParser(description="주간 식단 PNG → JSON 추출")
    parser.add_argument("--image", required=True, help="주간 식단 이미지 경로")
    parser.add_argument("--out", default=None, help="출력 디렉터리 (미지정 시 config.ini 설정 사용)")
    parser.add_argument(
        "--review-mode",
        choices=["none", "cli", "cli-auto-open", "gui"],
        default="none",
        help="검토 모드를 설정 (예: none, cli, cli-auto-open, gui)",
    )
    args = parser.parse_args()

    run_pipeline(
        args.image,
        args.out,
        review_mode=args.review_mode,
    )

if __name__ == "__main__":
    main()
