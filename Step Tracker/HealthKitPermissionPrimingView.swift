//
//  HealthKitPermissionPrimingView.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 14.08.2025.
//

import SwiftUI

struct HealthKitPermissionPrimingView: View {
    
    var description = """
        This app displays your steps and weight data in interactive charts.
        
        You can also add new steps and weight data to Apple Health from this app. Your data is private and secured.
        """
    
    var body: some View {
        VStack(spacing: 130) {
            VStack(alignment: .leading) {
                Image(.appleHealthIcon)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                    .padding(.bottom, 12)
                
                Text("Apple Health Integration")
                    .font(.title2).bold()
                
                Text(description)
                    .foregroundStyle(.secondary)
            }
            
            
            Button("Connect Apple Health") {
                // do code later
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
    }
}

#Preview {
    HealthKitPermissionPrimingView()
}
