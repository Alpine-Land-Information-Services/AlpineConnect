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
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [CoreUser]
    
    init(userID: String, @ViewBuilder app: () -> App ) {
        self.userID = userID
        self.app = app()
        _users = Query(filter: #Predicate<CoreUser> { $0.id == userID })
    }

    var body: some View {
        if CoreAppControl.shared.user == nil {
            ProgressView()
                .scaleEffect(2)
                .onAppear {
                    Core.shared.assignUser(users.first ?? assingUser(id: userID))
                    Core.logAtlasConnectEvent(.syncStatus, type: .system, parameters: ["status" : "successful"])
                }
        }
        else {
            app
                .environment(Core.shared)
                .locationToggler
                .networkTracker
        }
    }
    
    func assingUser(id: String) -> CoreUser {
        let user = CoreUser(id: id)
        modelContext.insert(user)
        return user
    }
}
