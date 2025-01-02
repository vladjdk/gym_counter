//
//  WorkoutEntity.swift
//  gym_counter
//
//  Created by vlad on 1/1/25.
//


import SwiftUI
import CoreData
import HorizonCalendar

class WorkoutEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var workoutDescription: String
    @NSManaged public var workoutType: String
    @NSManaged public var date: Date
}