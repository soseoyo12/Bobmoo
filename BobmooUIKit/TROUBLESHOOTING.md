# 🔧 문제 해결 가이드

## 발생한 문제와 해결 방법

### ❌ 문제 1: Invalid redeclaration of 'pastelBlue'

**오류 메시지**:
```
UIColor+Extensions.swift:14:16 Invalid redeclaration of 'pastelBlue'
```

**원인**:
- Swift에서 `static var` computed property로 선언할 때 이름 충돌 가능
- Xcode 프로젝트 설정에서 파일이 중복 참조될 수 있음
- extension에서 같은 이름의 property 중복 선언

**해결 방법**:
1. `static var pastelBlue` → `static func customPastelBlue()` 메서드로 변경
2. Optional 처리 제거하고 기본값 제공
3. 사용하는 곳에서 `.pastelBlue` → `.customPastelBlue()` 로 변경

**변경 전**:
```swift
extension UIColor {
    static var pastelBlue: UIColor? {
        return UIColor(named: "pastelBlue")
    }
}

// 사용
view.backgroundColor = .pastelBlue ?? UIColor.systemBlue
```

**변경 후**:
```swift
extension UIColor {
    static func customPastelBlue() -> UIColor {
        return UIColor(named: "pastelBlue") ?? .systemBlue
    }
}

// 사용
view.backgroundColor = .customPastelBlue()
```

---

## 일반적인 빌드 오류 해결

### 1. "No such module" 에러

**해결 방법**:
```bash
# Xcode에서
⇧⌘K  (Clean Build Folder)
⌘B   (Build)
```

### 2. 폰트 관련 오류

**증상**:
- 폰트가 로드되지 않음
- 시스템 폰트로 대체됨

**확인사항**:
1. Info.plist에 UIAppFonts 배열 존재
2. fonts/ 폴더에 .ttf 파일 존재
3. Xcode 프로젝트에 폰트 파일 추가
4. Target Membership 체크

**테스트 코드**:
```swift
// AppDelegate.swift의 didFinishLaunching에 추가
UIFont.verifyPretendardFonts()  // 콘솔에서 확인
```

### 3. 색상을 찾을 수 없음

**증상**:
```
UIColor(named: "pastelBlue") returns nil
```

**확인사항**:
1. Assets.xcassets에 pastelBlue.colorset 존재
2. Contents.json 파일 유효성
3. Xcode에서 색상 asset이 인식되는지 확인

**임시 해결책**:
```swift
// 직접 색상 정의
extension UIColor {
    static func customPastelBlue() -> UIColor {
        return UIColor(red: 0.678, green: 0.847, blue: 0.902, alpha: 1.0)
    }
}
```

### 4. Storyboard 관련 오류

**증상**:
```
Could not find a storyboard named 'Main'
```

**해결 방법**:
1. Info.plist에서 `UISceneStoryboardFile` 키 제거
2. SceneDelegate에서 프로그래매틱 UI 설정 확인
3. Main.storyboard 파일 삭제

### 5. 파일이 Target에 포함되지 않음

**증상**:
- Swift 파일이 있지만 컴파일되지 않음
- "Undefined symbol" 에러

**해결 방법**:
1. Xcode에서 파일 선택
2. File Inspector (⌥⌘1)
3. Target Membership에서 BobmooUIKit 체크

### 6. App Group 관련 경고

**증상**:
```
Could not read values in CFPrefsPlistSource
```

**해결 방법**:
1. Signing & Capabilities → + Capability → App Groups
2. AppGroup.swift의 identifier를 실제 그룹 ID로 변경
3. 또는 위젯을 사용하지 않는다면 AppGroup 코드 제거

---

## 디버깅 팁

### 1. 네트워크 디버깅

NetworkService.swift에 이미 로깅이 포함되어 있습니다:

```swift
// 콘솔에서 확인할 수 있는 로그
🌐 API URL: https://bobmoo.site/api/v1/menu?date=2025-10-03
📅 요청 날짜: 2025-10-03
📡 HTTP Status: 200
📦 받은 데이터 크기: 1234 bytes
📄 API 응답 내용: {...}
✅ 디코딩 성공: 3개 식당
```

### 2. UI 디버깅

**View 계층 확인**:
```
Debug → View Debugging → Capture View Hierarchy
```

**Auto Layout 이슈**:
```
Debug → View Debugging → Show Alignment Rectangles
```

### 3. 메모리 디버깅

**메모리 누수 확인**:
```
Product → Profile (⌘I) → Leaks
```

---

## Xcode 프로젝트 재설정

모든 것이 작동하지 않을 때:

### 1. DerivedData 삭제
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### 2. 프로젝트 클린
```
⇧⌘K (Clean Build Folder)
```

### 3. Xcode 재시작
```
⌘Q (Quit)
다시 Xcode 실행
```

### 4. 시뮬레이터 재설정
```
Device → Erase All Content and Settings...
```

---

## 파일 구조 검증

verify_project.sh 스크립트 실행:

```bash
cd BobmooUIKit
./verify_project.sh
```

예상 출력:
```
✅ 모든 검증 통과!
프로젝트가 빌드 준비 완료되었습니다.
```

---

## 자주 묻는 질문

### Q1: 앱이 실행되지만 메뉴가 안 보여요

**답변**:
1. 인터넷 연결 확인
2. API 서버 상태 확인: https://bobmoo.site/api/v1/menu?date=2025-10-03
3. 콘솔 로그에서 네트워크 오류 확인

### Q2: 폰트가 제대로 표시되지 않아요

**답변**:
1. `UIFont.printAvailableFonts()` 실행해서 Pretendard 폰트 확인
2. Info.plist에서 UIAppFonts 배열 확인
3. 폰트 파일이 Target에 포함되었는지 확인

### Q3: 날짜 선택이 작동하지 않아요

**답변**:
UIAlertController의 DatePicker가 일부 시뮬레이터에서 문제가 있을 수 있습니다.
실제 기기에서 테스트하거나, 다른 시뮬레이터로 변경해보세요.

### Q4: 설정 화면에서 선택이 저장되지 않아요

**답변**:
1. UserDefaults(suiteName: AppGroup.identifier) 확인
2. AppGroup.identifier가 올바른지 확인
3. 시뮬레이터를 재설정해보세요

---

## 추가 도움말

더 많은 정보는 다음 문서를 참고하세요:

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - 상세 빌드 가이드
- [MIGRATION_SUMMARY.md](MIGRATION_SUMMARY.md) - SwiftUI → UIKit 마이그레이션
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - 프로젝트 구조

---

**문제가 계속되면 프로젝트를 클린하고 다시 빌드해보세요!**

```bash
# 완전 클린
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd BobmooUIKit
# Xcode에서 ⇧⌘K 후 ⌘B
```
