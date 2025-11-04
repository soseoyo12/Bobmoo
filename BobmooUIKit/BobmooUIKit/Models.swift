//
//  Models.swift
//  BobmooUIKit
//
//  Created by SeongYongSong on 10/3/25.
//

import Foundation
import UIKit

// MARK: - Main Data Models

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

// MARK: - View Helper Models

/// View에서 Foreach문으로 깔끔하게 보여주기 위한 배열을 만들기위한 구조체
struct MealArray {
    let cafeteria: String
    let course: String
    let mainMenu: String
    let price: Int
}

/// 식당별로 그룹화된 메뉴들을 위한 구조체
struct CafeteriaMeals {
    let cafeteriaName: String
    let meals: [MealArray]
    let operatingHours: String
}

// MARK: - Helper Functions

/// 식사 시간 정렬을 위한 함수
func getMealOrder() -> [String] {
    let now = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: now)
    let minute = calendar.component(.minute, from: now)
    let currentTimeInMinutes = hour * 60 + minute
    
    // 시간대별 기준 (분 단위)
    let breakfastStart = 7 * 60      // 07:00
    let breakfastEnd = 10 * 60       // 10:00
    let lunchStart = 11 * 60         // 11:00
    let lunchEnd = 14 * 60           // 14:00
    let dinnerStart = 16 * 60 + 30   // 16:30
    let dinnerEnd = 19 * 60 + 30     // 19:30
    
    // 현재 시간에 따라 가장 가까운/진행중인 식사를 우선 표시
    if currentTimeInMinutes < breakfastStart {
        return ["breakfast", "lunch", "dinner"]
    } else if currentTimeInMinutes >= breakfastStart && currentTimeInMinutes < breakfastEnd {
        return ["breakfast", "lunch", "dinner"]
    } else if currentTimeInMinutes >= breakfastEnd && currentTimeInMinutes < lunchStart {
        return ["lunch", "dinner", "breakfast"]
    } else if currentTimeInMinutes >= lunchStart && currentTimeInMinutes < lunchEnd {
        return ["lunch", "dinner", "breakfast"]
    } else if currentTimeInMinutes >= lunchEnd && currentTimeInMinutes < dinnerStart {
        return ["dinner", "breakfast", "lunch"]
    } else if currentTimeInMinutes >= dinnerStart && currentTimeInMinutes < dinnerEnd {
        return ["dinner", "breakfast", "lunch"]
    } else {
        return ["breakfast", "lunch", "dinner"]
    }
}

/// 메뉴 배열 생성 함수
func makeMealArray(from menu: CampusMenu, mealType: String) -> [CafeteriaMeals] {
    var result: [CafeteriaMeals] = []
    
    for cafe in menu.cafeterias {
        var meals: [MealArray] = []
        var operatingHours: String = ""
        
        switch mealType {
        case "breakfast":
            if let breakfast = cafe.meals.breakfast {
                meals = breakfast.map { item in
                    MealArray(
                        cafeteria: cafe.name,
                        course: item.course,
                        mainMenu: item.mainMenu,
                        price: item.price
                    )
                }
            }
            operatingHours = "(\(cafe.hours.breakfast))"
            
        case "lunch":
            if let lunch = cafe.meals.lunch {
                meals = lunch.map { item in
                    MealArray(
                        cafeteria: cafe.name,
                        course: item.course,
                        mainMenu: item.mainMenu,
                        price: item.price
                    )
                }
            }
            operatingHours = "(\(cafe.hours.lunch))"
            
        case "dinner":
            if let dinner = cafe.meals.dinner {
                meals = dinner.map { item in
                    MealArray(
                        cafeteria: cafe.name,
                        course: item.course,
                        mainMenu: item.mainMenu,
                        price: item.price
                    )
                }
            }
            operatingHours = "(\(cafe.hours.dinner))"
            
        default:
            break
        }
        
        // 메뉴가 있거나 운영시간이 "미운영"이 아닌 경우 표시
        if !meals.isEmpty || !operatingHours.contains("미운영") {
            result.append(CafeteriaMeals(
                cafeteriaName: cafe.name,
                meals: meals,
                operatingHours: operatingHours
            ))
        }
    }
    return result
}

// MARK: - Operating State

enum OperatingStateKind {
    case preOpen, open, closed, notOperating
}

struct OperatingState {
    let text: String
    let color: UIColor
    let kind: OperatingStateKind
}

/// 운영 상태 계산: 운영전(회색), 운영중(파랑), 운영종료(빨강), 미운영(회색)
func operatingState(operatingHours: String, now: Date = Date()) -> OperatingState {
    // 07시 특별 규칙: 전 식사 공통 '운영전'
    if Calendar.current.component(.hour, from: now) == 7 {
        return OperatingState(text: "운영전", color: UIColor.gray.withAlphaComponent(0.8), kind: .preOpen)
    }

    if operatingHours.contains("미운영") {
        return OperatingState(text: "미운영", color: UIColor.gray.withAlphaComponent(0.6), kind: .notOperating)
    }

    let range = operatingHours.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    let parts = range.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
    guard parts.count == 2,
          let start = dateForToday(hhmm: parts[0], base: now),
          let end = dateForToday(hhmm: parts[1], base: now) else {
        return OperatingState(text: "운영종료", color: UIColor.red.withAlphaComponent(0.8), kind: .closed)
    }

    if now < start {
        return OperatingState(text: "운영전", color: UIColor.gray.withAlphaComponent(0.8), kind: .preOpen)
    } else if now >= start && now <= end {
        return OperatingState(text: "운영중", color: UIColor.blue.withAlphaComponent(0.8), kind: .open)
    } else {
        return OperatingState(text: "운영종료", color: UIColor.red.withAlphaComponent(0.8), kind: .closed)
    }
}

private func dateForToday(hhmm: String, base: Date) -> Date? {
    let comps = hhmm.split(separator: ":").compactMap { Int($0) }
    guard comps.count == 2 else { return nil }
    var dc = Calendar.current.dateComponents([.year, .month, .day], from: base)
    dc.hour = comps[0]
    dc.minute = comps[1]
    dc.second = 0
    return Calendar.current.date(from: dc)
}
