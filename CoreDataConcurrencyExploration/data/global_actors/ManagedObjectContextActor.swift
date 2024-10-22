//
//  ManagedObjectContextActor.swift
//  CoreDataConcurrencyExploration
//
//  Created by William Dupont on 21/10/2024.
//

import CoreData

@globalActor
actor ManagedObjectContextActor: Actor {
    nonisolated private let executor: ManagedObjectContextExecutor
    nonisolated var unownedExecutor: UnownedSerialExecutor { self.executor.asUnownedSerialExecutor() }
    var moc: NSManagedObjectContext { self.executor.moc }
    
    static var shared: ManagedObjectContextActor = ManagedObjectContextActor(
        moc: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    )
    
    @ManagedObjectContextActor
    static var sharedMOC: NSManagedObjectContext { self.shared.executor.moc }
    
    private init(moc: NSManagedObjectContext) {
        self.executor = ManagedObjectContextExecutor(moc: moc)
        moc.persistentStoreCoordinator = DataController.shared.container.persistentStoreCoordinator
    }
}

final class ManagedObjectContextExecutor: SerialExecutor {
    nonisolated(unsafe) let moc: NSManagedObjectContext
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    func enqueue(_ job: consuming ExecutorJob) {
        nonisolated(unsafe) var job: ExecutorJob? = job
        
        self.moc.perform {
            job.take()?.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }
    
    func isSameExclusiveExecutionContext(other: ManagedObjectContextExecutor) -> Bool {
        self.moc == other.moc
    }
}
