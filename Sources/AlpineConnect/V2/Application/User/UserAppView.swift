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

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ConnectUser.self])
        
        let modelConfiguration = ModelConfiguration("Connect User Data", schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [ConnectUser]
    
    var body: some View {
        app
            .onAppear {
                ConnectManager.shared.user = users.first
                ConnectManager.shared.modelContainer = sharedModelContainer
            }
    }
}
