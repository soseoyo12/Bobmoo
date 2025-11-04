//
//  NetworkService.swift
//  BobmooUIKit
//
//  Created by SeongYongSong on 10/3/25.
//

import Foundation

enum NetworkService {
    /// Fetch menu for a specific date (yyyy-MM-dd)
    static func fetch(date: Date) async throws -> CampusMenu {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        let urlString = "https://bobmoo.site/api/v1/menu?date=\(dateString)"
        print("🌐 API URL: \(urlString)")
        print("📅 요청 날짜: \(dateString)")

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("📡 HTTP Status: \(httpResponse.statusCode)")
        }

        print("📦 받은 데이터 크기: \(data.count) bytes")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 API 응답 내용: \(responseString)")
        }

        let decodedData = try JSONDecoder().decode(CampusMenu.self, from: data)
        print("✅ 디코딩 성공: \(decodedData.cafeterias.count)개 식당")
        return decodedData
    }

    /// Backward-compatible: fetch for today
    static func fetchToday() async throws -> CampusMenu {
        try await fetch(date: Date())
    }
}
