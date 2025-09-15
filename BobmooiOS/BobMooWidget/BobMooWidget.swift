//
//  BobMooWidget.swift
//  BobMooWidget
//
//  Created by SeongYongSong on 8/31/25.
//

import WidgetKit
import SwiftUI
import Foundation

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

// 다음 식사 시간 결정 함수 (현재 시각 기준 가장 가까운 다음 식사)
// 기준 시간표: 아침 07:00-10:00, 점심 11:00-14:00, 저녁 16:30-19:30
private func makeDate(on base: Date, hour: Int, minute: Int) -> Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: base)
    components.hour = hour
    components.minute = minute
    components.second = 0
    return Calendar.current.date(from: components) ?? base
}

func getNextMealType(at date: Date = Date()) -> String {
    let breakfastStart = makeDate(on: date, hour: 7, minute: 0)
    let breakfastEnd = makeDate(on: date, hour: 10, minute: 0)
    let lunchStart = makeDate(on: date, hour: 11, minute: 0)
    let lunchEnd = makeDate(on: date, hour: 14, minute: 0)
    let dinnerStart = makeDate(on: date, hour: 16, minute: 30)
    let dinnerEnd = makeDate(on: date, hour: 19, minute: 30)

    // 다음으로 보여줄 식사 종류
    if date < breakfastStart { return "breakfast" }
    if date >= breakfastStart && date < breakfastEnd { return "breakfast" }
    if date < lunchStart { return "lunch" }
    if date >= lunchStart && date < lunchEnd { return "lunch" }
    if date < dinnerStart { return "dinner" }
    if date >= dinnerStart && date < dinnerEnd { return "dinner" }
    // 그 외(저녁 이후)는 다음 날 아침
    return "breakfast"
}

// 위젯 타임라인 갱신이 필요한 경계 시각들(오늘 이후, 내일 일부까지)
private func timelineChangeDates(from now: Date) -> [Date] {
    let calendar = Calendar.current
    let today = now
    let today_0700 = makeDate(on: today, hour: 7, minute: 0)
    let today_1000 = makeDate(on: today, hour: 10, minute: 0)
    let today_1100 = makeDate(on: today, hour: 11, minute: 0)
    let today_1400 = makeDate(on: today, hour: 14, minute: 0)
    let today_1630 = makeDate(on: today, hour: 16, minute: 30)
    let today_1930 = makeDate(on: today, hour: 19, minute: 30)

    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
    let tomorrow_0005 = makeDate(on: tomorrow, hour: 0, minute: 5)
    let tomorrow_0700 = makeDate(on: tomorrow, hour: 7, minute: 0)
    let tomorrow_1000 = makeDate(on: tomorrow, hour: 10, minute: 0)
    let tomorrow_1100 = makeDate(on: tomorrow, hour: 11, minute: 0)
    let tomorrow_1400 = makeDate(on: tomorrow, hour: 14, minute: 0)
    let tomorrow_1630 = makeDate(on: tomorrow, hour: 16, minute: 30)
    let tomorrow_1930 = makeDate(on: tomorrow, hour: 19, minute: 30)

    let allCandidates = [
        today_0700, today_1000, today_1100, today_1400, today_1630, today_1930,
        tomorrow_0005, tomorrow_0700, tomorrow_1000, tomorrow_1100, tomorrow_1400, tomorrow_1630, tomorrow_1930
    ]
    return allCandidates.filter { $0 > now }
}

// 식사 시간에 따른 운영시간 가져오기
func getOperatingHours(for mealType: String, hours: Hours) -> String {
    switch mealType {
    case "breakfast":
        return hours.breakfast
    case "lunch":
        return hours.lunch
    case "dinner":
        return hours.dinner
    default:
        return hours.breakfast
    }
}

