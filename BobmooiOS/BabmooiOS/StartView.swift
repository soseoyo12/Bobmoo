//
//  StartView.swift
//  BabmooiOS
//
//  Created by Codex on 8/31/25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack(spacing: 8) { // 숫자를 줄이면 더 가까워져요
            Image("BobmooLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            Text("밥묵자")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StartView()
}
