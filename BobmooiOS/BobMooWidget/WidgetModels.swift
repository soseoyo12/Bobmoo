//
//  WidgetModels.swift
//  BobMooWidget
//
//  Created by SeongYongSong on 8/31/25.
//

import Foundation

// 위젯에서 사용할 데이터 모델들 (메인 앱과 동일)
struct CampusMenu: Codable {
    let date: String
    let school: String
    let cafeterias: [Cafeteria]
}

struct Cafeteria: Codable {
    let name: String
    let hours: Hours
    let meals: Meals
}

struct Hours: Codable {
    let breakfast: String
    let lunch: String
    let dinner: String
}

struct Meals: Codable {
    let breakfast: [MenuItem]?
    let lunch: [MenuItem]?
    let dinner: [MenuItem]?
}

struct MenuItem: Codable {
    let course: String
    let mainMenu: String
    let price: Int
}