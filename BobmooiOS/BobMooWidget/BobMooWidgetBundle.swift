//
//  BobMooWidgetBundle.swift
//  BobMooWidget
//
//  Created by SeongYongSong on 8/31/25.
//

import WidgetKit
import SwiftUI

@main
struct BobMooWidgetBundle: WidgetBundle {
    var body: some Widget {
        BobMooWidget()
        if #available(iOSApplicationExtension 16.1, *) {
            BobMooWidgetLiveActivity()
        }
    }
}
