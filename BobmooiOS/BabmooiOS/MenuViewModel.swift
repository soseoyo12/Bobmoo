//
//  Untitled.swift
//  Camplate_iOS
//
//  Created by SeongYongSong on 8/27/25.
//

// MenuViewModel.swift
import Foundation

@MainActor
class MenuViewModel: ObservableObject {
    @Published var today: CampusMenu?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchToday() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let url = URL(string: "https://0786777faf65.ngrok-free.app/api/v1/menu?date=2025-08-27") else {
            errorMessage = "잘못된 URL"
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else {
                errorMessage = "HTTP 실패"
                return
            }

            let decoded = try JSONDecoder().decode(CampusMenu.self, from: data)
            self.today = decoded

        } catch {
            errorMessage = "네트워크/디코딩 실패: \(error.localizedDescription)"
        }
    }
}
//
//  MenuViewModel.swift
//  BabmooiOS
//
//  Created by SeongYongSong on 8/31/25.
//

