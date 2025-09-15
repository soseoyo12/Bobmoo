//
//  model.swift
//  BabmooiOS
//
//  Created by SeongYongSong on 8/31/25.
//

//
//  models.swift
//  Camplate_iOS
//
//  Created by SeongYongSong on 8/15/25.
//

import SwiftUI


/*
let sampleData = """
{
  "date": "2025-08-16",
  "univ": "인하대학교",
  "cafeterias": [
    {
      "restaurant": "학생식당",
      "hours": {
        "breakfast": "08:00-09:30",
        "lunch": "11:30-14:00",
        "dinner": "17:30-19:30"
      },
      "meals": {
        "breakfast": [
          { "course": "A", "mainMenu": "북어해장국", "price": 5200 },
          { "course": "B", "mainMenu": "에그스크램블 토스트", "price": 3000 }
        ],
        "lunch": [
          { "course": "A", "mainMenu": "치즈돈카츠 정식", "price": 7200 },
          { "course": "B", "mainMenu": "닭갈비 덮밥", "price": 6800 },
          { "course": "C", "mainMenu": "얼큰 어묵우동", "price": 5500 }
        ],
        "dinner": [
          { "course": "A", "mainMenu": "순두부찌개와 제육", "price": 6900 },
          { "course": "B", "mainMenu": "크림파스타", "price": 6500 }
        ]
      }
    },
    {
      "restaurant": "교직원식당",
      "hours": {
        "breakfast": "미운영",
        "lunch": "11:30-13:30",
        "dinner": "17:30-19:00"
      },
      "meals": {
        "lunch": [
          { "course": "A", "mainMenu": "한우미역국 정식", "price": 7800 },
          { "course": "B", "mainMenu": "훈제오리 샐러드", "price": 8500 }
        ],
        "dinner": [
          { "course": "A", "mainMenu": "고등어구이 정식", "price": 7200 },
          { "course": "B", "mainMenu": "버섯들깨수제비", "price": 6000 }
        ]
      }
    },
    {
      "restaurant": "기숙사식당",
      "hours": {
        "breakfast": "07:30-09:00",
        "lunch": "11:30-13:30",
        "dinner": "17:30-19:30"
      },
      "meals": {
        "breakfast": [
          { "course": "A", "mainMenu": "소시지 오므라이스", "price": 4800 },
          { "course": "B", "mainMenu": "그릭요거트 볼", "price": 3500 }
        ],
        "lunch": [
          { "course": "A", "mainMenu": "치킨마요 덮밥", "price": 5200 },
          { "course": "B", "mainMenu": "토마토 리조또", "price": 5800 }
        ],
        "dinner": [
          { "course": "A", "mainMenu": "김치찌개와 계란말이", "price": 6100 },
          { "course": "B", "mainMenu": "불고기 비빔면", "price": 5700 }
        ]
      }
    }
  ]
}
""".data(using: .utf8)!
*/


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

//View에서 Foreach문으로 깔끔하게 보여주기 위한 배열을 만들기위한 구조체
struct MealArray: Identifiable {
    let id = UUID()
    let cafeteria: String
    let course: String
    let mainMenu: String
    let price: Int
}

//식당별로 그룹화된 메뉴들을 위한 구조체
struct CafeteriaMeals: Identifiable {
    let id = UUID()
    let cafeteriaName: String
    let meals: [MealArray]
    let operatingHours: String
}








//JSON을 디코딩해서 구조체에 매핑
//let todayData = try? JSONDecoder().decode(CampusMenu.self, from: sampleData)






