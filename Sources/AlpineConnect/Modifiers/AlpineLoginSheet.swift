//
//  AlpineLoginSheet.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/20/23.
//

import SwiftUI
import AlpineUI
import AlpineCore

struct AlpineLoginSheet: ViewModifier {
    
    @Binding var isPresented: Bool
    
    @ObservedObject var manager = ConnectManager.shared
    
    var info: LoginConnectionInfo?
    var afterSignInAction: () async -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    if let info {
                        AlpineLoginView(info: info)
                            .toolbar {
                                DismissButton(onEvent: { event, parameters in
                                    Core.logUIEvent(.dismissButton)
                                })
                            }
                    }
                    else {
                        ContentUnavailableView("No Connection Info", systemImage: "xmark", description: Text("Login sheet requires connectionInfo to be present."))
                    }
                }
                .environmentObject(manager)
            }
            .onChange(of: manager.isSignedIn) { _, signedIn in
                if signedIn {
                    isPresented = false
                    Task {
                        await afterSignInAction()
                    }
                }
            }
    }
}
