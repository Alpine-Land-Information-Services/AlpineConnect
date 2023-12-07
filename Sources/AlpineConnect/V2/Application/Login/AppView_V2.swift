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
    }
    
    public var body: some View {
        if manager.isSignedIn {
            app
                .transition(.opacity)
        }
        else {
            AlpineLoginView_V2(info: info)
                .transition(.move(edge: .bottom))
                .environmentObject(manager)
//                    .transition(.asymmetric(insertion: .slide, removal: .move(edge: .bottom)))
        }
    }
}

//#Preview {
//    AppView_V2 {
//        
//    }
//}
