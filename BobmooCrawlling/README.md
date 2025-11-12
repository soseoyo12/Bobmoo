# BobmooCrawlling – 인하대 생활관 주간 식단 이미지 분석 로직

주간 식단 이미지를 요일별로 분해한 뒤 Gemini Vision을 이용해 메뉴 데이터를 추출하고, `MealRecord` 모델에 매핑한 후 SQL 인서트 스크립트로 정리하는 자동화 도구입니다.

## 주요 기능
- 주간 표 이미지를 월~일 7장으로 자동 크롭하고 합성합니다.
- 각 요일 이미지를 Gemini Vision API로 분석해 `Meals` 스키마로 정규화합니다.
- 정규화된 결과를 DB 레코드 형태의 `MealRecord` 리스트로 변환합니다.
- 필요하면 CLI/GUI 검토 단계를 거쳐 결과를 수정할 수 있습니다.
- 날짜별 식단을 SQL `INSERT` 문으로 저장합니다.

## 준비물
- Python 3.10 이상
- Google Gemini API 키 (환경 변수 또는 `local.env`)
- Pillow, google-genai, pydantic 등은 `requirements.txt`로 관리

## 설치
```bash
python -m venv venv
venv\Scripts\activate                # PowerShell 예시
pip install -r requirements.txt
```

## 설정
- `local.env`: API 키 저장

```env
# 프로젝트 루트
GEMINI_API_KEY=YOUR_API_KEY
```

- `config.ini`: 학교명, 식당명, 가격을 정의

```ini
[settings]
school=인하대학교
cafeteria_name=생활관식당
price=5600
```

식단 이미지는 파일명에 주간 시작일(월요일)을 포함해야 합니다. 예) `2025-11-10.png`, `20251110.png`, `2025_11_10.png`

## 실행 방법
```bash
python main.py --image test_files/2025-11-10.png --review-mode gui
```
- `--image`: 주간 식단 이미지 경로 (필수, 파일명에서 주차 시작일 추출)
- `--out`: 출력 디렉터리 (기본값 `out`)
- `--review-mode`: `none` / `cli` / `cli-auto-open` / `gui` 중 하나 선택

## 생성물
- `out/crops/mon.png` … `sun.png`: 합성된 요일별 이미지
- `out/2025-11-10_insert.sql`: 날짜가 반영된 SQL `INSERT` 스크립트 (`MealRecord` 리스트를 직렬화)
- 검토 모드에서 승인한 `Meals` 결과는 즉시 SQL에 반영됩니다

생성되는 SQL 예시:

```sql
-- 2025-11-10
INSERT INTO meal (date, school, cafeteria_name, meal_type, course, mainMenu, price) VALUES
  ('2025-11-10', '인하대학교', '생활관식당', 'BREAKFAST', 'A', '모닝브레드2종&잼', 5600),
  ('2025-11-10', '인하대학교', '생활관식당', 'LUNCH', 'A', '미라쥬주제볶음, ...', 5600);
```

## 검토 워크플로우
- `--review`를 켜면 하루 단위 결과가 터미널에 표시됩니다.
- 옵션에 따라 이미지 자동 열기, 재시도, 수동 수정(임시 JSON 편집), 건너뛰기 등을 선택할 수 있습니다.
- `--gui`를 함께 사용하면 `review/gui_manager.py`의 Tk 인터페이스로 메뉴를 조정할 수 있습니다.

## 주요 모듈
- `image_cropper.py`: 주간 표를 열 단위로 자르고 요일 이미지를 생성합니다.
- `ai_providers/gemini.py`: Gemini Vision 호출, 재시도, 응답 정규화를 담당합니다.
- `review/manager.py`, `review/gui_manager.py`: CLI/GUI 리뷰 플로우를 제공합니다.
- `schemas.py`: `Course`, `Meals`, `MealRecord` Pydantic 모델 정의.
- `main.py`: 파이프라인 엔트리포인트 및 SQL 저장 로직.

## 트러블슈팅
- 이미지 크롭이 어긋나면 `crop_and_compose`의 여백/열 비율을 조정하세요.
- 파일명에 날짜가 없으면 SQL 파일명이 `None_insert.sql`로 생성되므로 반드시 ISO 형태 날짜를 포함하세요.
- Gemini 에러가 잦으면 API 사용량과 키 설정을 확인하고 재시도 횟수(기본 5회)를 늘려보세요.
- Windows에서 검토 중 이미지 열기/메모장 편집이 동작하지 않으면 PowerShell을 관리자 권한으로 실행하거나 기본 앱 연결을 확인하세요.

## 백엔드 연동 시 참고
- `MealRecord` 모델이 DB `meal` 테이블 스키마(날짜, 학교, 식당, 식사 타입, 코스, 대표 메뉴, 가격)에 대응합니다.
- AWS 환경에서 추가 인증/저장 로직을 붙일 개발자는 `run_pipeline()`에서 생성되는 `MealRecord` 리스트 또는 SQL 문자열을 후처리하면 됩니다.
- 검토 단계가 비활성화(`--review-mode none`)되어도 SQL문 결과 파일 생성이 유지되므로 비동기로 호출해도 안정적으로 동작합니다.