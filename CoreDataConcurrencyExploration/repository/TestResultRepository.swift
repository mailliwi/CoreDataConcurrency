//
//  TestResultRepository.swift
//  ExplorationTwoPointO
//
//  Created by William Dupont on 26/09/2024.
//

import CoreData

actor TestResultRepository {
    private let networkService: TestResultsNetworkService
    
    @MainActor weak var delegate: (any CoreDataChangeDelegate<TestResult>)?
    
    init() {
        self.networkService = TestResultsNetworkService()
    }
    
    func fetchTestResults() async throws -> [TestResult] {
        let localTestResults: [TestResult] = try await fetchLocalTestResults()
        await MainActor.run { delegate?.emitLocal(localTestResults) }
        
        let remoteTestResults: [TestResult] = try await fetchRemoteTestResults()
        try await createOrUpdateTestResults(remoteTestResults)
        
        let upToDateLocalTestResults: [TestResult] = try await fetchLocalTestResults()
        await MainActor.run { delegate?.emitLocal(upToDateLocalTestResults) }
        
        return upToDateLocalTestResults
    }
    
    func fetchLocalTestResults(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [TestResult] {
        let backgroundContext = DataController.shared.container.newBackgroundContext()
        let fetchRequest = TestResultEntity.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        return try await backgroundContext.perform {
            let entities = try backgroundContext.fetch(fetchRequest)
            let testResults: [TestResult] = entities.map { TestResult(from: $0) }
            
            return testResults
        }
    }
    
    func fetchRemoteTestResults() async throws -> [TestResult] {
        let remoteTestResults: [TestResult] = try await networkService.getTestResults()
        return remoteTestResults
    }
    
    func createOrUpdateTestResults(_ testResults: [TestResult]) async throws {
        // 1. Get IDs
        let testResultsIDs = testResults.compactMap { $0.id }
        let backgroundContext = DataController.shared.container.newBackgroundContext()
        let fetchRequest = TestResultEntity.fetchRequest()
        
        // 2.Get entities from local that match the IDs
        for testResultID in testResultsIDs {
            fetchRequest.predicate = NSPredicate(format: "id == %@", testResultID as CVarArg)
            
            try await backgroundContext.perform {
                let entities: [TestResultEntity] = try backgroundContext.fetch(fetchRequest)
                
                // 3. Update entities for found IDs
                if let entity: TestResultEntity = entities.first(where: { $0.id == testResultID }) {
                    let existingTestResult: TestResult = TestResult(from: entity)
                    Task { try await self.updateTestResult(existingTestResult) }
                    
                // 4. Create new entities for not found IDs
                } else {
                    if let newTestResult: TestResult = testResults.first(where: { $0.id == testResultID }) {
                        Task { try await self.createTestResult(newTestResult) }
                    }
                }
            }
        }
    }
    
    func createTestResult(_ testResult: TestResult) async throws {
        let backgroundContext = DataController.shared.container.newBackgroundContext()
        
        try await backgroundContext.perform {
            do {
                let entity = TestResultEntity(context: backgroundContext)
                
                self.setEntity(entity, fromValuesOf: testResult)
                
                try backgroundContext.save()
                
                // Logic to be reviewed for the below:
                // the createTestResult() method is called in a loop in createOrUpdateTestResults(),
                // therefore fetching all local test results with fetchLocalTestResults() at each pass of
                // the for-loop, like it is currently done below, is expensive
                
                // Potential solutions:
                // 1. batch update, transforming this method into one that accepts an array instead of a single value.
                // 2. deferring the emission in the createOrUpdateTestResults() method
                await MainActor.run { delegate?.emitLocal(fetchLocalTestResults()) }
            } catch {
                throw error
            }
        }
    }
    
    func updateTestResult(_ testResult: TestResult) async throws {
        guard let testResultID = testResult.id else {
            throw CoreDataError.noMatchingEntity
        }
        
        let backgroundContext = DataController.shared.container.newBackgroundContext()
        let fetchRequest = TestResultEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", testResultID as CVarArg)
        
        try await backgroundContext.perform {
            do {
                let entities: [TestResultEntity] = try backgroundContext.fetch(fetchRequest)
                guard let entity: TestResultEntity = entities.first(where: { $0.id == testResultID }) else {
                    throw CoreDataError.noMatchingEntity
                }
                
                self.setEntity(entity, fromValuesOf: testResult)
                
                try backgroundContext.save()
                
                // Logic to be reviewed for the below:
                // the updateTestResult() method is called in a loop in createOrUpdateTestResults(),
                // therefore fetching all local test results with fetchLocalTestResults() at each pass of
                // the for-loop, like it is currently done below, is expensive
                
                // Potential solutions:
                // 1. batch update, transforming this method into one that accepts an array instead of a single value.
                // 2. deferring the emission in the createOrUpdateTestResults() method
                await MainActor.run { delegate?.emitLocal(fetchLocalTestResults()) }
            } catch {
                throw error
            }
        }
    }
    
    func deleteTestResult(_ testResult: TestResult) async throws {
        guard let testResultID = testResult.id else {
            throw CoreDataError.noMatchingEntity
        }
        
        let backgroundContext = DataController.shared.container.newBackgroundContext()
        let fetchRequest = TestResultEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", testResultID as CVarArg)
        
        try await backgroundContext.perform {
            do {
                let entities: [TestResultEntity] = try backgroundContext.fetch(fetchRequest)
                guard let entity: TestResultEntity = entities.first(where: { $0.id == testResultID }) else {
                    throw CoreDataError.noMatchingEntity
                }
                
                backgroundContext.delete(entity)
                
                try backgroundContext.save()
                
                await MainActor.run {delegate?.emitLocal(fetchLocalTestResults()) }
            } catch {
                throw error
            }
        }
        
        return
    }
    
    private func setEntity(_ entity: TestResultEntity, fromValuesOf domainModel: TestResult) {
        entity.id = domainModel.id
        entity.course = domainModel.course
        entity.testName = domainModel.testName
        entity.score = Int16(domainModel.score ?? 0)
        entity.isCertified = domainModel.isCertified ?? false
    }
    
}
