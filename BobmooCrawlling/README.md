# BobmooCrawlling – 인하대 생활관 주간 식단 이미지 → JSON 추출

주간 식단 PNG를 자동으로 열(구분+월~일) 단위로 자르고, 각 요일 이미지를 OCR하여 하루 단위 JSON과 주간 요약 JSON을 생성합니다. 점심은 코스 A/B(+간편식)로 출력합니다.

## 준비물
- Python 3.10+
- Pillow, requests, pydantic, python-dotenv (필요시 설치)
- Upstage API Key (`local.env` 파일에 저장)

```env
# 프로젝트 루트의 local.env
API_KEY=YOUR_UPSTAGE_API_KEY
```

고정 설정은 `config.ini`로 관리합니다.

```ini
[settings]
school=인하대학교
cafeteria_name=생활관식당
price=5600

[hours]
breakfast=07:30-09:00
lunch=11:30-13:30
dinner=17:30-19:30
```

## 설치
```bash
pip install pillow requests pydantic python-dotenv
```

## 실행 방법
```bash
python main.py --image path/to/menu.png --out out --week 2025-10-27
```
- `--image`: 주간 식단 PNG 경로
- `--out`: 출력 디렉터리(기본 `out`)
- `--week`: 월요일 날짜(ISO). 예: `2025-10-27`

### 출력물
- `out/crops/mon.png` … `sun.png`: 구분+요일 합성 이미지(7장)
- `out/2025-10-27.json` … `out/2025-11-02.json`: 하루 단위 백엔드 스키마 JSON
- `out/menu_2025-10-27.json`: 주간 요약 JSON(내부 스키마)

하루 JSON 예시(백엔드 스키마)
```json
{
  "date": "2025-10-30",
  "school": "인하대학교",
  "cafeterias": [
    {
      "name": "생활관식당",
      "hours": {
        "breakfast": "07:30-09:00",
        "lunch": "11:30-13:30",
        "dinner": "17:30-19:30"
      },
      "meals": {
        "breakfast": [{"course": "A", "mainMenu": "...", "price": 5600}],
        "lunch": [
          {"course": "A", "mainMenu": "...", "price": 5600},
          {"course": "B", "mainMenu": "...", "price": 5600},
          {"course": "간편식", "mainMenu": "...", "price": 5600}
        ],
        "dinner": [{"course": "A", "mainMenu": "...", "price": 5600}]
      }
    }
  ]
}
```

## 워크플로우
1. `image_cropper.crop_and_compose`로 입력 PNG를 8열(구분+월~일) 비율 크롭 후, 구분 열과 각 요일 열을 합성하여 7장의 요일 이미지를 생성합니다.
2. 각 요일 이미지를 `ai_api.ocr_image_text`로 OCR(Upstage document-parse)합니다.
3. OCR 텍스트를 `extract.parse_day_text`로 파싱하여 섹션별(아침/점심A/점심B/간편식/저녁) 메뉴·kcal·비고를 추출합니다.
4. `main.run_pipeline`이
   - 주간 요약 JSON(`schemas.WeekMenu`)을 생성/저장하고,
   - 동시에 하루 단위 백엔드 스키마 JSON을 생성/저장합니다.

## 모듈/함수 설명

### `image_cropper.py`
- `crop_and_compose(input_image_path, output_dir, *, left_margin_ratio=0.018, right_margin_ratio=0.018, top_margin_ratio=0.0, bottom_margin_ratio=0.0, col_ratios=None, background_color=(255,255,255)) -> List[str]`
  - 주간 식단 이미지를 비율 기반으로 8열로 크롭한 뒤, 구분 열+요일 열을 가로로 붙여 월~일까지 7장의 이미지를 생성합니다.
  - 반환값: 생성된 이미지 경로 리스트(`[mon.png, ..., sun.png]`).

### `ai_api.py`
- `call_document_parse(input_file) -> dict`
  - Upstage `document-digitization` API 호출 결과 원문 JSON 반환.
- `ocr_image_text(input_file) -> str`
  - `content.text`가 있으면 텍스트, 없으면 `content.html`을 평문화하여 반환.

### `extract.py`
- `parse_day_text(text: str, weekend: bool = False) -> schemas.DayMeals`
  - 텍스트를 라인 정제 후 섹션 헤더를 기준으로 분리하여 `DayMeals` 구성.
  - 인식 섹션: 아침/점심A/점심B/간편식/저녁. 주말일 경우 아침은 생략 가능.

### `schemas.py`
- `Meal(items: List[str], kcal: Optional[int], notes: List[str])`
- `DayMeals(breakfast, lunchA, lunchB, snack, dinner)`
- `DayMenu(date, weekday, meals)`
- `WeekMenu(campus, week_range, days)`

### `main.py`
- `run_pipeline(image_path, out_dir, week_start) -> str`: 전체 파이프라인 실행 후 주간 요약 JSON 경로 반환. 동시에 하루 단위 백엔드 스키마 JSON들을 `out/`에 저장.
- CLI 엔트리포인트: `python main.py --image ... --out ... --week ...`

## 팁/트러블슈팅
- 비율 크롭이 어긋나면 `image_cropper.crop_and_compose`의 `left/right/top/bottom_margin_ratio`나 `col_ratios`를 조정하세요.
- OCR 품질이 낮을 때는 입력 해상도를 높이거나, 원본 대비 선명한 PNG를 사용해 주세요.
- `local.env`의 API 키가 없으면 `config.getAPIkey()`에서 예외가 발생합니다.

## 라이선스
사내/개인 용도에 맞게 사용하세요.
