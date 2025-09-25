## Implementation Plan: 대학 식단 크롤링 → 표준 JSON 변환 (Gemini 2.5 Flash)

### Technical Context
- **언어/런타임**: Python 3.11+
- **크롤러**: requests, charset-normalizer, brotli/zstd 지원
- **파서 1차**: BeautifulSoup4(bs4) + lxml
- **파서 2차(폴백)**: Selenium + Chrome(headless) + WebDriver Manager
- **LLM**: Google Gemini 2.5 Flash (Generative Language API)
- **검증**: jsonschema
- **출력 스키마**: `jsonExample.json` 준수
- **트리거 규칙(셀레니움)**: 1) 추출 데이터가 빈 값, 2) 식단 구조가 비정상(코스/메뉴/가격 누락 등으로 스키마 검증 실패)

### Architecture
1. fetcher: URL → HTML(bytes), 인코딩 감지/정규화
2. parser_bs4: HTML → semi-structured blocks(식당/시간/메뉴/가격 후보)
3. normalizer: 문자열 정규화(통화, 공백, 시간), 후보 데이터 요약
4. llm_client: Gemini 2.5 Flash 호출, 프롬프트 템플릿 적용
5. validator: JSON Schema 검증 + 보정 규칙
6. fallback_or_export:
   - 실패 시: selenium_parser → 동일 파이프라인 재시도
   - 성공 시: out/{school}/{date}.json 저장

### Execution Flow (gate 포함)
- Step 0. 입력 URL 수신, 출력 경로 구성
- Step 1. requests로 HTML 수신(3회 지수백오프), 인코딩 정규화
- Step 2. bs4 파싱으로 섹션/테이블/리스트에서 식단 후보 추출
- Step 3. 후보를 요약해 프롬프트 입력 생성, Gemini 호출(최대 2회 재시도)
- Step 4. JSON 파싱 및 Schema 검증. 실패 시 자동 보정 1차 시도
- Step 5. 여전히 실패거나 데이터 빈약/비정상 → selenium 파이프라인 재수행
- Step 6. 성공 결과 저장 및 로깅(원본/요약/응답)

### Error/Retry Policy
- HTTP: 3회, 0.5s→1s→2s 백오프
- Gemini: 2회, 1s→2s 백오프, 안전출력(코드블록 금지) 강제
- Schema: 자동 보정(가격 숫자화, 시간 정규화) 후 최종 실패 시 오류 반환

### Deliverables
- 라이브러리: `transform_from_url(url) -> dict`
- CLI: `python -m app.cli <url> --out out/`
- 문서: research.md, data-model.md, contracts/, quickstart.md, tasks.md

### Progress Tracking
- Phase 0: Research → 완료 시 체크
- Phase 1: Data model, Contracts, Quickstart → 완료 시 체크
- Phase 2: Tasks 보드 → 완료 시 체크

[Progress]
- Phase 0: PENDING
- Phase 1: PENDING
- Phase 2: PENDING
