# 🍚 BobmooUIKit

인하대학교 학식 메뉴를 보여주는 **UIKit 기반** iOS 앱

## 📱 스크린샷

메인 화면에서 오늘의 학식 메뉴를 시간대별(아침/점심/저녁)로 확인할 수 있습니다.

## ✨ 주요 기능

- 📅 **날짜 선택**: 원하는 날짜의 메뉴 확인
- 🕐 **시간대별 정렬**: 현재 시간에 맞는 식사를 우선 표시
- 🏫 **다중 식당 지원**: 학생식당, 교직원식당, 기숙사식당
- ⏰ **운영 상태 표시**: 운영전/운영중/운영종료/미운영
- 🔄 **자동 새로고침**: 앱 활성화 시 메뉴 자동 업데이트
- ⚙️ **설정 화면**: 위젯용 식당 선택

## 🛠 기술 스택

- **UI Framework**: UIKit
- **레이아웃**: Auto Layout, UIStackView
- **네트워킹**: URLSession + async/await
- **아키텍처**: MVC
- **최소 iOS 버전**: iOS 13.0+

## 🎨 디자인

- **커스텀 폰트**: Pretendard (9종)
- **컬러 스킴**: Pastel Blue 테마
- **다크 모드**: 지원 (UIColor dynamic colors)

## 📦 프로젝트 구조

```
BobmooUIKit/
├── AppDelegate.swift              # 앱 델리게이트
├── SceneDelegate.swift            # 씬 델리게이트 (window 설정)
├── AppGroup.swift                 # 위젯 공유 설정
├── Models.swift                   # 데이터 모델
├── NetworkService.swift           # API 통신
├── MainViewController.swift       # 메인 화면
├── SettingsViewController.swift  # 설정 화면
├── UIColor+Extensions.swift       # UIColor 확장
├── UIFont+Extensions.swift        # UIFont 확장
├── Assets.xcassets/               # 이미지 및 컬러 에셋
├── fonts/                         # Pretendard 폰트
└── Info.plist                     # 앱 설정
```

## 🚀 시작하기

### 1. 프로젝트 열기
```bash
open BobmooUIKit.xcodeproj
```

### 2. 시뮬레이터 선택
iPhone 15 또는 원하는 시뮬레이터 선택

### 3. 빌드 및 실행
**⌘R** 누르기

자세한 내용은 [QUICK_START.md](QUICK_START.md) 참고

## 📡 API

앱은 Bobmoo API를 사용합니다:
```
GET https://bobmoo.site/api/v1/menu?date=YYYY-MM-DD
```

### 응답 예시
```json
{
  "date": "2025-10-03",
  "school": "인하대학교",
  "cafeterias": [
    {
      "name": "학생식당",
      "hours": {
        "breakfast": "08:00-09:30",
        "lunch": "11:30-14:00",
        "dinner": "17:30-19:30"
      },
      "meals": {
        "breakfast": [...],
        "lunch": [...],
        "dinner": [...]
      }
    }
  ]
}
```

## 📚 문서

- **[QUICK_START.md](QUICK_START.md)**: 1분 빠른 시작 가이드
- **[BUILD_GUIDE.md](BUILD_GUIDE.md)**: 상세 빌드 가이드
- **[MIGRATION_SUMMARY.md](MIGRATION_SUMMARY.md)**: SwiftUI → UIKit 마이그레이션 내역

## 🔧 개발 환경

- **Xcode**: 15.0+
- **Swift**: 5.9+
- **iOS**: 13.0+

## 📱 지원 기기

- iPhone (iOS 13.0+)
- iPad (iOS 13.0+)
- iPod touch (iOS 13.0+)

## 🎯 로드맵

- [ ] 다크 모드 UI 개선
- [ ] 즐겨찾기 기능
- [ ] 메뉴 검색 기능
- [ ] 알림 기능 (식사 시간 알림)
- [ ] 위젯 완전 통합
- [ ] 오프라인 캐싱

## 🐛 알려진 이슈

현재 알려진 이슈가 없습니다.

## 🤝 기여

버그 리포트나 기능 제안은 Issues를 통해 남겨주세요.

## 📄 라이선스

이 프로젝트는 개인 프로젝트입니다.

## 👨‍💻 개발자

**SeongYongSong**
- SwiftUI 버전에서 UIKit으로 마이그레이션 (2025.10.03)

## 🙏 감사의 말

- **Pretendard 폰트**: 오픈소스 한글 폰트
- **Bobmoo API**: 학식 메뉴 데이터 제공

---

## 🔗 관련 프로젝트

- **BobmooiOS** (SwiftUI 버전): `../BobmooiOS/`

---

**Made with ❤️ and UIKit**
