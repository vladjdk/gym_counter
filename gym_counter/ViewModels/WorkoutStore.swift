//
//  WorkoutStore.swift
//  gym_counter
//
//  Created by vlad on 1/1/25.
//


import SwiftUI
import CoreData
import HorizonCalendar

class WorkoutStore: ObservableObject {
    @Published var workouts: [WorkoutEntity] = []
    private let context: NSManagedObjectContext
    
    init() {
        context = CoreDataStack.shared.persistentContainer.viewContext
        loadWorkouts()
    }
    
    func loadWorkouts() {
        let request = NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntity.date, ascending: true)]
        
        do {
            workouts = try context.fetch(request)
            objectWillChange.send()
        } catch {
            print("Error fetching workouts: \(error)")
        }
    }
    
    func addWorkout(title: String, description: String, type: WorkoutType, date: Date) {
        let workout = WorkoutEntity(context: context)
        workout.id = UUID()
        workout.title = title
        workout.workoutDescription = description
        workout.workoutType = type.rawValue
        workout.date = date
        
        saveContext()
        loadWorkouts()
    }
    
    func removeWorkout(at date: Date) {
        let request = NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                      date as NSDate,
                                      Calendar.current.date(byAdding: .day, value: 1, to: date)! as NSDate)
        
        do {
            let workoutsToDelete = try context.fetch(request)
            workoutsToDelete.forEach { context.delete($0) }
            saveContext()
            loadWorkouts()
        } catch {
            print("Error deleting workout: \(error)")
        }
    }
    
    func getWorkout(for date: Date) -> WorkoutEntity? {
        return workouts.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
