//
//  mainView.swift
//  Camplate_iOS
//
//  Created by SeongYongSong on 8/14/25.
//

import SwiftUI
import WidgetKit

// 식사 시간 정렬을 위한 함수
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
        // 새벽~아침 전: 아침 → 점심 → 저녁
        return ["breakfast", "lunch", "dinner"]
    } else if currentTimeInMinutes >= breakfastStart && currentTimeInMinutes < breakfastEnd {
        // 아침 시간대: 아침 → 점심 → 저녁
        return ["breakfast", "lunch", "dinner"]
    } else if currentTimeInMinutes >= breakfastEnd && currentTimeInMinutes < lunchStart {
        // 아침~점심 사이: 점심 → 저녁 → 아침
        return ["lunch", "dinner", "breakfast"]
    } else if currentTimeInMinutes >= lunchStart && currentTimeInMinutes < lunchEnd {
        // 점심 시간대: 점심 → 저녁 → 아침
        return ["lunch", "dinner", "breakfast"]
    } else if currentTimeInMinutes >= lunchEnd && currentTimeInMinutes < dinnerStart {
        // 점심~저녁 사이: 저녁 → 아침 → 점심
        return ["dinner", "breakfast", "lunch"]
    } else if currentTimeInMinutes >= dinnerStart && currentTimeInMinutes < dinnerEnd {
        // 저녁 시간대: 저녁 → 아침 → 점심
        return ["dinner", "breakfast", "lunch"]
    } else {
        // 저녁 이후: 다음날 아침 → 점심 → 저녁
        return ["breakfast", "lunch", "dinner"]
    }
}

struct MenuLine: Identifiable {
    let id = UUID()
    let course: String
    let mainMenu: String
}

struct CanteenSection: Identifiable {
    let id = UUID()
    let name: String
    let lines: [MenuLine]
}

// 식사 블록 뷰
struct MealBlockView: View {
    let mealType: String
    let menu: CampusMenu?
    
    private var mealDisplayName: String {
        switch mealType {
        case "breakfast":
            return "아침"
        case "lunch":
            return "점심"
        case "dinner":
            return "저녁"
        default:
            return "아침"
        }
    }
    
    private var mealIcon: String {
        switch mealType {
        case "breakfast":
            return "sun.horizon"
        case "lunch":
            return "sun.max"
        case "dinner":
            return "moon"
        default:
            return "sun.horizon"
        }
    }
    
    var body: some View {
        VStack {
            HStack (alignment: .firstTextBaseline) {
                Image(systemName: mealIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
                    .padding(.leading, 25)
                
                Text(mealDisplayName)
                    .font(.system(size: 25))
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            if let menu = menu {
                let meals = makeMealArray(from: menu, mealType: mealType)
                
                if meals.isEmpty {
                    VStack {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("오늘의 \(mealDisplayName) 메뉴가 없습니다")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(meals) { cafeteria in
                        // 식당 이름과 운영시간
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(cafeteria.cafeteriaName)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                Text(cafeteria.operatingHours)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                // 각 식당별 운영 상태 표시 (운영전/운영중/운영종료/미운영)
                                let status = operatingState(operatingHours: cafeteria.operatingHours)
                                Text(status.text)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(status.color)
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.trailing, 8)
                            }
                            
 
                        }
                        .padding(.leading, 27)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        
                        // 해당 식당의 모든 메뉴들
                        if cafeteria.meals.isEmpty {
                            HStack {
                                Text("\(mealDisplayName) 메뉴 없음")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 30)
                                Spacer()
                            }
                        } else {
                            ForEach(cafeteria.meals) { meal in
                                HStack {
                                    Text(meal.course)
                                        .fontWeight(.medium)
                                        .padding(.leading, 30)
                                    Text(meal.mainMenu)
                                    Spacer()
                                }
                            }
                        }
                        
                        Divider()
                    }
                }
            }
        }
        .padding(.top, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.white))
                .shadow(radius: 3)
        )
        .padding()
    }
}

