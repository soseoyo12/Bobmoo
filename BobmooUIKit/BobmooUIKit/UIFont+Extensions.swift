//
//  UIFont+Extensions.swift
//  BobmooUIKit
//
//  Created by SeongYongSong on 10/3/25.
//

import UIKit

extension UIFont {
    // MARK: - Pretendard Fonts
    
    static func pretendard(size: CGFloat, weight: Weight = .regular) -> UIFont {
        let fontName: String
        
        switch weight {
        case .thin:
            fontName = "Pretendard-Thin"
        case .ultraLight:
            fontName = "Pretendard-ExtraLight"
        case .light:
            fontName = "Pretendard-Light"
        case .regular:
            fontName = "Pretendard-Regular"
        case .medium:
            fontName = "Pretendard-Medium"
        case .semibold:
            fontName = "Pretendard-SemiBold"
        case .bold:
            fontName = "Pretendard-Bold"
        case .heavy:
            fontName = "Pretendard-ExtraBold"
        case .black:
            fontName = "Pretendard-Black"
        default:
            fontName = "Pretendard-Regular"
        }
        
        if let font = UIFont(name: fontName, size: size) {
            return font
        } else {
            print("⚠️ Failed to load font: \(fontName), using system font instead")
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
    
    // MARK: - Convenience Methods
    
    static func pretendardThin(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .thin)
    }
    
    static func pretendardLight(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .light)
    }
    
    static func pretendardRegular(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .regular)
    }
    
    static func pretendardMedium(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .medium)
    }
    
    static func pretendardSemiBold(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .semibold)
    }
    
    static func pretendardBold(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .bold)
    }
    
    static func pretendardExtraBold(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .heavy)
    }
    
    static func pretendardBlack(size: CGFloat) -> UIFont {
        return pretendard(size: size, weight: .black)
    }
}

// MARK: - Font Discovery Helper

extension UIFont {
    /// 사용 가능한 모든 폰트 패밀리와 폰트 이름 출력 (디버깅용)
    static func printAvailableFonts() {
        for family in UIFont.familyNames.sorted() {
            print("🔤 Font Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   - \(name)")
            }
        }
    }
    
    /// Pretendard 폰트가 정상적으로 로드되었는지 확인
    static func verifyPretendardFonts() -> Bool {
        let testFont = UIFont(name: "Pretendard-Regular", size: 12)
        if testFont != nil {
            print("✅ Pretendard fonts loaded successfully")
            return true
        } else {
            print("❌ Failed to load Pretendard fonts")
            return false
        }
    }
}
