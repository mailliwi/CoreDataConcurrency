//
//  DataController.swift
//  ExplorationTwoPointO
//
//  Created by William Dupont on 26/09/2024.
//

import CoreData

final class DataController: Sendable {
    
    /// Singleton instance.
    static let shared: DataController = DataController()
    
    /// Responsible for loading a Model and accessing the data that is inside.
    /// We have given it an initializer with the name `Bookworm` because that is
    /// the name of our `xcdatamodeld` file, aka the name of the NSPersistentContainer object,
    /// and we are using it as the container.
    let container: NSPersistentContainer = NSPersistentContainer(name: "MyDatabase")
    
    private init() {
        loadPersistentStores()
    }
    
    /// Sets up the container by loading data from the persistent stores.
    /// Executes the code inside the closure when done.
    private func loadPersistentStores() {
        container.loadPersistentStores { description, error in
            if let error {
                print("💿❌ CoreData failed to load data from the persistent stores.")
                print("ERROR DESCRIPTION: \(error.localizedDescription)")
                return
            }
            
            print("💿✅ CoreData was initialized.")
        }
    }
    
    /// Method that saves changes to the persistent container.
    /// This function has custom logic embedded into it, and acts as a "wrapper" around the original `save()` method.
    /// For instance, the custom logic here is that if there are no changes, the function returns early. But more logic can be added if necessary.
    public func saveChanges() throws {
        guard container.viewContext.hasChanges else { return }
        
        do {
            try container.viewContext.save()
            print("💾 Changes have been saved.")
            print("---------------------------")
        } catch {
            print("😞 Failed to save the context:", error.localizedDescription)
            throw CoreDataError.noChanges
        }
    }
    
}
