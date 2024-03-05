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
    var showAtlas: Bool
    
    @State private var changesSelection = "app"
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                List {
                    HStack {
                        Text(previousFullVersion)
                        Image(systemName: "arrow.forward")
                        Text(currentVersion)
                    }
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                    .padding()

                    Section {
                        ListPickerBlock(style: .segmented, value: $changesSelection) {
                            Text(appName + " Changelog")
                                .tag("app")
                            Text("Atlas Changelog")
                                .tag("atlas")
                        }
                    }
                    
                    Section {
                        if changesSelection == "app" {
                            WebView(url: .constant(appChangelogURL))
                                .frame(height: geometry.size.width > geometry.size.height ? 340 : 640)
                        }
                        else {
                            WebView(url: .constant(URL(string: "https://raw.githubusercontent.com/Alpine-Land-Information-Services/iOS-Docs/main/atlas-changelog.md")!))
                                .frame(height: geometry.size.width > geometry.size.height ? 340 : 640)
                        }
                    }
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
    }
}

fileprivate struct ChangelogModifier: ViewModifier {
    
    @State private var isChangelogPresented = false
    
    var core: CoreAppControl {
        CoreAppControl.shared
    }
    
    var appURL: String
    var includeAtlas: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    checkIfToPresent()
                }
            }
            .sheet(isPresented: $isChangelogPresented, content: {
                AppChangeLogView(appChangelogURL: URL(string: appURL)!, showAtlas: includeAtlas)
            })
    }
    
    func checkIfToPresent() {
        if let lastBuild = core.defaults.appBuild {
            if lastBuild != Tracker.appBuild() {
                isChangelogPresented.toggle()
            }
        }
        else {
            core.defaults.appBuild = Tracker.appBuild()
            core.defaults.appVersion = Tracker.appVersion()
        }
    }
}

public extension View {
    
    func changelog(appURL: String, includeAtlas: Bool) -> some View {
        modifier(ChangelogModifier(appURL: appURL, includeAtlas: includeAtlas))
    }
}

//#Preview {
//    VStack {
//        
//    }
//    .sheet(isPresented: .constant(true), content: {
//        AppChangeLogView()
//    })
//}
