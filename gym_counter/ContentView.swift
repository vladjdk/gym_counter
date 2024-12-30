import SwiftUI
import CoreData
import HorizonCalendar

// Core Data model class
class WorkoutEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var workoutDescription: String
    @NSManaged public var workoutType: String
    @NSManaged public var date: Date
}

// Create the Core Data model programmatically
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

// ViewModel to handle workout data
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
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: now))!
        let endDate = calendar.date(byAdding: DateComponents(day: calendar.range(of: .day, in: .year, for: now)!.count - 1), to: startDate)!
        
        VStack(spacing: 16) {
            // Workout Counter
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
            
            CalendarViewRepresentable(
                calendar: calendar,
                visibleDateRange: startDate...endDate,
                monthsLayout: .horizontal(options: HorizontalMonthsLayoutOptions()),
                dataDependency: workoutStore.workouts.count
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
                        .background(
                            workout != nil ?
                                .green.opacity(0.2) :
                                Color.clear
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    workout != nil ?
                                        .green :
                                        Color(UIColor.systemGray),
                                    lineWidth: 1
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
            
            // Legend
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

#Preview {
    ContentView()
}
