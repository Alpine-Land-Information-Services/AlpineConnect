//
//  SwiftUIUpdater.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI
import Network

public class SwiftUIUpdater: ObservableObject {
    
    @Environment(\.openURL) var openURL
    @Published var showAlert = false

    let updater = Updater.shared
    
    public func checkForUpdate(automatic: Bool) {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "UpdaterMonitor"))
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.updater.checkVersion(name: Tracker.appName(), automatic: automatic, showMessage: { result in
                    if result {
                        self.alertToggle(automatic: automatic)
                    }
                })
            }
            else {
                self.updater.updateStatus = .notConnected
                self.alertToggle(automatic: automatic)
            }
        }
        monitor.cancel()
    }
    
    
    func alertToggle(automatic: Bool) {
        DispatchQueue.main.async {
            if !automatic {
                self.showAlert = true
            }
            else {
                self.showAlert = false
            }
        }
    }
    
    func callUpdate() {
        updater.callUpdate(name: Tracker.appName(), result: { (result, url) in
            if result {
                if let url = url {
                    self.openURL(url)
                }
            }
        })
    }
    
    func alert() -> Alert {
        switch updater.updateStatus {
        case .updatedRequired:
            return Alert(title: Text("New Version Avalible"),
                         message: Text("Update to the latest version for best functionality."),
                         primaryButton: .default(Text("Update"), action: callUpdate),
                         secondaryButton: .destructive(Text("Not Now")))
        case .latestVersion:
            return Alert(title: Text("No Updates Avalible"),
                         message: Text("You are already on the latest version."),
                         dismissButton: .default(Text("Okay")))
        case .error:
            return Alert(title: Text("Something Went Wrong"),
                         message: Text("Contact developer for support."),
                         dismissButton: .default(Text("Okay")))
        case .notConnected:
            return Alert(title: Text("No Connection"),
                         message: Text("Unable to check for update, connect to network and try again."),
                         dismissButton: .default(Text("Okay")))
        }
    }
}
