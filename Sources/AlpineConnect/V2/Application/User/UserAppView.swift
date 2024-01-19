//
//  UserAppView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/16/24.
//

import SwiftUI
import SwiftData
import AlpineCore

struct UserAppView<App: View>: View {
    
    var userID: String
    
    @ViewBuilder var app: App
    
    @EnvironmentObject var manager: ConnectManager

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([CoreUser.self])
        let modelConfiguration = ModelConfiguration("Connect User Data", schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            CoreAppControl.shared.modelContainer = container
            
            return container
        } 
        catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [CoreUser]
    
    init(userID: String, @ViewBuilder app: () -> App ) {
        self.userID = userID
        self.app = app()
        _users = Query(filter: #Predicate<CoreUser> { $0.id == userID })
        CoreAppControl.shared.user = users.first ?? assingUser(id: userID)
    }
    
    var body: some View {
        app
            .environment(CoreAppControl.shared)
            .modelContainer(sharedModelContainer)
    }
    
    func assingUser(id: String) -> CoreUser {
        let user = CoreUser(id: id)
        sharedModelContainer.mainContext.insert(user)
        try? sharedModelContainer.mainContext.save()
        return user
    }
}
