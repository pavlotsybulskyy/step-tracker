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
    
    private var isSteps: Bool { metric == .steps }
    
    var listData: [HealthMetric] {
        isSteps ? healthKitManager.stepData : healthKitManager.weightData
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                Text(data.date, format: .dateTime.month().day().year())
                Spacer()
                Text(data.value, format: .number.precision(.fractionLength(isSteps ? 0 : 1)))
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
                HStack {
                    Text(metric.title)
                    Spacer()
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
                            .unableToCompleteRequest:
                        EmptyView()
                    case .sharedDenied(let quantityType):
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
                        Task {
                            if isSteps {
                                do {
                                    try await healthKitManager.addStepData(for: addDataDate, value: Double(valuetoAdd)!)
                                    try await healthKitManager.fetchStepCount()
                                    isShowingAddData = false
                                } catch STError.sharedDenied(let quantityType) {
                                    writeError = .sharedDenied(quantityType: quantityType)
                                    isShowingAlert = true
                                } catch {
                                    writeError = .unableToCompleteRequest
                                    isShowingAlert = true
                                }
                            } else {
                                do {
                                    try await healthKitManager.addWeightData(for: addDataDate, value: Double(valuetoAdd)!)
                                    try await healthKitManager.fetchWeightsCount()
                                    try await healthKitManager.fetchWeightForDifferencials()
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
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
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
