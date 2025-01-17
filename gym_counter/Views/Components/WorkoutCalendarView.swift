//
//  WorkoutCalendarView.swift
//  gym_counter
//
//  Created by vlad on 1/1/25.
//


import SwiftUI
import CoreData
import HorizonCalendar

struct WorkoutCalendarView: View {
    let calendar: Calendar
    let startDate: Date
    let endDate: Date
    let workoutStore: WorkoutStore
    @Binding var selectedDate: Date?
    @Binding var showingWorkoutSheet: Bool
    @StateObject private var calendarViewProxy = CalendarViewProxy()
    
    var body: some View {
        let now = Date()
        CalendarViewRepresentable(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .horizontal(options: HorizontalMonthsLayoutOptions()),
            dataDependency: workoutStore.workouts.count,
            proxy: calendarViewProxy
        )
        .onDaySelection { day in
            selectedDate = calendar.date(from: day.components)
            showingWorkoutSheet = true
        }
        .days { day in
            let date = calendar.date(from: day.components)!
            let workout = workoutStore.getWorkout(for: date)
            
            ZStack {
                Text("\(day.day)")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(UIColor.label))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                workout != nil ?
                                    .green :
                                    Color(UIColor.systemGray),
                                lineWidth: 1
                            )
                            .fill(
                                workout != nil ?
                                    .green.opacity(0.2) :
                                    Color.clear
                            )
                    }
                
                if let workout = workout,
                   let workoutType = WorkoutType(rawValue: workout.workoutType) {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(workoutType.color)
                                .frame(width: 8, height: 8)
                        }
                        .padding(.trailing, 5)
                        .padding(.top, 5)
                        Spacer()
                    }
                }
            }
        }
        .verticalDayMargin(8)
        .horizontalDayMargin(8)
        .padding(10.0)
        .onAppear {
            let calendar = Calendar.current
            
            let firstDayOfMonth = calendar.date(from:calendar.dateComponents([.year, .month], from: Date())) ?? Date()
            print(firstDayOfMonth)
            let components = calendar.dateComponents([.weekday], from: firstDayOfMonth)
            
            let weekday = components.weekday ?? 0
            
            print(weekday)
            print(components)
            
            var date = firstDayOfMonth
            
            if weekday != 1 && weekday != 0 {
                date = calendar.date(byAdding: .day, value: 7 - weekday + 1, to: date) ?? date
            }
            
            print(date)
            
            calendarViewProxy.scrollToDay(containing: date, scrollPosition: .firstFullyVisiblePosition, animated: false)
        }
    }
}
