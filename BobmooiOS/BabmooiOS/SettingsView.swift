//
//  SettingsView.swift
//  BabmooiOS
//
//  Created by SeongYongSong on 8/31/25.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage(
        "selectedCafeteria",
        store: UserDefaults(suiteName: AppGroup.identifier)
    ) private var selectedCafeteria: String = "학생식당"
    
    // (stored value, display label). Stored value should match API cafeteria name.
    private let availableCafeterias = [
        ("학생식당", "학생식당"),
        ("교직원식당", "교직원식당"),
        ("기숙사식당", "생활관식당")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("위젯 설정")) {
                    Text("1x1 위젯에 표시할 식당을 선택하세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(availableCafeterias, id: \.0) { cafeteria in
                        HStack {
                            Text(cafeteria.1)
                                .font(.body)
                            
                            Spacer()
                            
                            if selectedCafeteria == cafeteria.0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCafeteria = cafeteria.0
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                }
                
                Section(header: Text("정보")) {
                    HStack {
                        Text("위젯 업데이트")
                        Spacer()
                        Text("6시간마다")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("지원 위젯 크기")
                        Spacer()
                        Text("1x1, 1x2")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("1x1 위젯")
                        Spacer()
                        Text("선택된 식당 1개")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("1x2 위젯")
                        Spacer()
                        Text("모든 식당 표시")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}
