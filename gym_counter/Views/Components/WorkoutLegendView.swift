//
//  WorkoutLegendView.swift
//  gym_counter
//
//  Created by vlad on 1/1/25.
//


import SwiftUI
import CoreData
import HorizonCalendar

struct WorkoutLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workout Types")
                .font(.headline)
                .padding(.bottom, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    HStack {
                        Circle()
                            .fill(type.color)
                            .frame(width: 8, height: 8)
                        Text(type.rawValue)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}