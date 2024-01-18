//
//  UserAppView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/16/24.
//

import SwiftUI
import SwiftData

struct UserAppView<App: View>: View {
    
    var userID: String
    
    @ViewBuilder var app: App
    
    @EnvironmentObject var manager: ConnectManager

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ConnectUser_MOVED_TO_CORE.self])
        
        let modelConfiguration = ModelConfiguration("Connect User Data", schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            ConnectManager.shared.modelContainer = container
            return container
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [ConnectUser_MOVED_TO_CORE]
    
    var body: some View {
        app
            .modelContainer(sharedModelContainer)
            .onAppear {
                manager.coreUser = users.first
            }
    }
}
