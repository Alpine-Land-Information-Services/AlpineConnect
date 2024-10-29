//
//  AppView_V2.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import SwiftUI
import SwiftData
import TipKit
import AlpineCore

public struct AppView<App: View>: View {
    
    @ViewBuilder var app: (_ userID: String) -> App
    @ObservedObject var manager = ConnectManager.shared
    
    var info: LoginConnectionInfo
    
    public init(info: LoginConnectionInfo, @ViewBuilder app: @escaping (_ userID: String) -> App) {
        self.info = info
        self.app = app

        print(code: .info, try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false))
        print(code: .info, FS.atlasGroupURL.absoluteString)
        
//        try? Tips.resetDatastore()
        try? Tips.configure([.datastoreLocation(.applicationDefault), .displayFrequency(.immediate)])
        
    }
    
    public var body: some View {
        host
            .popupPresenter
            .uiOrientationGetter
            .environmentObject(manager)
            .modelContainer(CoreAppControl.shared.modelContainer)
    }
    
    @ViewBuilder var host: some View {
        if manager.isSignedIn {
            UserAppView(userID: manager.userID) {
                app(manager.userID)
                    .environmentObject(LocationManager.shared)
            }
            .transition(.opacity)
            .onDisappear {
                if !manager.isSignedIn {
                    ConnectManager.signingOutReset()
                }
            }
        }
        else {
            AlpineLoginView(info: info)
                .transition(.move(edge: .bottom))
        }
    }
}
