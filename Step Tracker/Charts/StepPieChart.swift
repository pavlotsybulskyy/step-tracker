//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 22.08.2025.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    var charData: [WeekdayChartData]
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(.pink)
                
                Text("Last 28 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)
            
            Chart {
                ForEach(charData) { weekday in
                    SectorMark(
                        angle: .value("Average Steps", weekday.value),
                        innerRadius: .ratio(0.618),
                        angularInset: 1
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(6)
                }
            }
            .frame(height: 240)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    StepPieChart(charData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
