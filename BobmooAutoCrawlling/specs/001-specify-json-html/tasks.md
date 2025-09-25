# Tasks: 대학 식단 크롤링 → 표준 JSON 변환 (Gemini 2.5 Flash)

FEATURE_DIR: `/Users/soseoyo/Documents/Programming/Project/Bobmoo/specs/001-specify-json-html`
INPUT SPEC: `/Users/soseoyo/Documents/Programming/Project/Bobmoo/specs/001-specify-json-html/spec.md`
PLAN: `/Users/soseoyo/Documents/Programming/Project/Bobmoo/specs/001-specify-json-html/plan.md`

## Numbered Tasks (Dependency-Ordered)

T001. 프로젝트 스캐폴딩 및 의존성 설치 [P]
- Files: `/Users/soseoyo/Documents/Programming/Project/Bobmoo/BobmooAutoCrawlling/requirements.txt`, `app/__init__.py`, `app/`
- Actions:
  - requirements.txt 작성: requests, beautifulsoup4, lxml, charset-normalizer, google-generativeai, jsonschema, selenium, webdriver-manager
  - 패키지 구조 생성: `app/fetcher.py`, `app/parser_bs4.py`, `app/parser_selenium.py`, `app/normalizer.py`, `app/llm_client.py`, `app/validator.py`, `app/pipeline.py`, `app/cli.py`
  - 환경변수 로딩(.env 선택): GEMINI_API_KEY
- Agent:
  - /tasks.run T001

T002. 데이터 모델 및 스키마 파일 생성 (jsonschema) [P]
- Files: `app/schema.py`, `schemas/standard.json`
- Actions:
  - `data-model.md`의 JSON Schema를 코드/파일로 반영
  - `validator.py`에서 파일 기반 로딩 지원
- Agent: /tasks.run T002

T003. fetcher 구현 (requests + 재시도 + 인코딩 정규화)
- Files: `app/fetcher.py`
- Actions:
  - 3회 지수백오프, 압축/리다이렉트 지원, charset-normalizer 적용
  - 원본 bytes, 정규화된 str, 최종 encoding 반환
- Depends: T001

T004. bs4 파서 구현 (테이블/리스트/카드 탐지, 후보 추출)
- Files: `app/parser_bs4.py`
- Actions:
  - 시맨틱 키워드 기반 섹션 분할(학생/생활관/교직원/메뉴/가격/시간)
  - 후보 구조 추출(식당명/시간/코스/메뉴/가격)
- Depends: T003

T005. 정규화 유틸 구현 (가격/시간/텍스트)
- Files: `app/normalizer.py`
- Actions:
  - 가격 숫자화, 시간 HH:MM-HH:MM 표준화, 공백/기호 정리
- Depends: T004

T006. Gemini 클라이언트 구현 (2.5 Flash, 프롬프트 템플릿, 재시도)
- Files: `app/llm_client.py`, `specs/001-specify-json-html/contracts/gemini-prompt.md`
- Actions:
  - 요약 입력 생성, 모델 호출(2회 재시도), 코드블록 금지
  - 응답 JSON 파싱 및 에러 메시지 포함 재프롬프트
- Depends: T005

T007. 스키마 검증 및 자동 보정
- Files: `app/validator.py`, `schemas/standard.json`
- Actions:
  - jsonschema 검증, 간단 보정(가격 문자열→숫자, 시간 정규화)
- Depends: T006

T008. 셀레니움 파서 구현 (Headless, 명시적 대기)
- Files: `app/parser_selenium.py`
- Actions:
  - WebDriver Manager 사용, 특정 키워드/셀렉터 대기 후 HTML 추출
  - bs4 파이프라인 재사용
- Depends: T004

T009. 오케스트레이션 파이프라인 구현
- Files: `app/pipeline.py`
- Actions:
  - `transform_from_url(url)` 구현: fetch→bs4→LLM→검증→폴백(selenium)→검증→저장
  - 저장 경로: `out/{school}/{date}.json`
- Depends: T007, T008

T010. CLI 구현 및 Quickstart 연동
- Files: `app/cli.py`, `README.md`
- Actions:
  - `python -m app.cli "<url>" --out out/` 지원
  - Quickstart 예제 반영
- Depends: T009

T011. 계약 기반 테스트(프롬프트 계약) [P]
- Files: `tests/test_contract_prompt.py`
- Actions:
  - `contracts/gemini-prompt.md` 검증: 출력 JSON만, 필드 필수, 누락 처리
- Depends: T006

T012. 데이터 모델 테스트 [P]
- Files: `tests/test_schema.py`
- Actions:
  - `schemas/standard.json`로 예시 `jsonExample.json` 검증
- Depends: T002

T013. 통합 테스트 (샘플 학교 2곳) [P]
- Files: `tests/test_integration.py`
- Actions:
  - URL 2개에 대해 파이프라인 실행, 결과 스키마 검증
  - bs4 실패/비정상 데이터 시 셀레니움 폴백 동작 확인
- Depends: T010

T014. 성능/회귀 테스트 및 문서 마무리
- Files: `tests/`, `README.md`, `specs/001-specify-json-html/quickstart.md`
- Actions:
  - 처리 시간 측정, 회귀 스냅샷, 문서 업데이트
- Depends: T013

## Parallel Guidance
- [P] 표시된 T001, T002는 병렬 가능
- [P] T011, T012는 병렬 가능(테스트 독립)
- T003→T004→T005→T006→T007는 순차
- T008은 파서 독립적으로 병렬 진행 가능(단 통합은 T009 이후)

## Agent Commands Examples
- /tasks.run T001
- /tasks.run T002
- /tasks.run T011 [P]
- /tasks.run T012 [P]
