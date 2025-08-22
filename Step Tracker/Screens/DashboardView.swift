//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 06.08.2025.
//

import SwiftUI

struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var healthKitManager
    
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowPermissionPrimingSheet: Bool = false
    @State private var selectedStat: HealthMetricContext = .steps
    
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
                    
                    StepBarChart(selectedStat: selectedStat, chartData: healthKitManager.stepData)
                    
                    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: healthKitManager.stepData))
                }
            }
            .padding()
            .task {
                await healthKitManager.fetchStepCount()
                isShowPermissionPrimingSheet = !hasSeenPermissionPriming
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
                    HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
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
