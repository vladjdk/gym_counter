//
//  ContentView.swift
//  gym_counter
//
//  Created by vlad on 12/28/24.
//

import SwiftUI
import HorizonCalendar

struct DateData: Codable {
    var workoutData: WorkoutData
}

struct WorkoutData: Codable {
    var title: String
    var workoutType: WorkoutTypeEnumerator
}

enum WorkoutTypeEnumerator: Codable {
    case chesttri
    case backbi
    case shoulders
    case legs
    case other
}

struct ContentView: View {
    @AppStorage("workout_count") private var workout_count = 0
    @AppStorage("workout_count_20th") private var workout_count_20th: Int = 0
    
    @State private var selectedDate: Date?
    @State private var editingDate: Date?
    
    var body: some View {
        let calendar = Calendar.current
        
        let now = Date()
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: now))!
        let endDate = calendar.date(byAdding: DateComponents(day: calendar.range(of: .day, in: .year, for: now)!.count - 1), to: startDate)!
        
        CalendarViewRepresentable(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .horizontal(options: HorizontalMonthsLayoutOptions()),
            dataDependency: nil
        )
        .onDaySelection { day in
            if editingDate != nil {
                editingDate = nil
                selectedDate = nil
            }
            else if selectedDate != nil {
                editingDate = calendar.date(from: day.components)
                selectedDate = nil
            } else {
                selectedDate = calendar.date(from: day.components)
            }
        }
        .days { [selectedDate, editingDate] day in
            let date = calendar.date(from: day.components)
            let borderColor: UIColor = date == editingDate ? .systemGreen : date == selectedDate ? .systemBlue : .systemRed
            
            Text("\(day.day)")
                .font(.system(size: 18))
                .foregroundStyle(Color(UIColor.label))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(borderColor), lineWidth: 1)
                }
        }
        .verticalDayMargin(8)
        .horizontalDayMargin(8)
        .padding(10.0)
    }
}

#Preview {
    ContentView()
}
