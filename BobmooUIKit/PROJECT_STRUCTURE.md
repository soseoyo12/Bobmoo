# 📁 프로젝트 구조

## 디렉토리 트리

```
BobmooUIKit/
├── BobmooUIKit.xcodeproj/              # Xcode 프로젝트 파일
│   └── project.pbxproj
├── BobmooUIKit/                        # 메인 소스 디렉토리
│   ├── 📱 App Lifecycle
│   │   ├── AppDelegate.swift           # 앱 델리게이트
│   │   └── SceneDelegate.swift         # 씬 델리게이트 (UI 초기화)
│   │
│   ├── 🎯 View Controllers
│   │   ├── MainViewController.swift    # 메인 화면 (학식 메뉴)
│   │   └── SettingsViewController.swift # 설정 화면
│   │
│   ├── 📊 Models & Data
│   │   ├── Models.swift                # 데이터 모델 및 헬퍼 함수
│   │   ├── NetworkService.swift        # API 통신 서비스
│   │   └── AppGroup.swift              # 위젯 공유 설정
│   │
│   ├── 🎨 Extensions
│   │   ├── UIColor+Extensions.swift    # UIColor 확장
│   │   └── UIFont+Extensions.swift     # UIFont 확장 (Pretendard)
│   │
│   ├── 🖼️ Resources
│   │   ├── Assets.xcassets/            # 이미지 및 컬러 에셋
│   │   │   ├── AppIcon.appiconset/
│   │   │   ├── AccentColor.colorset/
│   │   │   ├── pastelBlue.colorset/
│   │   │   ├── pastelBlue_real.colorset/
│   │   │   └── BobmooLogo.imageset/
│   │   ├── fonts/                      # Pretendard 폰트
│   │   │   ├── Pretendard-Thin.ttf
│   │   │   ├── Pretendard-ExtraLight.ttf
│   │   │   ├── Pretendard-Light.ttf
│   │   │   ├── Pretendard-Regular.ttf
│   │   │   ├── Pretendard-Medium.ttf
│   │   │   ├── Pretendard-SemiBold.ttf
│   │   │   ├── Pretendard-Bold.ttf
│   │   │   ├── Pretendard-ExtraBold.ttf
│   │   │   └── Pretendard-Black.ttf
│   │   └── Base.lproj/
│   │       └── LaunchScreen.storyboard
│   │
│   └── Info.plist                      # 앱 설정 파일
│
├── 📖 Documentation
│   ├── README.md                       # 프로젝트 개요
│   ├── QUICK_START.md                  # 빠른 시작 가이드
│   ├── BUILD_GUIDE.md                  # 상세 빌드 가이드
│   ├── MIGRATION_SUMMARY.md            # SwiftUI → UIKit 마이그레이션
│   └── PROJECT_STRUCTURE.md            # 이 파일
│
├── 🔧 Scripts
│   └── verify_project.sh               # 프로젝트 검증 스크립트
│
└── .gitignore                          # Git 무시 파일
```

## 파일 설명

### App Lifecycle (앱 생명주기)

#### `AppDelegate.swift`
- 앱의 진입점
- 앱 시작 시 초기화 작업

#### `SceneDelegate.swift`
- UI 윈도우 생성 및 설정
- MainViewController를 NavigationController로 감싸서 root로 설정
- 프로그래매틱 UI 사용 (Storyboard 없음)

### View Controllers (뷰 컨트롤러)

#### `MainViewController.swift` (약 500줄)
**역할**: 메인 화면 - 학식 메뉴 표시

**주요 기능**:
- 날짜 선택 (DatePicker)
- 시간대별 식사 블록 표시 (아침/점심/저녁)
- 식당별 메뉴 표시
- 운영 상태 표시 (운영전/운영중/운영종료/미운영)
- 로딩 및 에러 상태 처리
- 자동 새로고침

**UI 구성**:
- NavigationBar (pastelBlue 배경)
- 날짜 선택 버튼 (상단 헤더)
- ScrollView + StackView
- 동적 메뉴 블록 생성

#### `SettingsViewController.swift` (약 180줄)
**역할**: 설정 화면

**주요 기능**:
- 위젯용 식당 선택
- UserDefaults에 설정 저장
- TableView 기반 UI

### Models & Data (모델 및 데이터)

#### `Models.swift` (약 220줄)
**데이터 모델**:
- `CampusMenu`: 전체 메뉴 데이터
- `Cafeteria`: 식당 정보
- `Hours`: 운영 시간
- `Meals`: 식사 목록
- `MenuItem`: 메뉴 아이템
- `MealArray`: 뷰용 메뉴 배열
- `CafeteriaMeals`: 식당별 메뉴 그룹

**헬퍼 함수**:
- `getMealOrder()`: 현재 시간에 따른 식사 순서 결정
- `makeMealArray()`: API 데이터 → 뷰 모델 변환
- `operatingState()`: 운영 상태 계산

