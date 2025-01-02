//
//  CoreDataStack.swift
//  gym_counter
//
//  Created by vlad on 1/1/25.
//


import SwiftUI
import CoreData
import HorizonCalendar

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let modelDescription = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let container = NSPersistentContainer(name: "WorkoutModel", managedObjectModel: createWorkoutModel())
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private func createWorkoutModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create the entity
        let workoutEntity = NSEntityDescription()
        workoutEntity.name = "WorkoutEntity"
        workoutEntity.managedObjectClassName = NSStringFromClass(WorkoutEntity.self)
        
        // Create attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.type = .uuid
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.type = .string
        
        let descriptionAttribute = NSAttributeDescription()
        descriptionAttribute.name = "workoutDescription"
        descriptionAttribute.type = .string
        
        let typeAttribute = NSAttributeDescription()
        typeAttribute.name = "workoutType"
        typeAttribute.type = .string
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.type = .date
        
        // Add attributes to entity
        workoutEntity.properties = [idAttribute, titleAttribute, descriptionAttribute, typeAttribute, dateAttribute]
        
        // Add entity to model
        model.entities = [workoutEntity]
        
        return model
    }
}