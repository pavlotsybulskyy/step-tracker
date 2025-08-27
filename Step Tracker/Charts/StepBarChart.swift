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
    
    var body: some View {
        let config = ChartContainerConfiguration(
            title: "Steps",
            symbol: "figure.walk",
            subtitle: "Average \(Int(ChartHelper.averageValue(for: chartData))) steps",
            context: .steps,
            isNav: true
        )
        
        ChartContainer(config: config) {
            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.bar",
                    title: "No Data",
                    description: "There is no step count data from Health App"
                )
            } else {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .steps)
                    }
                    RuleMark(y: .value("Averages", ChartHelper.averageValue(for: chartData)))
                        .foregroundStyle(.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    ForEach(chartData) { steps in
                        BarMark(
                            x: .value("Date", steps.date, unit:. day),
                            y: .value("Steps", steps.value)
                        )
                        .foregroundStyle(.pink.gradient)
                        .opacity(selectedDate == nil || steps.date == selectedData?.date ? 1.0 : 0.3)
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
}

#Preview {
    StepBarChart(chartData: [])
}
