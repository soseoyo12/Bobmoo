# BobmooUIKit 빌드 가이드

## 📦 프로젝트 준비 완료 상태

모든 필요한 파일이 생성되고 올바른 위치에 있습니다:

✅ **Swift 소스 파일**
- AppDelegate.swift
- SceneDelegate.swift
- AppGroup.swift
- Models.swift
- NetworkService.swift
- MainViewController.swift
- SettingsViewController.swift

✅ **리소스 파일**
- fonts/ (Pretendard 폰트 9종)
- Assets.xcassets (색상 및 이미지)
- Info.plist (폰트 등록 완료)
- LaunchScreen.storyboard

✅ **제거된 파일**
- ViewController.swift (삭제됨)
- Main.storyboard (삭제됨)

## 🚀 빌드 및 실행 방법

### 1. Xcode에서 프로젝트 열기
```bash
open BobmooUIKit/BobmooUIKit.xcodeproj
```

### 2. 파일 자동 인식 확인
이 프로젝트는 Xcode의 **File System Synchronized Groups** 기능을 사용하므로:
- 모든 파일이 자동으로 프로젝트에 포함됩니다
- 수동으로 파일을 추가할 필요가 없습니다
- BobmooUIKit 폴더의 모든 Swift 파일이 자동으로 빌드됩니다

### 3. 빌드 설정 확인

#### a) Deployment Target
- **iOS 15.0 이상** 권장
- Project Settings → General → Deployment Info 확인

#### b) Bundle Identifier
- 필요시 변경: `com.yourcompany.BobmooUIKit`

#### c) App Group (선택사항)
위젯을 사용할 경우:
1. Signing & Capabilities → + Capability → App Groups
2. AppGroup.swift의 identifier를 실제 그룹 ID로 변경

### 4. 빌드 및 실행
1. 시뮬레이터 선택 (iPhone 15 권장)
2. **⌘R** 또는 Product → Run

## 🔍 빌드 전 체크리스트

### Swift 파일 확인
```bash
# 프로젝트 디렉토리에서 실행
ls -la BobmooUIKit/BobmooUIKit/*.swift
```

예상 결과:
```
AppDelegate.swift
AppGroup.swift
MainViewController.swift
Models.swift
NetworkService.swift
SceneDelegate.swift
SettingsViewController.swift
```

### 폰트 파일 확인
```bash
ls BobmooUIKit/BobmooUIKit/fonts/
```

예상 결과: 9개의 .ttf 파일

### Info.plist 확인
```bash
plutil -p BobmooUIKit/BobmooUIKit/Info.plist | grep -A 10 UIAppFonts
```

예상 결과: 9개의 폰트 파일 등록됨

## 🎨 실행 후 확인사항

앱이 정상적으로 실행되면:

1. **메인 화면**
   - 상단: pastelBlue 배경의 네비게이션 바
   - 타이틀: "인하대학교"
   - 우측 상단: 설정 버튼 (⚙️)
   - 날짜 선택 버튼
   - 스크롤 가능한 식사 블록들 (아침/점심/저녁)

2. **기능 테스트**
   - [ ] 날짜 선택 버튼 클릭 → DatePicker 표시
   - [ ] 날짜 변경 → 메뉴 데이터 로딩
   - [ ] 설정 버튼 → 설정 화면으로 이동
   - [ ] 스크롤 테스트
   - [ ] 운영 상태 표시 확인

3. **설정 화면**
   - [ ] 위젯 식당 선택 기능
   - [ ] 선택된 항목 체크마크 표시
   - [ ] 위젯 정보 표시

## ⚠️ 문제 해결

### 빌드 오류 발생 시

#### 1. "No such module" 에러
```bash
# 프로젝트 클린
Product → Clean Build Folder (⇧⌘K)
```

#### 2. 폰트 관련 오류
- Info.plist에서 UIAppFonts 배열 확인
- fonts/ 폴더에 실제 ttf 파일이 있는지 확인

#### 3. "pastelBlue" 색상을 찾을 수 없음
- Assets.xcassets에 pastelBlue.colorset이 있는지 확인
- 없으면 BobmooiOS에서 다시 복사:
```bash
cp -r BobmooiOS/BabmooiOS/Assets.xcassets/pastelBlue.colorset BobmooUIKit/BobmooUIKit/Assets.xcassets/
```

#### 4. Storyboard 관련 오류
- Info.plist에 UISceneStoryboardFile 키가 없는지 확인
- Main.storyboard가 삭제되었는지 확인

#### 5. 앱이 크래시됨
- Xcode Console에서 에러 메시지 확인
- SceneDelegate.swift에서 window 설정 확인

### 네트워크 관련

#### API 호출 실패
- 인터넷 연결 확인
- API 엔드포인트: `https://bobmoo.site/api/v1/menu`
- Console 로그 확인 (🌐, 📡, 📦, 📄 아이콘)

#### 메뉴 데이터가 안 보임
- 선택한 날짜에 데이터가 있는지 확인
- 오늘 날짜로 테스트

## 🔧 고급 설정

### 커스텀 폰트 사용
```swift
// 코드에서 Pretendard 폰트 사용
let font = UIFont(name: "Pretendard-Regular", size: 16)
let boldFont = UIFont(name: "Pretendard-Bold", size: 20)
```

### 디버그 로깅
NetworkService.swift에 이미 상세한 로깅이 포함되어 있습니다:
- 🌐 API URL
- 📅 요청 날짜
- 📡 HTTP Status
- 📦 데이터 크기
- 📄 응답 내용
- ✅ 디코딩 결과

## 📱 배포 준비

### 1. App Icon 설정
Assets.xcassets/AppIcon.appiconset에 앱 아이콘 추가

### 2. Launch Screen 커스터마이징
Base.lproj/LaunchScreen.storyboard 편집

### 3. Bundle Identifier 변경
실제 앱 ID로 변경 (예: com.yourcompany.bobmoo)

### 4. Code Signing
- Development Team 선택
- Provisioning Profile 설정

### 5. App Group (위젯 사용 시)
- App Groups Capability 추가
- AppGroup.swift의 identifier 업데이트

## 📊 프로젝트 통계

- **Swift 파일**: 7개
- **코드 라인**: ~500 줄 (주석 제외)
- **UI 컴포넌트**: UIKit 네이티브
- **레이아웃**: Auto Layout + UIStackView
- **네트워킹**: URLSession + async/await
- **최소 iOS 버전**: iOS 13.0+

## 🎯 다음 단계

1. ✅ Xcode에서 프로젝트 열기
2. ✅ 빌드 설정 확인
3. ✅ 시뮬레이터에서 실행
4. ✅ 기능 테스트
5. ⏭️ 추가 기능 개발 또는 UI 개선

---

**준비 완료!** 이제 Xcode에서 프로젝트를 열고 실행하면 됩니다! 🚀