**운영 상태 로직**:
```
07시: 모든 식당 "운영전"
현재 시간 < 시작 시간: "운영전" (회색)
시작 시간 ≤ 현재 시간 ≤ 종료 시간: "운영중" (파랑)
종료 시간 < 현재 시간: "운영종료" (빨강)
미운영: "미운영" (회색)
```

#### `NetworkService.swift` (약 50줄)
**역할**: API 통신

**메서드**:
- `fetch(date:)`: 특정 날짜 메뉴 가져오기
- `fetchToday()`: 오늘 메뉴 가져오기

**특징**:
- async/await 패턴
- 상세한 디버그 로깅 (🌐, 📡, 📦, 📄, ✅)
- 에러 처리

**API 엔드포인트**:
```
GET https://bobmoo.site/api/v1/menu?date=YYYY-MM-DD
```

#### `AppGroup.swift` (약 15줄)
**역할**: 위젯과 앱 간 데이터 공유

**설정**:
```swift
static let identifier = "group.com.example.babmooiOS"
```

### Extensions (확장)

#### `UIColor+Extensions.swift`
**제공 기능**:
- `UIColor.pastelBlue`: 커스텀 컬러 쉽게 접근
- `alpha(_:)`: 투명도 적용 헬퍼
- `dynamic(light:dark:)`: 다크 모드 대응

**사용 예**:
```swift
view.backgroundColor = .pastelBlue
statusLabel.backgroundColor = .blue.alpha(0.8)
```

#### `UIFont+Extensions.swift`
**제공 기능**:
- `pretendard(size:weight:)`: Pretendard 폰트 사용
- Weight별 편의 메서드 (thin, light, regular, medium, semibold, bold, etc.)
- 폰트 로딩 검증 함수

**사용 예**:
```swift
label.font = .pretendardBold(size: 20)
label.font = .pretendard(size: 16, weight: .medium)
```

## 코드 통계

| 항목 | 수치 |
|------|------|
| Swift 파일 | 9개 |
| 총 코드 라인 | ~1,200줄 |
| View Controllers | 2개 |
| 데이터 모델 | 8개 구조체 |
| Extensions | 2개 |
| 폰트 파일 | 9개 |
| 문서 파일 | 5개 |

## 데이터 흐름

```
API (Bobmoo)
    ↓
NetworkService.fetch(date:)
    ↓
CampusMenu (Decodable)
    ↓
makeMealArray()
    ↓
[CafeteriaMeals]
    ↓
MainViewController.updateUI()
    ↓
UIScrollView + UIStackView
    ↓
사용자에게 표시
```

## UI 구조

```
UIWindow
└── UINavigationController
    └── MainViewController
        ├── dateHeaderView (날짜 선택 버튼)
        └── scrollView
            └── contentStackView
                ├── MealBlock (아침)
                │   ├── Header (아이콘 + 제목)
                │   └── Cafeteria Views
                │       ├── 학생식당
                │       ├── 교직원식당
                │       └── 기숙사식당
                ├── MealBlock (점심)
                └── MealBlock (저녁)
```

## 설정 화면 구조

```
SettingsViewController (UITableViewController)
├── Section 0: 위젯 설정
│   ├── 학생식당 (체크마크)
│   ├── 교직원식당
│   └── 기숙사식당
└── Section 1: 정보
    ├── 위젯 업데이트: 6시간마다
    ├── 지원 위젯 크기: 1x1, 1x2
    ├── 1x1 위젯: 선택된 식당 1개
    └── 1x2 위젯: 모든 식당 표시
```

## 빌드 설정

- **최소 iOS 버전**: iOS 13.0+
- **Swift 버전**: 5.9+
- **Xcode**: 15.0+
- **프레임워크**: UIKit
- **의존성**: 없음 (순수 UIKit + URLSession)

## 리소스 관리

### 색상
- `pastelBlue`: 메인 테마 컬러 (네비게이션 바, 헤더)
- `pastelBlue_real`: 대체 컬러
- Dynamic Colors 지원 (다크 모드 대응)

### 폰트
- Pretendard 9 weights
- Info.plist에 등록됨
- UIFont extension으로 쉽게 사용

### 이미지
- 앱 아이콘: AppIcon.appiconset
- 로고: BobmooLogo.imageset (SVG)
- SF Symbols 사용 (시스템 아이콘)

## Git 관리

### 무시되는 파일 (.gitignore)
- `xcuserdata/`: 사용자별 Xcode 설정
- `build/`, `DerivedData/`: 빌드 산출물
- `.DS_Store`: macOS 시스템 파일

### 버전 관리 대상
- 모든 Swift 소스 파일
- 리소스 파일 (폰트, Assets)
- 문서 파일
- Info.plist
- project.pbxproj

## 주요 아키텍처 패턴

- **MVC**: Model-View-Controller
- **Delegate Pattern**: UITableViewDelegate, UIScrollViewDelegate
- **Async/Await**: 네트워크 통신
- **Factory Pattern**: 동적 UI 생성 (createMealBlockView, etc.)
- **Extension Pattern**: 기능 확장 (UIColor, UIFont)

---

**이 구조는 확장 가능하고 유지보수가 쉬운 UIKit 앱 아키텍처입니다.**
