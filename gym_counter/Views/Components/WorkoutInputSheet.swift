//
//  WorkoutInputSheet.swift
//  gym_counter
//
//  Created by vlad on 1/1/25.
//


import SwiftUI
import CoreData
import HorizonCalendar

struct WorkoutInputSheet: View {
    let date: Date
    let existingWorkout: WorkoutEntity?
    @Binding var workoutType: WorkoutType
    @Binding var title: String
    @Binding var description: String
    let onSave: (String, String, WorkoutType) -> Void
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    Picker("Type", selection: $workoutType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section {
                    Button("Save") {
                        onSave(title, description, workoutType)
                    }
                    
                    if existingWorkout != nil {
                        Button("Delete", role: .destructive) {
                            onDelete()
                        }
                    }
                }
            }
            .navigationTitle(Text(date.formatted(date: .long, time: .omitted)))
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
        .onAppear {
            if let existing = existingWorkout {
                title = existing.title
                description = existing.workoutDescription
                if let type = WorkoutType(rawValue: existing.workoutType) {
                    workoutType = type
                }
            }
        }
    }
}