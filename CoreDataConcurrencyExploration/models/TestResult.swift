//
//  TestResult.swift
//  ExplorationTwoPointO
//
//  Created by William Dupont on 26/09/2024.
//

import Foundation

struct TestResult: Identifiable, DomainModel {
    var id: UUID?
    var course: String?
    var testName: String?
    var score: Int?
    var isCertified: Bool?
    
    init(
        id: UUID? = UUID(),
        course: String? = nil,
        testName: String? = nil,
        score: Int? = nil,
        isCertified: Bool? = nil
    ) {
        self.id = id
        self.course = course
        self.testName = testName
        self.score = score
        self.isCertified = isCertified
    }
    
    init(from entity: TestResultEntity) {
        self.id = entity.id
        self.course = entity.course
        self.testName = entity.testName
        self.score = Int(entity.score)
        self.isCertified = entity.isCertified
    }
}

extension TestResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
