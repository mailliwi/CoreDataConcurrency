//
//  ViewModel.swift
//  ExplorationTwoPointO
//
//  Created by William Dupont on 26/09/2024.
//

import Foundation

@MainActor
@Observable
final class ViewModel {
    let repository: TestResultRepository
    var testResults: [TestResult] = []
    
    init() {
        self.repository = TestResultRepository()
        self.repository.delegate = self
    }
    
    func fetchTestResults() {
        Task(priority: .userInitiated) {
            let testResults: [TestResult] = try await repository.fetchTestResults()
            print("Fetched \(testResults.count) test results.")
        }
    }
    
    func createTestResult(_ testResult: TestResult) {
        Task(priority: .userInitiated) {
            try await repository.createTestResult(testResult)
        }
    }
    
    func deleteTestResult(_ testResult: TestResult) {
        Task(priority: .userInitiated) {
            try await repository.deleteTestResult(testResult)
        }
    }
    
    func generateRandomTestResult() -> TestResult {
        let courses: [String] = [
            "Safeguarding Level 1",
            "Image Sharing",
            "Social Media",
            "TikTok",
            "Professional Development",
            "Instagram"
        ]
        
        let testNames: [String] = [
            "What Not To Do",
            "Best Practices",
            "All About This",
            "Do You Know Your Rights",
            "Yearly Recap",
            "Don't Forget This"
        ]
        
        let scores: [Int] = [100, 90, 80, 75, 70, 65]
        
        var testResult = TestResult()
        testResult.id = UUID()
        testResult.course = courses.randomElement()!
        testResult.testName = testNames.randomElement()!
        testResult.score = scores.randomElement()!
        testResult.isCertified = Bool.random()
        
        return testResult
    }
}

extension ViewModel: CoreDataChangeDelegate {
    
    @MainActor
    func emitLocal(_ data: [TestResult]) {
        self.testResults = data
    }
    
}
