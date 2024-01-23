//
//  AppView_V2.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import SwiftUI

import PopupKit
import AlpineCore

public struct AppView_V2<App: View>: View {
    
    @ViewBuilder var app: (_ userID: String) -> App
    @ObservedObject var manager = ConnectManager.shared
    
    var info: LoginConnectionInfo
    
    public init(info: LoginConnectionInfo, @ViewBuilder app: @escaping (_ userID: String) -> App) {
        self.info = info
        self.app = app
        
        print(code: .info, try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false))
        print(code: .info, FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas")!.absoluteString)
    }
    
    public var body: some View {
        host
            .environmentObject(manager)
            .popupPresenter
    }
    
    @ViewBuilder var host: some View {
        if manager.isSignedIn {
            UserAppView(userID: manager.userID) {
                app(manager.userID)
            }
            .transition(.opacity)
            .onDisappear {
                if !manager.isSignedIn {
                    ConnectManager.signout()
                }
            }
            .uiOrientationGetter
        }
        else {
            AlpineLoginView_V2(info: info)
                .transition(.move(edge: .bottom))
        }
    }
}
