//
//  Untitled.swift
//  BabmooiOS
//
//  Created by SeongYongSong on 9/21/25.
//

import UIKit

func printAllSystemFonts() {
    for family in UIFont.familyNames.sorted() {
        print(family)
        for name in UIFont.fontNames(forFamilyName: family).sorted() {
            print("=== \(name)")
        }
    }
}
