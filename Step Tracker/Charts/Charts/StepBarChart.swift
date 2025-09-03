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
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: selectedDate)
    }
    
    var averageSteps: Int {
        Int(chartData.map { $0.value }.average)
    }
    
    var body: some View {
        ChartContainer(chartType: .stepBar(average: averageSteps)) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .steps)
                }
                if !chartData.isEmpty {
                    RuleMark(y: .value("Averages", averageSteps))
                        .foregroundStyle(.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                        .accessibilityHidden(true)
                }
               
                ForEach(chartData) { steps in
                    Plot {
                        BarMark(
                            x: .value("Date", steps.date, unit: .day),
                            y: .value("Steps", steps.value)
                        )
                        .foregroundStyle(.pink.gradient)
                        .opacity(selectedDate == nil || steps.date == selectedData?.date ? 1.0 : 0.3)
                    }
                    .accessibilityLabel(steps.date.formatted(.dateTime.month(.wide).day()))
                    .accessibilityValue("\(Int(steps.value)) steps")
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
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.bar",
                        title: "No Data",
                        description: "There is no step count data from Health App"
                    )
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
}

#Preview {
    StepBarChart(chartData: ChartHelper.convert(data: MockData.steps))
}
