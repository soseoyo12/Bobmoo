//
//  mainViewVer2.swift
//  BabmooiOS
//
//  Created by SeongYongSong on 9/21/25.
//

import SwiftUI

struct mainViewVer2: View {
    var body: some View {
        HStack {
            Text("인하대학교 ")
                .font(.custom("Pretendard-Bold", size: 30))
            Spacer()
            Image(systemName: "gear")
        }

    }
}

#Preview {
    mainViewVer2()
}
