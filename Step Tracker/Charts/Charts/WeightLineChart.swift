//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 24.08.2025.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    
    @State private var selectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: selectedDate)
    }
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var average: Double {
        return chartData.map { $0.value }.average
    }
    
    var body: some View {
        ChartContainer(chartType: .weightLine(average: average)) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                
                if !chartData.isEmpty {
                    RuleMark(y: .value("Goal", 155))
                        .foregroundStyle(.mint)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                }
                
                ForEach(chartData) { weight in
                    AreaMark(
                        x: .value("Day", weight.date, unit: .day),
                        yStart: .value("Value", weight.value),
                        yEnd: .value("Min value", minValue)
                    )
                    .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Day", weight.date, unit: .day),
                        y: .value("Value", weight.value)
                    )
                    .foregroundStyle(.indigo)
                    .interpolationMethod(.catmullRom)
                    .symbol(.circle)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $selectedDate.animation(.easeInOut))
            .chartForegroundStyleScale( chartData.isEmpty ? [:] : ["Goal - 155 kgs": .mint])
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.secondary.opacity(0.3))
                    AxisValueLabel()
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.line.downtrend.xyaxis",
                        title: "No Data",
                        description: "There is no weight data from Health App"
                    )
                }
            }
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            if oldValue?.weekday != newValue?.weekday {
                selectedDay = newValue
            }
        }
    }
}

#Preview {
    WeightLineChart(chartData: [])
}
