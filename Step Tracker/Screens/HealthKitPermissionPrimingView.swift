//
//  HealthKitPermissionPrimingView.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 14.08.2025.
//

import SwiftUI
import HealthKitUI

struct HealthKitPermissionPrimingView: View {
    
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(\.dismiss) private var dissmiss
    
    @State private var isShowingHealthKitPermissions: Bool = false
        
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
                isShowingHealthKitPermissions = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
        .interactiveDismissDisabled()
        .healthDataAccessRequest(
            store: healthKitManager.store,
            shareTypes: healthKitManager.types,
            readTypes: healthKitManager.types,
            trigger: isShowingHealthKitPermissions) { result in
                switch result {
                case .success:
                    dissmiss()
                case .failure:
                    // handle the error later
                    dissmiss()
                }
            }
    }
}

#Preview {
    HealthKitPermissionPrimingView()
        .environment(HealthKitManager())
}
