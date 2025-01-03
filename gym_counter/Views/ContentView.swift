import SwiftUI
import CoreData
import HorizonCalendar

struct ContentView: View {
    @StateObject private var workoutStore = WorkoutStore()
    @State private var selectedDate: Date?
    @State private var showingWorkoutSheet = false
    @State private var selectedWorkoutType: WorkoutType = .chesttri
    @State private var workoutTitle: String = ""
    @State private var workoutDescription: String = ""
    
    var workoutStats: [WorkoutType: Int] {
        var stats: [WorkoutType: Int] = [:]
        for workout in workoutStore.workouts {
            if let type = WorkoutType(rawValue: workout.workoutType) {
                stats[type, default: 0] += 1
            }
        }
        return stats
    }
    
    var totalWorkouts: Int {
        workoutStore.workouts.count
    }
    
    var body: some View {
        let calendar = Calendar.current
        
        let now = Date()
        let startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        let endDate = calendar.date(byAdding: .year, value: 1, to: now)!
        
        VStack(spacing: 16) {
            // Workout Counter
            WorkoutStatsView(totalWorkouts: totalWorkouts, workoutStats: workoutStats)
            
            WorkoutCalendarView(calendar: calendar, startDate: startDate, endDate: endDate, workoutStore: workoutStore, selectedDate: $selectedDate, showingWorkoutSheet: $showingWorkoutSheet)
            
            WorkoutLegendView()
        }
        .sheet(isPresented: $showingWorkoutSheet) {
            WorkoutInputSheet(
                date: selectedDate ?? Date(),
                existingWorkout: selectedDate.flatMap { workoutStore.getWorkout(for: $0) },
                workoutType: $selectedWorkoutType,
                title: $workoutTitle,
                description: $workoutDescription,
                onSave: { title, description, type in
                    if let date = selectedDate {
                        workoutStore.removeWorkout(at: date)
                        workoutStore.addWorkout(
                            title: title,
                            description: description,
                            type: type,
                            date: date
                        )
                    }
                    showingWorkoutSheet = false
                    workoutTitle = ""
                    workoutDescription = ""
                },
                onDelete: {
                    if let date = selectedDate {
                        workoutStore.removeWorkout(at: date)
                    }
                    showingWorkoutSheet = false
                    workoutTitle = ""
                    workoutDescription = ""
                }
            )
        }
    }
}



#Preview {
    ContentView()
}
