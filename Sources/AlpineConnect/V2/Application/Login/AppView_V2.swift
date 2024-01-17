//
//  AppView_V2.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import SwiftUI

public struct AppView_V2<App: View>: View {
    
    @ViewBuilder var app: App
    @ObservedObject var manager = ConnectManager.shared
    
    var info: LoginConnectionInfo
    
    public init(info: LoginConnectionInfo, @ViewBuilder app: () -> App) {
        self.info = info
        self.app = app()
        
        print(code: .info, try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false))
        print(code: .info, FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas")!.absoluteString)
    }
    
    public var body: some View {
        if manager.isSignedIn {
            UserAppView(userID: manager.userID) {
                app
            }
            .transition(.opacity)
            .environmentObject(manager)
        }
        else {
            AlpineLoginView_V2(info: info)
                .transition(.move(edge: .bottom))
                .environmentObject(manager)
        }
    }
}
