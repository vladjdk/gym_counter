//
//  WorkoutStatsView.swift
//  gym_counter
//
//  Created by vlad on 1/1/25.
//


import SwiftUI
import CoreData
import HorizonCalendar

struct WorkoutStatsView: View {
    let totalWorkouts: Int
    let workoutStats: [WorkoutType: Int]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Total Workouts: \(totalWorkouts)")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    VStack {
                        Circle()
                            .fill(type.color)
                            .frame(width: 8, height: 8)
                        Text("\(workoutStats[type, default: 0])")
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.top)
    }
}