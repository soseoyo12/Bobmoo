//
//  addSubview.swift
//  Bobmoo-iOS-UIKit
//
//  Created by 송성용 on 11/4/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}

extension UIViewController {
    func addSubview(_ subview: UIView) {
        view.addSubview(subview)
    }
    
    func addSubviews(_ views: UIView...) {
        for view in views {
            self.view.addSubview(view)
        }
    }
}

