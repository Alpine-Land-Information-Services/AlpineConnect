//
//  LocationRequiremenModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/6/24.
//

import SwiftUI

struct LocationRequiremenModifier: ViewModifier {
    
    @EnvironmentObject var manager: LocationManager
    
    func body(content: Content) -> some View {
        switch manager.autorizationStatus {
        case .notDetermined:
            requestPermission
        case .denied, .restricted:
            turnOnPermission
        case .authorizedAlways, .authorizedWhenInUse:
            content
        @unknown default:
            content
        }
    }
    
    var requestPermission: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            ContentUnavailableView(label: {
                Label("Allow Location Services", systemImage: "location")
            }) {
                Text("\nThis application requires location services. \n\nPlease tap allow and confirm in the presented dialog to continue.")
            } actions: {
                Button {
                    manager.requestAuthorization()
                } label: {
                    Text("Allow")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .ignoresSafeArea()
    }
    
    var turnOnPermission: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            ContentUnavailableView(label: {
                Label("Location Services Disabled", systemImage: "location.slash")
            }) {
                Text("\nThis application requires location services for proper functionality. \n\nPlease enable in Settings to continue.")
            } actions: {
                Button {
                    openAppSettings()
                } label: {
                    Text("Settings")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .ignoresSafeArea()
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        
        UIApplication.shared.open(settingsUrl)
    }
}

public extension View {
    
    var locationRequirementTracker: some View {
        modifier(LocationRequiremenModifier())
    }
}
