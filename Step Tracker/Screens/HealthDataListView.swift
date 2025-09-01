//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 14.08.2025.
//

import SwiftUI

struct HealthDataListView: View {
    
    @Environment(HealthKitManager.self) private var healthKitManager
    
    @State private var isShowingAddData: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var writeError: STError = .noData
    @State private var addDataDate: Date = .now
    @State private var valuetoAdd: String = ""
        
    var metric: HealthMetricContext
    
    var listData: [HealthMetric] {
        isSteps ? healthKitManager.stepData : healthKitManager.weightData
    }
    
    private var isSteps: Bool { metric == .steps }
    
    var body: some View {
        List(listData.reversed()) { data in
            LabeledContent {
                Text(data.value, format: .number.precision(.fractionLength(isSteps ? 0 : 1)))
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                LabeledContent(metric.title) {
                    TextField("Value", text: $valuetoAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(isSteps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .alert(
                isPresented: $isShowingAlert,
                error: writeError,
                actions: { writeError in
                    switch writeError {
                    case .authNotDetermined,
                            .noData,
                            .unableToCompleteRequest,
                            .invalidValue:
                        EmptyView()
                    case .sharedDenied:
                        Button("Settings") {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                },
                message: { writeError in
                    Text(writeError.failureReason)
                }
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add data") {
                        addDataToHealthKit()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
    
    private func addDataToHealthKit() {
        guard let value = Double(valuetoAdd) else {
            writeError = .invalidValue
            isShowingAlert = true
            valuetoAdd = ""
            return
        }
        
        Task {
            do {
                if isSteps {
                    try await healthKitManager.addStepData(for: addDataDate, value: value)
                    healthKitManager.stepData = try await healthKitManager.fetchStepCount()
                } else {
                    try await healthKitManager.addWeightData(for: addDataDate, value: value)
                    async let weightsForLineCharts = healthKitManager.fetchWeights(daysBack: 28)
                    async let weightsForDiffBarChart = healthKitManager.fetchWeights(daysBack: 29)
                    
                    healthKitManager.weightData = try await weightsForLineCharts
                    healthKitManager.weightDiffData = try await weightsForDiffBarChart
                }
                
                isShowingAddData = false
            } catch STError.sharedDenied(let quantityType) {
                writeError = .sharedDenied(quantityType: quantityType)
                isShowingAlert = true
            } catch {
                writeError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .weight)
            .environment(HealthKitManager())
    }
}
