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
                    AlpineLoginView_V2(info: info)
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

public extension View {
    func alpineLoginSheet(info: LoginConnectionInfo, isPresented: Binding<Bool>, afterSignInAction: @escaping () async -> Void) -> some View {
        modifier(AlpineLoginSheet(info: info, isPresented: isPresented, afterSignInAction: afterSignInAction))
    }
}
