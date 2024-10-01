//
//  TestResultRowView.swift
//  ExplorationTwoPointO
//
//  Created by William Dupont on 30/09/2024.
//

import SwiftUI

struct TestResultRowView: View {
    let testResult: TestResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(testResult.testName ?? "Unknown Test")
                    .bold()
                    .font(.headline)
                HStack {
                    Text(testResult.course ?? "Unknown Course")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if testResult.isCertified ?? false {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.pink)
                                .frame(width: 8)
                            Text("CPD")
                                .font(.caption2)
                                .foregroundStyle(.pink)
                        }
                    }
                }
                Text(testResult.id?.uuidString ?? "Unknown ID")
                    .font(.caption)
                    .foregroundStyle(.teal)
            }
            Spacer()
            Text("\(testResult.score ?? 0)")
                .font(.largeTitle)
                .bold()
        }
        .fontDesign(.rounded)
    }
}
