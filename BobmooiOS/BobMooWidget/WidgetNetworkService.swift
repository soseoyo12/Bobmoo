//
//  WidgetNetworkService.swift
//  BobMooWidget
//
//  Created by SeongYongSong on 8/31/25.
//

import Foundation

// 위젯용 네트워크 서비스
enum WidgetNetworkService {
    static func fetchToday() async throws -> CampusMenu {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        let urlString = "https://585fd6cc3e1f.ngrok-free.app/api/v1/menu?date=\(today)"
        print("🌐 Widget API URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Widget HTTP Status: \(httpResponse.statusCode)")
        }
        
        print("📦 Widget 받은 데이터 크기: \(data.count) bytes")
        
        let decodedData = try JSONDecoder().decode(CampusMenu.self, from: data)
        print("✅ Widget 디코딩 성공: \(decodedData.cafeterias.count)개 식당")
        
        return decodedData
    }
}
