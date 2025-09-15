//
//  BabmooiOSApp.swift
//  BabmooiOS
//
//  Created by SeongYongSong on 8/31/25.
//

import SwiftUI

@main
struct BabmooiOSApp: App {
    @State private var showStartView: Bool = true
    var body: some Scene {
        WindowGroup {
            Group {
                if showStartView {
                    StartView()
                } else {
                    ContentView()
                }
            }
            .task {
                // Show StartView for ~1.5 seconds
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                withAnimation(.easeInOut) {
                    showStartView = false
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
