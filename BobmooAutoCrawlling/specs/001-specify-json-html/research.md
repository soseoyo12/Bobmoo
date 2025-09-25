## Phase 0: Research

### Constraints & Considerations
- 다양한 학식 페이지 구조(표/리스트/카드). 정적 DOM만으로는 누락 가능 → Selenium 폴백 필요
- 인코딩: UTF-8/EUC-KR 혼재. charset-normalizer + 수동 지정 폴백
- 가격/시간 표기 다양: "5,500원", "11:30~13:30", "점심: 11-14"
- 날짜: 주간표/일간표 혼재, 주차/요일 텍스트에서 날짜 계산 필요 가능

### LLM Prompting Notes (Gemini 2.5 Flash)
- 입력 HTML 원문 전체 전달은 비효율 → 섹션 요약/정규화 후 전달
- 출력은 JSON만, 코드블록 금지, 스키마 명시로 포맷 안정화
- 실패 시: 에러 메시지 포함 재프롬프트로 수렴 유도

### Selenium Usage
- headless Chrome, implicit 0, explicit wait for key selectors (e.g., table/menu keywords)
- 로딩 후 `document.readyState` 및 특정 키워드 가시성 체크

### Success Criteria
- 두 개 이상의 서로 다른 학교 URL에서 스키마 일치 JSON 산출
- 가격/시간 정규화 일관성 유지(숫자/HH:MM-HH:MM)
