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
        await delegate?.emitLocal(localTestResults)
        
        let remoteTestResults: [TestResult] = try await fetchRemoteTestResults()
        try await createOrUpdateTestResults(remoteTestResults)
        
        let upToDateLocalTestResults: [TestResult] = try await fetchLocalTestResults()
        await delegate?.emitLocal(upToDateLocalTestResults)
        
        return upToDateLocalTestResults
    }
    
    nonisolated func fetchLocalTestResults(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [TestResult] {
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
    
    @ManagedObjectContextActor
    func createOrUpdateTestResults(_ testResults: [TestResult]) throws {
        // 1. Get IDs
        let testResultIDs = testResults.compactMap { $0.id }
        let backgroundContext = ManagedObjectContextActor.sharedMOC
        let fetchRequest = TestResultEntity.fetchRequest()
        
        // 2.Get entities from local that match the IDs
        for testResultID in testResultIDs {
            fetchRequest.predicate = NSPredicate(format: "id == %@", testResultID as CVarArg)
            
            let entities: [TestResultEntity] = try backgroundContext.fetch(fetchRequest)
            
            // 3. Update entities for found IDs
            if let entity: TestResultEntity = entities.first(where: { $0.id == testResultID }) {
                let existingTestResult: TestResult = TestResult(from: entity)
                Task { try self.updateTestResult(existingTestResult) }
                
            // 4. Create new entities for not found IDs
            } else {
                if let newTestResult: TestResult = testResults.first(where: { $0.id == testResultID }) {
                    Task { try self.createTestResult(newTestResult) }
                }
            }
        }
    }
    
    @ManagedObjectContextActor
    func createTestResult(_ testResult: TestResult) throws {
        let backgroundContext = ManagedObjectContextActor.sharedMOC
        
        do {
            let entity: TestResultEntity = TestResultEntity(context: backgroundContext)
            setEntity(entity, fromValuesOf: testResult)
            
            try backgroundContext.save()
        } catch {
            throw error
        }
        
        Task { @MainActor in
            self.delegate?.emitLocal(try await self.fetchLocalTestResults())
        }
    }
    
    @ManagedObjectContextActor
    func updateTestResult(_ testResult: TestResult) throws {
        guard let testResultID = testResult.id else {
            throw CoreDataError.noMatchingEntity
        }
        
        let backgroundContext = ManagedObjectContextActor.sharedMOC
        let fetchRequest = TestResultEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", testResultID as CVarArg)
        
        do {
            let entities: [TestResultEntity] = try backgroundContext.fetch(fetchRequest)
            guard let entity: TestResultEntity = entities.first(where: { $0.id == testResultID }) else {
                throw CoreDataError.noMatchingEntity
            }
            
            setEntity(entity, fromValuesOf: testResult)
            
            try backgroundContext.save()
        } catch {
            throw error
        }
        
        Task { @MainActor in
            self.delegate?.emitLocal(try await self.fetchLocalTestResults())
        }
    }
    
    @ManagedObjectContextActor
    func deleteTestResult(_ testResult: TestResult) throws {
        guard let testResultID = testResult.id else {
            throw CoreDataError.noMatchingEntity
        }
        
        let backgroundContext = ManagedObjectContextActor.sharedMOC
        let fetchRequest = TestResultEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", testResultID as CVarArg)
        
        do {
            let entities: [TestResultEntity] = try backgroundContext.fetch(fetchRequest)
            guard let entity: TestResultEntity = entities.first(where: { $0.id == testResultID }) else {
                throw CoreDataError.noMatchingEntity
            }
            
            backgroundContext.delete(entity)
            
            try backgroundContext.save()
        } catch {
            throw error
        }
        
        Task { @MainActor in
            self.delegate?.emitLocal(try await self.fetchLocalTestResults())
        }
    }
    
    @ManagedObjectContextActor
    private func setEntity(_ entity: TestResultEntity, fromValuesOf domainModel: TestResult) {
        entity.id = domainModel.id
        entity.course = domainModel.course
        entity.testName = domainModel.testName
        entity.score = Int16(domainModel.score ?? 0)
        entity.isCertified = domainModel.isCertified ?? false
    }
    
}
