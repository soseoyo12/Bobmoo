## Feature: 대학교 식단 크롤링 및 표준 JSON 변환 파이프라인

### 목적
- **학생식당, 기숙사(생활관) 식당, 교직원 식당**의 식단 정보를 각 학교 홈페이지의 HTML에서 크롤링·파싱하여, 공통 **표준 JSON 스키마**로 변환한다.
- 타학교로의 **확장 가능성**을 전제하여, 입력은 **식단 페이지 URL 하나**만 제공받아도 동작하도록 설계한다.
- HTML 파싱 결과를 **Gemini API**로 전달하고, 적절한 **프롬프트 엔지니어링**을 통해 표준 JSON으로 가공한다.
- 최종 산출물은 예시 파일 `jsonExample.json`과 동일한 구조를 갖는 JSON 파일이다.

### 범위
- 입력: 단일 학교 식단 페이지의 **URL** (학교별 상이한 HTML 구조 고려)
- 처리: HTTP 요청 → HTML 파싱 → 텍스트 정규화 → Gemini API 프롬프트 구성/요청 → 응답 검증/후처리 → 표준 JSON 출력
- 출력: `jsonExample.json` 스키마 준수 JSON

### 표준 JSON 스키마
`/Users/soseoyo/Documents/Programming/Project/Bobmoo/BobmooAutoCrawlling/jsonExample.json`을 기준으로 필드 정의:
- **date**: 문자열(YYYY-MM-DD)
- **school**: 문자열(학교명)
- **cafeterias**: 배열
  - **name**: 문자열(식당명; 예: 생활관식당, 학생식당, 교직원식당)
  - **hours**: 오브젝트
    - **breakfast/lunch/dinner**: 문자열("HH:MM-HH:MM")
  - **meals**: 오브젝트
    - **breakfast/lunch/dinner**: 배열(코스별 항목)
      - **course**: 문자열(예: "A", "B", "C" 등)
      - **mainMenu**: 문자열(주요 메뉴, 쉼표 구분 허용)
      - **price**: 숫자(정수; 통화기호 제거, VAT 포함 가정)

### 기능 요구사항
- **URL 입력만**으로 동작: 사전 규칙 최소화, 파서/프롬프트는 도메인 불가지론적으로 설계
- **HTML 파싱**: 각 식당 블록, 식사 시간표, 메뉴·코스·가격을 최대한 구조화 추출
- **정규화**: 공백/개행/특수문자 정리, 통화기호/단위 제거, 시간 표현 표준화
- **Gemini API 가공**: 프롬프트에
  - 학교명 추정 규칙(페이지 타이틀/메타/상단 로고 텍스트)
  - 식당 유형 매핑 규칙(키워드: 생활관/기숙사, 학생, 교직원)
  - 날짜 파싱 규칙(여러 형식 → YYYY-MM-DD)
  - 누락 필드 처리 정책(미제공 시간표는 필드 생략 대신 null 또는 빈 배열)
  - 가격 파싱 정책(숫자만; 쉼표/원/￦ 제거)
  - 다중 코스 병합 정책(코스 알파벳 자동 증분)
  - 출력 스키마 엄격 고정(JSON Schema)
- **응답 검증**: JSON Schema 검증 실패 시 재프롬프트/후처리
- **로깅**: 원본 HTML 스냅샷, 파싱 중간 산출물, 최종 JSON 보존 옵션

### 비기능 요구사항
- 언어/문자 인코딩: UTF-8 가정, EUC-KR 대응을 위해 재인코딩 시도
- 안정성: HTML 구조 변경에도 최소 동작(키워드 기반 파싱 + LLM 보정)
- 성능: 단일 URL 처리 5초 내(네트워크 제외) 목표
- 확장성: 파서 모듈/프롬프트 템플릿을 학교별로 플러그인화 가능

### 시스템 구성
- **crawler**: HTTP GET, 리다이렉트/압축/쿠키 대응
- **parser**: Cheerio(또는 BeautifulSoup 대안) 기반 DOM 추출 유틸
- **normalizer**: 문자열/숫자/시간 정규화 유틸
- **llm-client**: Gemini API 클라이언트, 프롬프트 템플릿/요청/재시도
- **validator**: JSON Schema 검증, 필드 보정
- **exporter**: 파일 저장(.json), 경로 규칙: `out/{school}/{date}.json`

### 프롬프트 템플릿(초안)
- 시스템 지시: "너는 대학 식단 데이터 변환기다. 아래 HTML 요약을 받아 표준 스키마로만 응답해라."
- 입력: 학교명 후보, 날짜 후보, 식당 섹션 텍스트, 표 가격·시간표 후보
- 출력 제약: 코드블록 금지, JSON만, 스키마 필수, 누락은 null/빈배열

### JSON Schema(요약)
- 타입: object
- required: [date, school, cafeterias]
- cafeterias.items.required: [name, hours, meals]
- price: number, minimum 0

### 에러 처리/재시도 정책
- HTTP 오류: 3회 지수백오프
- 인코딩 감지 실패: iconv 재시도
- LLM 응답 파싱 실패: 2회까지 재프롬프트(원인 로그 포함)
- 스키마 검증 실패: 자동 보정 규칙(예: 가격 문자열 → 숫자)

### CLI/라이브러리 사용 시나리오
- 라이브러리 호출: `transformFromUrl(url: string): Promise<StandardJson>`
- CLI: `bun run crawl "<url>" --out out/` 또는 `node src/cli.js <url>`

### 보안/비용
- API 키 관리: 환경변수 `GEMINI_API_KEY`
- PII: 없음, 단 공개 페이지만 처리
- 토큰비용: HTML 요약 후 LLM 호출(토큰 절약), 최대 8k 토큰 목표

### 완료 기준(DoD)
- 1) 샘플 2개 학교 URL 입력 시 `jsonExample.json`과 동일 스키마 출력
- 2) 스키마 검증 자동화 테스트 통과
- 3) README에 사용법/예제/스키마 명시

### 참고
- 예시 스키마 파일: `/Users/soseoyo/Documents/Programming/Project/Bobmoo/BobmooAutoCrawlling/jsonExample.json`
