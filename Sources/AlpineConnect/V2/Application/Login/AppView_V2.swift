//
//  AppView_V2.swift
//  
//
//  Created by Jenya Lebid on 12/6/23.
//

import SwiftUI

public struct AppView_V2<App: View>: View {
    
    @ViewBuilder var app: App
    @ObservedObject var manager = AppManager.shared
    
    var info: LoginConnectionInfo
    
    public init(info: LoginConnectionInfo, @ViewBuilder app: () -> App) {
        self.info = info
        self.app = app()
    }
    
    public var body: some View {
        Group {
            if manager.user != nil {
                
            }
            else {
                AlpineLoginView_V2(info: info)
            }
        }
        .environmentObject(manager)
    }
}

//#Preview {
//    AppView_V2 {
//        
//    }
//}
