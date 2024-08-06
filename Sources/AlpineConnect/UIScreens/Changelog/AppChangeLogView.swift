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
    
    private var appName: String {
        Tracker.appName()
    }
    
    private var version: String {
        Tracker.appVersion()
    }
    
    private var build: String {
        Tracker.appBuild()
    }
    
    private var core: CoreAppControl {
        CoreAppControl.shared
    }
    
    private var previousBuild: String? {
        core.defaults.appBuild
    }
    
    private var previousVersion: String? {
        core.defaults.appVersion
    }
    
    private var previousFullVersion: String {
        if let previousVersion, let previousBuild {
            return previousVersion + " " + previousBuild
        } else {
            return "Not Recorded"
        }
    }
    
    private var currentVersion: String {
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
                   DismissButton(eventTracker: Core.eventTracker)
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

#Preview {
    VStack {
        
    }
    .sheet(isPresented: .constant(true), content: {
        AppChangeLogView(appChangelogURL: URL(string: "https://alpinesupport-preview.azurewebsites.net/Releases/Wildlife/3_0_1/webview")!)
    })
}
