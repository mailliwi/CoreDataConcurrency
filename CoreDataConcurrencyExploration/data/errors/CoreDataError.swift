//
//  CoreDataError.swift
//  ExplorationTwoPointO
//
//  Created by William Dupont on 26/09/2024.
//

enum CoreDataError: Error {
    case couldNotCreateEntity
    case couldNotDeleteEntity
    case couldNotFetchEntity
    case couldNotUpdateEntity
    case noChanges
    case noMatchingEntity
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .couldNotCreateEntity:
            "The entity could not be created."
        case .couldNotDeleteEntity:
            "The entity could not be deleted."
        case .couldNotFetchEntity:
            "The managed object type is invalid."
        case .couldNotUpdateEntity:
            "The entity could not be updated."
        case .noChanges:
            "No changes were made to the object."
        case .noMatchingEntity:
            "No matching entity."
        }
    }
}
