//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 06.08.2025.
//

import SwiftUI

struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var healthKitManager
    
    @State private var isShowPermissionPrimingSheet: Bool = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert: Bool = false
    @State private var fetchError: STError = .noData
    
    var isSteps: Bool { selectedStat == .steps }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(selectedStat: selectedStat, chartData: healthKitManager.stepData)
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: healthKitManager.stepData))
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat, chartData: healthKitManager.weightData)
                        WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDifference(for: healthKitManager.weightDiffData))
                    }
                }
            }
            .padding()
            .task {
                do {
                    try await healthKitManager.fetchStepCount()
                    try await healthKitManager.fetchWeightsCount()
                    try await healthKitManager.fetchWeightForDifferencials()
                } catch STError.authNotDetermined {
                    isShowPermissionPrimingSheet = true
                } catch STError.noData {
                    fetchError = .noData
                    isShowingAlert = true
                } catch {
                    fetchError = .unableToCompleteRequest
                    isShowingAlert = true
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(
                isPresented: $isShowPermissionPrimingSheet,
                onDismiss: {
                    
                },
                content: {
                    HealthKitPermissionPrimingView()
                }
            )
            .alert(
                isPresented: $isShowingAlert,
                error: fetchError,
                actions: { fetchError in
                    // Actions
                },
                message: { fetchError in
                    Text(fetchError.failureReason)
                }
            )
        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
