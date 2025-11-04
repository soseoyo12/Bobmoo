# 🚀 빠른 시작 가이드

## 1분 안에 앱 실행하기

### 1. Xcode에서 열기
```bash
open BobmooUIKit/BobmooUIKit.xcodeproj
```

### 2. 시뮬레이터 선택
상단 바에서 **iPhone 15** (또는 다른 시뮬레이터) 선택

### 3. 실행
**⌘R** 누르기 또는 재생 버튼 클릭

### 4. 완료! 🎉
앱이 시뮬레이터에서 실행됩니다.

---

## 빌드 오류가 발생하면?

### 오류: "No such file or directory"
```bash
# 프로젝트 클린
⇧⌘K (Shift + Command + K)
```

### 오류: 폰트 또는 색상 관련
모든 파일이 올바른 위치에 있는지 확인:
```bash
ls BobmooUIKit/BobmooUIKit/*.swift
ls BobmooUIKit/BobmooUIKit/fonts/*.ttf
```

### 그래도 안 되면?
`BUILD_GUIDE.md` 파일의 상세 가이드를 참고하세요.

---

## 주요 파일 설명

| 파일 | 역할 |
|------|------|
| `MainViewController.swift` | 메인 화면 (식당 메뉴 표시) |
| `SettingsViewController.swift` | 설정 화면 |
| `Models.swift` | 데이터 모델 |
| `NetworkService.swift` | API 통신 |
| `SceneDelegate.swift` | 앱 시작 설정 |

---

## API 엔드포인트

앱은 다음 API를 사용합니다:
```
https://bobmoo.site/api/v1/menu?date=YYYY-MM-DD
```

인터넷 연결이 필요합니다!

---

**더 자세한 정보는 `BUILD_GUIDE.md`와 `MIGRATION_SUMMARY.md`를 참고하세요.**
