//
//  WorkoutType.swift
//  gym_counter
//
//  Created by vlad on 1/1/25.
//


import SwiftUI
import CoreData
import HorizonCalendar

enum WorkoutType: String, Codable, CaseIterable {
    case chesttri = "Chest & Triceps"
    case backbi = "Back & Biceps"
    case shoulders = "Shoulders"
    case legs = "Legs"
    case other = "Other"
    
    var color: Color {
        switch self {
            case .chesttri: return .red
            case .backbi: return .blue
            case .shoulders: return .green
            case .legs: return .purple
            case .other: return .orange
        }
    }
}