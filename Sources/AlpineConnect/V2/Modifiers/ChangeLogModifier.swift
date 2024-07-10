//
//  ChangeLogModifier.swift
//
//
//  Created by Vladislav on 7/10/24.
//

import SwiftUI
import AlpineCore

struct ChangeLogModifier: ViewModifier {
    
    @State private var isChangeLogPresented = false
    
    var core: CoreAppControl {
        CoreAppControl.shared
    }
    
    var appURL: URL
    var onVersionChange: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    checkIfToPresent()
                }
            }
            .sheet(isPresented: $isChangeLogPresented, content: {
                AppChangeLogView(appChangelogURL: appURL)
            })
    }
    
    func checkIfToPresent() {
        if let lastBuild = core.defaults.appBuild, core.isInitialized(sandbox: Connect.user?.isSandbox ?? false) {
            if lastBuild != Tracker.appBuild() {
                isChangeLogPresented.toggle()
                onVersionChange()
            }
        }
    }
}