// 운영 상태 계산 (위젯용): 운영전(회색), 운영중(파랑), 운영종료(빨강), 미운영(회색)
private func widgetOperatingState(operatingHours: String, date: Date = Date()) -> (text: String, color: Color) {
    if Calendar.current.component(.hour, from: date) == 7 {
        return ("운영전", Color.gray.opacity(0.8))
    }
    if operatingHours.contains("미운영") {
        return ("미운영", Color.gray.opacity(0.6))
    }

    let range = operatingHours.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    let parts = range.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
    guard parts.count == 2 else { return ("운영종료", Color.red.opacity(0.8)) }

    func toDate(_ s: String) -> Date? {
        let comps = s.split(separator: ":").compactMap { Int($0) }
        guard comps.count == 2 else { return nil }
        var dc = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dc.hour = comps[0]
        dc.minute = comps[1]
        dc.second = 0
        return Calendar.current.date(from: dc)
    }

    guard let start = toDate(parts[0]), let end = toDate(parts[1]) else {
        return ("운영종료", Color.red.opacity(0.8))
    }

    if date < start { return ("운영전", Color.gray.opacity(0.8)) }
    if date >= start && date <= end { return ("운영중", Color.blue.opacity(0.8)) }
    return ("운영종료", Color.red.opacity(0.8))
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), menu: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            do {
                let menu = try await WidgetNetworkService.fetchToday()
                print("📸 Widget Snapshot에서 받은 메뉴: \(menu.cafeterias.count)개 식당")
                let entry = SimpleEntry(date: Date(), menu: menu)
                completion(entry)
            } catch {
                print("❌ Widget Snapshot API 호출 실패: \(error)")
                // 실패 시 nil 데이터 사용
                let entry = SimpleEntry(date: Date(), menu: nil)
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let now = Date()
            let refreshAfterMidnight = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now))?.addingTimeInterval(5 * 60)
            do {
                let menu = try await WidgetNetworkService.fetchToday()
                print("🎯 Widget Timeline 메뉴 수신: \(menu.cafeterias.count)개 식당")

                var entries: [SimpleEntry] = []
                let changeDates = timelineChangeDates(from: now)

                // 현재 시각과 경계 시각들로 타임라인 구성
                entries.append(SimpleEntry(date: now, menu: menu))
                for date in changeDates {
                    entries.append(SimpleEntry(date: date, menu: menu))
                }

                let policyDate = refreshAfterMidnight ?? (changeDates.last ?? now.addingTimeInterval(60 * 60))
                let timeline = Timeline(entries: entries, policy: .after(policyDate))
                completion(timeline)
            } catch {
                print("❌ Widget API 호출 실패: \(error)")
                var entries: [SimpleEntry] = []
                let changeDates = timelineChangeDates(from: now)

                entries.append(SimpleEntry(date: now, menu: nil))
                for date in changeDates {
                    entries.append(SimpleEntry(date: date, menu: nil))
                }

                let policyDate = refreshAfterMidnight ?? (changeDates.last ?? now.addingTimeInterval(60 * 60))
                let timeline = Timeline(entries: entries, policy: .after(policyDate))
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let menu: CampusMenu?
}

struct BobMooWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - 1x1 (Small) Widget
struct SmallWidgetView: View {
    let entry: SimpleEntry
    @AppStorage(
        "selectedCafeteria",
        store: UserDefaults(suiteName: AppGroup.identifier)
    ) private var selectedCafeteria: String = "학생식당"
    
    private var filteredCafeterias: [Cafeteria] {
        guard let menu = entry.menu else { return [] }
        return menu.cafeterias.filter { $0.name == selectedCafeteria }
    }
    
    private var nextMealType: String { getNextMealType(at: entry.date) }
    
