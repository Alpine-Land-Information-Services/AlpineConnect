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
                    CoreAppControl.shared.assignUser(users.first ?? assingUser(id: userID))
                    Core.makeEvent("sign in successful", type: .system)
                }
        }
        else {
            app
                .environment(CoreAppControl.shared)
                .locationToggler
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { _ in
                    
                })
        }
    }
    
    func assingUser(id: String) -> CoreUser {
        let user = CoreUser(id: id)
        modelContext.insert(user)
        return user
    }
}
