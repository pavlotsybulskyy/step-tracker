//
//  StepBarChart.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 22.08.2025.
//

import SwiftUI
import Charts

struct StepBarChart: View {
    
    @State private var selectedDate: Date?
    @State private var selectedDay: Date?
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var averageStepCount: Double {
        guard !chartData.isEmpty else { return 0 }
        
        let totalSteps = chartData.reduce(0) { $0 + $1.value }
        return totalSteps / Double(chartData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let selectedDate else { return nil }
        
        return chartData.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        ChartContainer(
            title: "Steps",
            symbol: "figure.walk",
            subtitle: "Average \(Int(averageStepCount)) steps",
            context: selectedStat,
            isNav: true
        ) {
            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.bar",
                    title: "No Data",
                    description: "There is no step count data from Health App"
                )
            } else {
                Chart {
                    if let selectedHealthMetric {
                        RuleMark(x: .value("Selected metric", selectedHealthMetric.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(
                                position: .top,
                                spacing: 0,
                                overflowResolution: .init(x:.fit(to: .chart), y: .disabled),
                                content: { annotationView }
                            )
                    }
                    RuleMark(y: .value("Averages", averageStepCount))
                        .foregroundStyle(.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    ForEach(chartData) { steps in
                        BarMark(
                            x: .value("Date", steps.date, unit:. day),
                            y: .value("Steps", steps.value)
                        )
                        .foregroundStyle(.pink.gradient)
                        .opacity(selectedDate == nil || steps.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $selectedDate.animation(.easeInOut))
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.secondary.opacity(0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedDate) { oldValue, newValue in
            if oldValue?.weekday != newValue?.weekday {
                selectedDay = newValue
            }
        }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(
                selectedHealthMetric?.date ?? .now,
                format: .dateTime.weekday(.abbreviated).month(.abbreviated).day()
            )
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.pink)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    StepBarChart(selectedStat: .steps, chartData: MockData.steps)
}
