//
//  UIColor+Extensions.swift
//  BobmooUIKit
//
//  Created by SeongYongSong on 10/3/25.
//

import UIKit

extension UIColor {
    // MARK: - Custom Colors
    
    /// 커스텀 pastelBlue 컬러를 반환하는 메서드
    static func customPastelBlue() -> UIColor {
        return UIColor(named: "pastelBlue") ?? .systemBlue
    }
    
    // MARK: - Convenience Methods
    
    /// 투명도를 적용한 색상 생성 헬퍼
    func withAlpha(_ alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
    
    // MARK: - Dynamic Colors for Dark Mode Support
    
    /// 라이트/다크 모드에 대응하는 동적 색상 생성
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}
