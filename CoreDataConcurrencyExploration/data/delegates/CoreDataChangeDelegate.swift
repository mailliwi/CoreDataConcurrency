//
//  CoreDataChangeDelegate.swift
//  ExplorationTwoPointO
//
//  Created by William Dupont on 26/09/2024.
//

@MainActor
protocol CoreDataChangeDelegate<DataType>: AnyObject {
    associatedtype DataType: DomainModel
    
    func emitLocal(_ data: [DataType])
}