    private var mealTypeDisplayName: String {
        switch nextMealType {
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
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Image(systemName: nextMealType == "breakfast" ? "sun.horizon" : nextMealType == "lunch" ? "sun.max" : "moon")
                    .foregroundColor(.orange)
                    .font(.system(size: 16, weight: .medium))
                Text(mealTypeDisplayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 6)
            .padding(.top, 6)
            
            // 메뉴 내용
            if !filteredCafeterias.isEmpty {
                let _ = print("🍽️ SmallWidget 필터링된 메뉴 데이터: \(filteredCafeterias.map { "\($0.name): \($0.meals.breakfast?.map { $0.mainMenu } ?? [])" })")
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(filteredCafeterias.prefix(1)), id: \.name) { cafe in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(cafe.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                let operatingHours = getOperatingHours(for: nextMealType, hours: cafe.hours)
                                let status = widgetOperatingState(operatingHours: "(\(operatingHours))", date: entry.date)
                                Text(status.text)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(status.color)
                                    .cornerRadius(5)
                            }
                            
                            let meals = getMeals(for: nextMealType, meals: cafe.meals)
                            if let meals = meals, !meals.isEmpty {
                                ForEach(Array(meals.prefix(2)), id: \.course) { meal in
                                    HStack(spacing: 4) {
                                        Text(meal.course)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .frame(width: 12, alignment: .leading)
                                        Text(meal.mainMenu)
                                            .font(.system(size: 11, weight: .regular))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                }
                            } else {
                                Text("\(mealTypeDisplayName) 메뉴 없음")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)
            } else {
                VStack {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    Text("로딩중...")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    private func getMeals(for mealType: String, meals: Meals) -> [MenuItem]? {
        switch mealType {
        case "breakfast":
            return meals.breakfast
        case "lunch":
            return meals.lunch
        case "dinner":
            return meals.dinner
        default:
            return meals.breakfast
        }
    }
}

// MARK: - 1x2 (Medium) Widget
struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    private var filteredCafeterias: [Cafeteria] {
        guard let menu = entry.menu else { return [] }
        return menu.cafeterias // 1x2 위젯은 모든 식당 표시
    }
    
    private var nextMealType: String { getNextMealType(at: entry.date) }
    
    private var mealTypeDisplayName: String {
        switch nextMealType {
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
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Image(systemName: nextMealType == "breakfast" ? "sun.horizon" : nextMealType == "lunch" ? "sun.max" : "moon")
                    .foregroundColor(.orange)
                    .font(.system(size: 18, weight: .medium))
                Text("인하대 \(mealTypeDisplayName)메뉴")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
            .padding(.top, 6)
            
            // 메뉴 내용 - 가로 3등분 (학식/교식/생활관식당), 운영중/종료 배지 제거
            if !filteredCafeterias.isEmpty {
                let groups: [[String]] = [
                    ["학생식당", "학생 식당"],
                    ["교직원식당", "교직원 식당"],
                    ["생활관식당", "생활관 식당", "기숙사식당", "기숙사 식당"]
                ]
                let cafes = groups.compactMap { names in
                    filteredCafeterias.first { names.contains($0.name) }
                }

                HStack(alignment: .top, spacing: 8) {
                    ForEach(cafes, id: \.name) { cafe in
                        VStack(alignment: .leading, spacing: 4) {
                            // 식당명
                            Text(cafe.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)

                            // 운영시간 (운영중/종료 배지 제거)
                            let operatingHours = getOperatingHours(for: nextMealType, hours: cafe.hours)
                            Text(operatingHours)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)

                            // 메뉴 상위 2개
                            let meals = getMeals(for: nextMealType, meals: cafe.meals)
                            if let meals = meals, !meals.isEmpty {
                                ForEach(Array(meals.prefix(2)), id: \.course) { meal in
                                    Text("\(meal.course) \(meal.mainMenu)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                            } else {
                                Text("메뉴 없음")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }

                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
            } else {
                VStack {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                    Text("메뉴를 불러오는 중...")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    private func getMeals(for mealType: String, meals: Meals) -> [MenuItem]? {
        switch mealType {
        case "breakfast":
            return meals.breakfast
        case "lunch":
            return meals.lunch
        case "dinner":
            return meals.dinner
        default:
            return meals.breakfast
        }
    }
}

struct BobMooWidget: Widget {
    let kind: String = "BobMooWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BobMooWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("인하대 메뉴")
        .description("인하대학교 식당 메뉴를 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    BobMooWidget()
} timeline: {
    SimpleEntry(date: Date(), menu: nil)
}

#Preview(as: .systemMedium) {
    BobMooWidget()
} timeline: {
    SimpleEntry(date: Date(), menu: nil)
}
