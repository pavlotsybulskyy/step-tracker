//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 24.08.2025.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Weight", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        
                        Text("Average: 180 kgs")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                .padding(.bottom, 12)
            }
            .foregroundStyle(.secondary)
            
            Chart {
                ForEach(chartData) { weight in
                    AreaMark(
                        x: .value("Day", weight.date, unit: .day),
                        y: .value("Value", weight.value)
                    )
                    .foregroundStyle(Gradient(colors: [.blue.opacity(0.5), .clear]))
                    
                    LineMark(
                        x: .value("Day", weight.date, unit: .day),
                        y: .value("Value", weight.value)
                    )
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
