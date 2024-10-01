//
//  ContentView.swift
//  ExplorationTwoPointO
//
//  Created by William Dupont on 26/09/2024.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.testResults) { testResult in
                TestResultRowView(testResult: testResult)
                    .swipeActions {
                        Button {
                            viewModel.deleteTestResult(testResult)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
            }
            .navigationTitle("Test Results")
            .task(priority: .high) {
                viewModel.fetchTestResults()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.fetchTestResults()
                    } label: {
                        Label("Fetch", systemImage: "arrow.down")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.createTestResult(viewModel.generateRandomTestResult())
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
