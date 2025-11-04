# 📱 Storyboard 추가 가이드

## 현재 상황

이 프로젝트는 **프로그래매틱 UI**를 사용합니다:
- ✅ 모든 UI가 Swift 코드로 작성됨
- ✅ Storyboard 없음 (LaunchScreen 제외)
- ✅ SceneDelegate에서 UI 초기화

## 🎨 Storyboard를 사용하고 싶다면?

### 방법 1: Main.storyboard 추가 (기존 코드 유지)

#### 1단계: Main.storyboard 생성
```
Xcode → File → New → File → Storyboard
이름: Main.storyboard
위치: BobmooUIKit/BobmooUIKit/
```

#### 2단계: Initial View Controller 설정
1. Main.storyboard 열기
2. Library (⇧⌘L)에서 View Controller 드래그
3. View Controller 선택 → Attributes Inspector
4. "Is Initial View Controller" 체크

#### 3단계: Custom Class 설정
1. View Controller 선택
2. Identity Inspector (⌥⌘3)
3. Class: `MainViewController`
4. Module: `BobmooUIKit`

#### 4단계: Storyboard ID 설정
1. Identity Inspector에서
2. Storyboard ID: `MainViewController`

#### 5단계: SceneDelegate 수정
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: windowScene)
    
    // Storyboard에서 로드
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
        let navigationController = UINavigationController(rootViewController: mainVC)
        window.rootViewController = navigationController
    }
    
    window.makeKeyAndVisible()
    self.window = window
}
```

#### 6단계: project.pbxproj 수정
다시 Main.storyboard 참조 추가:
```
INFOPLIST_KEY_UIMainStoryboardFile = Main;
```

---

### 방법 2: 하이브리드 방식 (권장)

프로그래매틱 UI는 유지하면서, 일부 화면만 Storyboard 사용:

#### 예: SettingsViewController를 Storyboard로

```swift
// MainViewController.swift
@objc private func settingsButtonTapped() {
    let storyboard = UIStoryboard(name: "Settings", bundle: nil)
    let settingsVC = storyboard.instantiateInitialViewController() as! SettingsViewController
    navigationController?.pushViewController(settingsVC, animated: true)
}
```

---

### 방법 3: 완전히 Storyboard 기반으로 변환

프로젝트를 처음부터 다시 만드는 것과 같습니다.

#### 필요한 작업:
1. Main.storyboard 생성
2. 모든 View Controller를 Storyboard에 추가
3. Auto Layout constraints를 Interface Builder에서 설정
4. IBOutlet과 IBAction 연결
5. Segue 설정

#### 예시 (MainViewController):

**MainViewController.swift 수정**:
```swift
import UIKit

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var menu: CampusMenu?
    private var selectedDate: Date = Date()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMenuData(for: selectedDate)
    }
    
    // MARK: - IBActions
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        // 날짜 선택 로직
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        // 설정 화면으로 이동
    }
    
    // ... 나머지 코드
}
```

**Main.storyboard에서 연결**:
1. UIScrollView 드래그 → scrollView IBOutlet 연결
2. UIStackView 드래그 → contentStackView IBOutlet 연결
3. UIButton 드래그 → dateButton IBOutlet 연결
4. UIButton의 Touch Up Inside → dateButtonTapped: IBAction 연결

---

## ❓ 프로그래매틱 vs Storyboard?

### 프로그래매틱 UI (현재 방식)

**장점**:
- ✅ Git merge 충돌 없음
- ✅ 코드 리뷰 쉬움
- ✅ 동적 UI 생성 용이
- ✅ 재사용 가능한 컴포넌트
- ✅ 팀 협업에 유리

**단점**:
- ❌ 코드가 길어짐
- ❌ UI 미리보기 어려움
- ❌ 학습 곡선

**현재 구현 예시**:
```swift
private lazy var dateHeaderView: UIView = {
    let view = UIView()
    view.backgroundColor = .customPastelBlue()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let button = UIButton(type: .system)
    button.setTitle(dateLabel, for: .normal)
    // ... constraints 설정
    
    return view
}()
```

### Storyboard (시각적 방식)

**장점**:
- ✅ 시각적으로 UI 디자인
- ✅ 드래그 앤 드롭으로 빠른 프로토타이핑
- ✅ Interface Builder에서 실시간 미리보기
- ✅ 초보자에게 친숙

**단점**:
- ❌ XML 파일이라 merge 어려움
- ❌ 복잡한 UI는 느려짐
- ❌ 동적 UI 제한적
- ❌ 코드 리뷰 어려움

---

## 🎯 추천 방식

### 이 프로젝트에는:
**프로그래매틱 UI 유지 (현재 방식)** 👍

**이유**:
1. 이미 모든 UI가 구현됨
2. 동적 메뉴 블록 생성 (시간대별)
3. 재사용 가능한 뷰 컴포넌트
4. Git 친화적

### Storyboard가 더 나은 경우:
- 프로토타입 앱
- 간단한 정적 UI
- 디자이너와 협업
- Interface Builder에 익숙함

---

## 🔧 프로그래매틱 UI 미리보기

Xcode에서 프로그래매틱 UI도 미리볼 수 있습니다!

### SwiftUI Preview 사용 (iOS 13+)

**MainViewController.swift에 추가**:
```swift
#if DEBUG
import SwiftUI

struct MainViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let vc = MainViewController()
            let nav = UINavigationController(rootViewController: vc)
            return nav
        }
    }
}

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: () -> ViewController
    
    init(_ viewController: @escaping () -> ViewController) {
        self.viewController = viewController
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        viewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
#endif
```

그러면 Canvas에서 미리보기 가능! (⌥⌘↩)

---

## 📚 더 알아보기

### Interface Builder vs Code
- [Apple - Interface Builder](https://developer.apple.com/xcode/interface-builder/)
- [Ray Wenderlich - Programmatic UI](https://www.kodeco.com/6004856-building-ios-interfaces-programmatically)

### Auto Layout
- [Apple - Auto Layout Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/)

---

## 🎨 결론

**현재 프로젝트를 그대로 사용하는 것을 추천합니다!**

이유:
1. ✅ 이미 완성되어 작동함
2. ✅ 확장 가능한 구조
3. ✅ Git 친화적
4. ✅ 실무에서 선호하는 방식

**Storyboard가 필요하다면**:
- 새로운 화면만 Storyboard로 추가 (하이브리드 방식)
- 또는 프로토타이핑용 별도 프로젝트 생성

---

**질문이 있으면 언제든 물어보세요!** 😊
