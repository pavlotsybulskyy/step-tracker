//
//  AnnotationView.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 28.08.2025.
//

import SwiftUI

struct AnnotationView: View {
    let data: DateValueChartData
    let context: HealthMetricContext
    
    var isSteps: Bool {
        return context == .steps
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(
                data.date,
                format: .dateTime.weekday(.abbreviated).month(.abbreviated).day()
            )
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            
            Text(data.value, format: .number.precision(.fractionLength(isSteps ? 0 : 1)))
                .fontWeight(.heavy)
                .foregroundStyle(isSteps ? .pink : .indigo)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}
