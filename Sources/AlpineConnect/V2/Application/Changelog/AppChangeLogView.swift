//
//  AppChangeLogView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/6/24.
//

import SwiftUI
import AlpineUI

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
    

    
    private var previousVersion: String? {
        UserDefaults.standard.string(forKey: "AC_previous_app_build")
    }
    
    var appChangelogURL: URL
    var showAtlas: Bool
    
    @State private var changesSelection = "app"
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                List {
                    HStack {
                        Text(fullVersion(build: previousVersion ?? "Version Not Recorded"))
                        Image(systemName: "arrow.forward")
                        Text(fullVersion(build: build))
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
                    UserDefaults.standard.setValue(build, forKey: "AC_previous_app_build")
                }
            }
        }
    }
    
    func fullVersion(build: String) -> String {
        version + " (\(build))"
    }
}

fileprivate struct ChangelogModifier: ViewModifier {
    
    @State private var isChangelogPresented = false
    
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
        if let lastBuild = UserDefaults.standard.string(forKey: "AC_previous_app_build") {
            if lastBuild != Tracker.appBuild() {
                isChangelogPresented.toggle()
            }
        }
        else {
            isChangelogPresented.toggle()
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
