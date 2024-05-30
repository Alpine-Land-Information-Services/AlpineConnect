//
//  AppChangeLogView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/6/24.
//

import SwiftUI
import AlpineUI
import AlpineCore

struct AppChangeLogView: View {
    
    var appName: String {
        Tracker.appName()
    }
    
    var version: String {
        Tracker.appVersion()
    }
    
    var build: String {
        Tracker.appBuild()
    }
    
    var core: CoreAppControl {
        CoreAppControl.shared
    }
    
    private var previousBuild: String? {
        core.defaults.appBuild
    }
    
    private var previousVersion: String? {
        core.defaults.appVersion
    }
    
    var previousFullVersion: String {
        if let previousVersion, let previousBuild {
            return previousVersion + " " + previousBuild
        }
        else {
            return "Not Recorded"
        }
    }
    
    var currentVersion: String {
        version + " " + build
    }
        
    var appChangelogURL: URL
        
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack(spacing: 0) {
                    HStack {
                        Text(previousFullVersion)
                        Image(systemName: "arrow.forward")
                        Text(currentVersion)
                    }
                    .frame(maxWidth: .infinity)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                    .background()
                    .backgroundStyle(.ultraThickMaterial)
                    Divider()
                    WebView(url: .constant(appChangelogURL))
                }
                .navigationTitle(appName + " Has Been Updated")
                .toolbar {
                    DismissButton()
                }
                .onDisappear {
                    core.defaults.appBuild = build
                    core.defaults.appVersion = version
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

fileprivate struct ChangelogModifier: ViewModifier {
    
    @State private var isChangelogPresented = false
    
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
            .sheet(isPresented: $isChangelogPresented, content: {
                AppChangeLogView(appChangelogURL: appURL)
            })
    }
    
    func checkIfToPresent() {
        if let lastBuild = core.defaults.appBuild, core.isInitialized(sandbox: Connect.user?.isSandbox ?? false) {
            if lastBuild != Tracker.appBuild() {
                isChangelogPresented.toggle()
                onVersionChange()
            }
        }
    }
}

public extension View {
    
    func changelog(appURL: URL, onVersionChange: @escaping () -> Void) -> some View {
        modifier(ChangelogModifier(appURL: appURL, onVersionChange: onVersionChange))
    }
}

#Preview {
    VStack {
        
    }
    .sheet(isPresented: .constant(true), content: {
        AppChangeLogView(appChangelogURL: URL(string: "https://alpinesupport-preview.azurewebsites.net/Releases/Wildlife/3_0_1/webview")!)
    })
}
