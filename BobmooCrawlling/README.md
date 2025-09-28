# 웹 스크래핑 및 메뉴 정보 추출 프로그램

Playwright와 Gemini API를 사용하여 웹사이트에서 식당 메뉴 정보를 추출하고 JSON 형태로 저장하는 프로그램입니다.

## 기능

- Playwright를 사용한 동적 웹사이트 스크래핑
- Gemini API를 통한 HTML 텍스트 분석 및 JSON 변환
- **여러 URL 동시 처리**: 한 번에 여러 식당 링크를 입력하여 모든 식당 정보를 하나의 JSON에 병합
- **날짜별 자동 파일 저장**: 각 날짜별로 모든 식당 정보가 포함된 JSON 파일 생성
- **자동 병합 기능**: 기존 파일이 있으면 새로운 식당 정보를 자동으로 추가
- **정확한 형식 준수**: jsonExample.json과 동일한 형식으로 데이터 생성
- 한국어 메뉴명 지원

## 설치

1. 의존성 설치:
```bash
pip install -r requirements.txt
```

2. Playwright 브라우저 설치:
```bash
playwright install chromium
```

3. 환경 변수 설정:
`.env` 파일을 생성하고 Gemini API 키를 설정하세요:
```
GEMINI_API_KEY=your_gemini_api_key_here
```

## 사용법

### 기본 사용법 (단일 URL)
```bash
python3 main.py "https://example.com/menu"
```

### 여러 URL 사용법 (권장)
```bash
python3 main.py "https://example.com/cafeteria1" "https://example.com/cafeteria2" "https://example.com/cafeteria3"
```

### 실제 사용 예시 (인하대학교)
```bash
python3 main.py "https://www.inha.ac.kr/kr/1072/subview.do" "https://www.inha.ac.kr/kr/1073/subview.do" --school "인하대학교"
```

### 옵션 사용법
```bash
python3 main.py "https://example.com/menu1" "https://example.com/menu2" --school "서울대학교" --output "results" --wait 5000
```

### 명령어 옵션
- `urls`: 스크래핑할 웹사이트 URL들 (여러 개 가능, 필수)
- `--school`, `-s`: 학교 이름 (기본값: 인하대학교)
- `--output`, `-o`: 출력 디렉토리 (기본값: output)
- `--wait`, `-w`: 페이지 로딩 대기 시간(밀리초) (기본값: 3000)

## 출력 형식

프로그램은 `jsonExample.json`과 정확히 동일한 형식으로 JSON 파일을 생성합니다:

### 주요 특징:
- **여러 식당 지원**: 하나의 JSON 파일에 여러 식당 정보 포함
- **날짜별 파일**: 각 날짜별로 별도의 JSON 파일 생성
- **정확한 형식**: 시간은 하이픈(`-`), 메뉴는 쉼표와 띄어쓰기로 구분
- **코스 표기**: A, B, C 등 단순한 알파벳으로 표기

```json
{
    "date": "2024-09-29",
    "school": "인하대학교",
    "cafeterias": [
        {
            "name": "학생식당(학생회관)",
            "hours": {
                "breakfast": "08:00-09:00",
                "lunch": "11:00-14:00",
                "dinner": "17:00-18:30"
            },
            "meals": {
                "lunch": [
                    {
                        "course": "A",
                        "mainMenu": "제육김치볶음*두부, 쌀밥, 건파래볶음, 단무지, 배추김치",
                        "price": 5800
                    },
                    {
                        "course": "B",
                        "mainMenu": "해물빠에야볶음밥, 쌀피고구마롤, 단무지, 배추김치",
                        "price": 5800
                    }
                ]
            }
        },
        {
            "name": "교직원식당",
            "hours": {
                "breakfast": "08:20-09:20",
                "lunch": "11:20-13:30",
                "dinner": "17:20-18:20"
            },
            "meals": {
                "lunch": [
                    {
                        "course": "A",
                        "mainMenu": "오삼불고기",
                        "price": 5500
                    }
                ]
            }
        }
    ]
}
```

## 파일 구조

```
.
├── main.py              # 메인 실행 스크립트
├── web_scraper.py       # Playwright 웹 스크래핑 모듈
├── gemini_parser.py     # Gemini API 연동 및 JSON 변환 모듈
├── file_manager.py      # 파일 관리 및 병합 모듈
├── config.py            # 설정 파일 (API 키 포함)
├── requirements.txt     # 의존성 목록
├── jsonExample.json     # JSON 예시 파일 (참조 형식)
├── check_models.py      # Gemini 모델 확인 스크립트
├── test_scraper.py      # 테스트 스크립트
├── output/              # 출력 디렉토리 (날짜별 JSON 파일)
└── scraper.log          # 로그 파일
```

## 주요 개선사항

### v2.0 업데이트
- ✅ **여러 URL 동시 처리**: 한 번에 여러 식당 링크를 입력하여 모든 식당 정보를 하나의 JSON에 병합
- ✅ **자동 병합 기능**: 기존 파일이 있으면 새로운 식당 정보를 자동으로 추가
- ✅ **정확한 형식 준수**: jsonExample.json과 완전히 동일한 형식으로 데이터 생성
- ✅ **날짜별 파일 생성**: 각 날짜별로 모든 식당 정보가 포함된 완전한 JSON 파일 생성
- ✅ **향상된 프롬프트**: Gemini API가 정확한 형식으로 데이터를 추출하도록 최적화

## 주의사항

1. Gemini API 키가 필요합니다.
2. 웹사이트의 이용약관을 준수하여 사용하세요.
3. 동적 콘텐츠가 많은 사이트의 경우 `--wait` 옵션으로 대기 시간을 늘려보세요.
4. 로그는 `scraper.log` 파일에 저장됩니다.

## 문제 해결

- **Playwright 오류**: `playwright install chromium` 명령어를 실행하세요.
- **Gemini API 오류**: API 키가 올바르게 설정되었는지 확인하세요.
- **스크래핑 실패**: `--wait` 옵션으로 대기 시간을 늘려보세요.