struct mainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var menu: CampusMenu?
    @State private var tapBounce = false
    @State private var error: String?
    @State private var cafeteriaMeals: [CafeteriaMeals] = []
    @State private var isLoading = false
    @State private var selectedDate: Date = Date()
    @State private var isShowingDatePicker: Bool = false

    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 0){
                    // Removed pastel blue area below the navigation bar, now handled by safeAreaInset
                    if isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("메뉴를 불러오는 중...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else if let error = error {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("오류가 발생했습니다")
                                .font(.headline)
                                .padding(.top, 8)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else if cafeteriaMeals.isEmpty {
                        VStack {
                            Image(systemName: "fork.knife")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("오늘의 메뉴가 없습니다")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        // 동적으로 식사 시간 순서에 따라 블록 생성
                        ForEach(getMealOrder(), id: \.self) { mealType in
                            MealBlockView(mealType: mealType, menu: menu)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("pastelBlue"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("인하대학교")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.primary)
                            .imageScale(.large)
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                HStack {
                    Button(action: { isShowingDatePicker = true }) {
                        HStack(spacing: 10) {
                            Text(dateLabel)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemFill))
                        .cornerRadius(59)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 30, alignment: .center) // 헤더 높이 고정, 중앙 정렬
                .padding(.top, 2)                      // 중앙보다 살짝 아래로
                .padding(.horizontal, 16)
                .background(Color("pastelBlue"))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            // Removed .background(Color("pastelBlue").ignoresSafeArea(edges: .top))
            .sheet(isPresented: $isShowingDatePicker) {
                VStack {
                    DatePicker(
                        "날짜 선택",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Button("완료") { isShowingDatePicker = false }
                        .padding(.top, 8)
                }
                .presentationDetents([.medium, .large])
            }
            .onChange(of: selectedDate) { newValue in
                Task { await loadMenuData(for: newValue) }
            }
            .task {
                await loadMenuData(for: selectedDate)
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    Task { await loadMenuData(for: selectedDate) }
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        return formatter.string(from: selectedDate)
    }
    
    private func loadMenuData(for date: Date) async {
        isLoading = true
        error = nil
        
        do {
            let menuData = try await NetworkService.fetch(date: date)
            await MainActor.run {
                self.menu = menuData
                self.cafeteriaMeals = makeMealArray(from: menuData, mealType: "breakfast")
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// 운영시간 체크 함수
func isOperatingNow(operatingHours: String) -> Bool {
    let now = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    let currentTime = formatter.string(from: now)
    
    // "미운영"인 경우 false
    if operatingHours.contains("미운영") {
        return false
    }
    
    // 시간 범위 파싱 (예: "08:00-09:30")
    let timeRange = operatingHours.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    let times = timeRange.components(separatedBy: "-")
    
    if times.count == 2 {
        let startTime = times[0].trimmingCharacters(in: .whitespaces)
        let endTime = times[1].trimmingCharacters(in: .whitespaces)
        
        return currentTime >= startTime && currentTime <= endTime
    }
    
    return false
}

// 운영 상태 계산: 운영전(회색), 운영중(파랑), 운영종료(빨강), 미운영(회색)
enum OperatingStateKind { case preOpen, open, closed, notOperating }

func operatingState(operatingHours: String, now: Date = Date()) -> (text: String, color: Color, kind: OperatingStateKind) {
    // 07시 특별 규칙: 전 식사 공통 '운영전'
    if Calendar.current.component(.hour, from: now) == 7 {
        return ("운영전", Color.gray.opacity(0.8), .preOpen)
    }

    if operatingHours.contains("미운영") {
        return ("미운영", Color.gray.opacity(0.6), .notOperating)
    }

    let range = operatingHours.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    let parts = range.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
    guard parts.count == 2,
          let start = dateForToday(hhmm: parts[0], base: now),
          let end = dateForToday(hhmm: parts[1], base: now) else {
        return ("운영종료", Color.red.opacity(0.8), .closed)
    }

    if now < start {
        return ("운영전", Color.gray.opacity(0.8), .preOpen)
    } else if now >= start && now <= end {
        return ("운영중", Color.blue.opacity(0.8), .open)
    } else {
        return ("운영종료", Color.red.opacity(0.8), .closed)
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

private func timeString(from date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    return f.string(from: date)
}

// 메뉴 배열 생성 함수
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

#Preview {
    mainView()
}
