//
//  AlpineLoginSheet.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/20/23.
//

import SwiftUI
import AlpineUI

struct AlpineLoginSheet: ViewModifier {
    
    var info: LoginConnectionInfo
    @Binding var isPresented: Bool
    
    var afterSignInAction: () async -> Void
    
    @ObservedObject var manager = ConnectManager.shared

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    AlpineLoginView(info: info)
                        .toolbar {
                            DismissButton()
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
