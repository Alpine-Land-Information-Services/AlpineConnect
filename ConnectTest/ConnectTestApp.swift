//
//  ConnectTestApp.swift
//  ConnectTest
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI
import AlpineConnect

@main
struct ConnectTestApp: App {
    
    @ObservedObject var updater = SwiftUIUpdater()

    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .onAppear {
//                    Tracker.shared.start(timeIntervalInSeconds: 10)
//                }
//                .modifier(UpdateCheckModifier(automatic: true))
//                .modifier(NotificationCheckModifier(timeIntervalInSeconds: 10, actions: nil))

        }
    }
}
