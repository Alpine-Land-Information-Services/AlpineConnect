//
//  LaunchSettings.swift
//
//
//  Created by Vladislav on 6/6/24.
//

import SwiftUI
import AlpineUI
import AlpineCore

struct LaunchSettingsView: View {
    
    @State private var showAlert: Bool = false
    @State private var currentAlert = ConnectAlert.empty
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingBlock(image: "trash", color: .red, title: "Delete User Container", eventTracker: Core.eventTracker, action:  {
                        self.questionAlert()
                        showAlert.toggle()
                    })
                }
            }
            .connectAlert(currentAlert, isPresented: $showAlert)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Launch Settings")
            .toolbar {
                DismissButton(onEvent: { event, parameters in
                    Core.logUIEvent(event, parameters: parameters)
                })
            }
        }
        .interactiveDismissDisabled()
    }

    private func deleteContainer(targetFileName: String) {
        var filePathURL = FS.atlasGroupURL
        filePathURL.appendPathComponent("Library/Application Support")
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: filePathURL, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in fileURLs {
                if fileURL.deletingPathExtension().lastPathComponent == targetFileName {
                    print(code: .circleG, "Deleting file: \(fileURL.lastPathComponent)")
                    try FS.deleteFile(at: fileURL)
                }
            }
            print(code: .info, "Files removed from the directory \(filePathURL.path)")
        } catch {
            print(code: .red, "Error while enumerating files in directory \(filePathURL.path): \(error.localizedDescription)")
        }
    }
    
    private func questionAlert() {
        let cancel = ConnectAlertButton(label: "Cancel", role: .cancel, action: {})
        let deleteButton = ConnectAlertButton(label: "Delete", role: .destructive) {
            //TODO: -Check password
            print("Password entered: \(password)")
            self.deleteContainer(targetFileName: "Atlas User Data")
        }
        currentAlert = ConnectAlert(title: "Are you sure you want to delete the container?", message: "To confirm, please enter your password.", buttons: [deleteButton], dismissButton: cancel, textFieldBinding: $password, textFieldPlaceholder: "Password")
    }
}

#Preview {
    LaunchSettingsView()
}
