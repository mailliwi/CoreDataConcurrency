//
//  TestResultsNetworkService.swift
//  CoreDataExploration
//
//  Created by William Dupont on 16/09/2024.
//

final class TestResultsNetworkService: NetworkService {
    
    func getTestResults() async throws -> [TestResult] {
        let testResultsURL: String = "https://5c5313ad-2a30-4fa0-ae41-27b129b4c386.mock.pstmn.io/testresults"
        
        do {
            let testResults: [TestResult] = try await requestData(at: testResultsURL)
            return testResults
        } catch {
            throw error
        }
    }
    
}
