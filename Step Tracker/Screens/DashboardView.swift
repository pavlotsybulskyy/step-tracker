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
                        StepBarChart(
                            chartData: ChartHelper.convert(data: healthKitManager.stepData)
                        )
                        StepPieChart(
                            chartData: ChartMath.averageWeekdayCount(for: healthKitManager.stepData)
                        )
                    case .weight:
                        WeightLineChart(
                            chartData: ChartHelper.convert(data: healthKitManager.weightData)
                        )
                        WeightDiffBarChart(
                            chartData: ChartMath.averageDailyWeightDifference(for: healthKitManager.weightDiffData)
                        )
                    }
                }
            }
            .padding()
            .task { fetchHealthData() }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .fullScreenCover(
                isPresented: $isShowPermissionPrimingSheet,
                onDismiss: {
                    fetchHealthData()
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
        .tint(selectedStat == .steps ? .pink : .indigo)
    }
    
    private func fetchHealthData() {
        Task {
            do {
                async let steps = healthKitManager.fetchStepCount()
                async let weightsForLineCharts = healthKitManager.fetchWeights(daysBack: 28)
                async let weightsForDiffBarChart = healthKitManager.fetchWeights(daysBack: 29)
                
                healthKitManager.stepData = try await steps
                healthKitManager.weightData = try await weightsForLineCharts
                healthKitManager.weightDiffData = try await weightsForDiffBarChart
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
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
