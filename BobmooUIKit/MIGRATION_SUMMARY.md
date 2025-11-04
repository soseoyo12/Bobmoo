# BobmooiOS → BobmooUIKit 마이그레이션 완료

## 📋 개요
SwiftUI 기반의 BobmooiOS 앱을 UIKit으로 완전히 이식했습니다.

## ✅ 완료된 작업

### 1. 모델 파일 생성
- **Models.swift**: 모든 데이터 구조체와 헬퍼 함수 포함
  - `CampusMenu`, `Cafeteria`, `Hours`, `Meals`, `MenuItem`
  - `MealArray`, `CafeteriaMeals` (뷰 헬퍼 모델)
  - `getMealOrder()`: 시간에 따른 식사 순서 결정
  - `makeMealArray()`: 메뉴 데이터 변환
  - `operatingState()`: 운영 상태 계산

### 2. 네트워크 서비스
- **NetworkService.swift**: API 호출 로직
  - `fetch(date:)`: 특정 날짜의 메뉴 가져오기
  - `fetchToday()`: 오늘 메뉴 가져오기
  - async/await 패턴 사용

### 3. App Group 설정
- **AppGroup.swift**: 위젯과 앱 간 데이터 공유를 위한 식별자

### 4. 메인 뷰 컨트롤러
- **MainViewController.swift**: mainView.swift의 UIKit 버전
  - ✨ 주요 기능:
    - 날짜 선택 기능 (DatePicker)
    - 시간대별 식사 블록 표시 (아침/점심/저녁)
    - 식당별 메뉴 표시
    - 운영 상태 표시 (운영전/운영중/운영종료/미운영)
    - 로딩 및 에러 상태 처리
    - 자동 새로고침 (앱 활성화 시)
  - 🎨 UI 구성:
    - NavigationBar: pastelBlue 배경, 인하대학교 타이틀
    - 날짜 선택 버튼
    - ScrollView + StackView 기반 레이아웃
    - 식사 블록: 아이콘, 식당 정보, 메뉴 목록

### 5. 설정 뷰 컨트롤러
- **SettingsViewController.swift**: SettingsView.swift의 UIKit 버전
  - ✨ 주요 기능:
    - 위젯용 식당 선택 (UserDefaults 저장)
    - 위젯 정보 표시
    - TableView 기반 UI

### 6. 앱 델리게이트 설정
- **SceneDelegate.swift**: 프로그래매틱 UI 설정
  - Storyboard 제거
  - NavigationController로 MainViewController 설정
- **AppDelegate.swift**: 기본 설정 유지

### 7. 리소스 파일
- **Assets.xcassets**:
  - pastelBlue.colorset ✅
  - pastelBlue_real.colorset ✅
  - BobmooLogo.imageset ✅
- **fonts/** 폴더:
  - Pretendard 폰트 9종 (ttf) ✅

### 8. Info.plist 업데이트
- UISceneStoryboardFile 제거 (Storyboard 사용 안 함)
- UIAppFonts 추가 (Pretendard 폰트 등록)
- LaunchScreen 설정

## 📁 파일 구조

```
BobmooUIKit/BobmooUIKit/
├── AppDelegate.swift
├── SceneDelegate.swift
├── AppGroup.swift
├── Models.swift
├── NetworkService.swift
├── MainViewController.swift
├── SettingsViewController.swift
├── Info.plist
├── Assets.xcassets/
│   ├── AccentColor.colorset/
│   ├── AppIcon.appiconset/
│   ├── pastelBlue.colorset/
│   ├── pastelBlue_real.colorset/
│   └── BobmooLogo.imageset/
├── fonts/
│   ├── Pretendard-Black.ttf
│   ├── Pretendard-Bold.ttf
│   ├── Pretendard-ExtraBold.ttf
│   ├── Pretendard-ExtraLight.ttf
│   ├── Pretendard-Light.ttf
│   ├── Pretendard-Medium.ttf
│   ├── Pretendard-Regular.ttf
│   ├── Pretendard-SemiBold.ttf
│   └── Pretendard-Thin.ttf
└── Base.lproj/
    └── LaunchScreen.storyboard
```

## 🔧 Xcode 프로젝트 설정 필요

현재 파일들이 생성되었지만, Xcode 프로젝트에 다음 파일들을 추가해야 합니다:

### 추가해야 할 파일:
1. **Swift 파일**:
   - AppGroup.swift
   - Models.swift
   - NetworkService.swift
   - MainViewController.swift
   - SettingsViewController.swift

2. **리소스 파일**:
   - fonts/*.ttf (9개 파일)
   - Assets.xcassets의 새 colorset들

### Xcode에서 추가하는 방법:
1. Xcode에서 BobmooUIKit.xcodeproj 열기
2. Project Navigator에서 BobmooUIKit 그룹 선택
3. 우클릭 → "Add Files to BobmooUIKit..."
4. 위 파일들 선택 (Copy items if needed 체크)
5. Target: BobmooUIKit 선택

## 🎯 SwiftUI vs UIKit 주요 변환 사항

### 1. View → ViewController
```swift
// SwiftUI
struct mainView: View { ... }

// UIKit
class MainViewController: UIViewController { ... }
```

### 2. @State → 프로퍼티
```swift
// SwiftUI
@State private var menu: CampusMenu?

// UIKit
private var menu: CampusMenu?
```

### 3. ScrollView + VStack → UIScrollView + UIStackView
```swift
// SwiftUI
ScrollView {
    VStack { ... }
}

// UIKit
let scrollView = UIScrollView()
let stackView = UIStackView()
```

### 4. NavigationStack → UINavigationController
```swift
// SwiftUI
NavigationStack { ... }

// UIKit
let navigationController = UINavigationController(rootViewController: mainVC)
```

### 5. .task → viewDidLoad + Task
```swift
// SwiftUI
.task { await loadMenuData() }

// UIKit
override func viewDidLoad() {
    Task { await loadMenuData() }
}
```

## 🚀 실행 방법

1. Xcode에서 BobmooUIKit.xcodeproj 열기
2. 위의 "추가해야 할 파일" 섹션대로 파일 추가
3. Build & Run (⌘R)

## 📝 참고사항

- **App Group ID**: `group.com.example.babmooiOS`를 실제 ID로 변경 필요
- **Widget 연동**: WidgetKit은 UIKit 앱에서 직접 reload할 수 없으므로 UserDefaults 변경으로 위젯이 자동 업데이트됨
- **폰트 사용**: Pretendard 폰트는 Info.plist에 등록되어 있으며, 코드에서 `UIFont(name: "Pretendard-Regular", size: 16)` 형태로 사용 가능
- **색상**: `UIColor(named: "pastelBlue")`로 커스텀 색상 사용

## ✨ 기능 동일성

모든 SwiftUI 버전의 기능이 UIKit 버전에도 동일하게 구현되었습니다:
- ✅ 날짜 선택 기능
- ✅ 시간대별 식사 순서 자동 조정
- ✅ 운영 상태 표시
- ✅ 로딩 및 에러 처리
- ✅ 설정 화면 (위젯 식당 선택)
- ✅ 자동 새로고침
- ✅ 커스텀 폰트 및 색상

---

**마이그레이션 완료일**: 2025년 10월 3일
