//
//  UpdaterViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI
import Network

public class UpdaterViewModel: ObservableObject {
    
    @Environment(\.openURL) var openURL
    @Published var status: Updater.UpdateStatus = .error

    let updater = Updater.shared
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "UpdaterMonitor")
    
    var appName: String

    init(appName: String) {
        self.appName = appName
    }
    
    
    func checkForUpdate(name: String, automatic: Bool, showMessage: @escaping ((Bool) -> Void)) {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.updater.checkVersion(name: name, automatic: automatic, showMessage: showMessage)
            }
            else {
                self.updater.updateStatus = .notConnected
            }
        }
    }
    
    func getUpdateStatus() {
        status = updater.updateStatus
    }
    
    func callUpdate() {
        updater.callUpdate(name: appName, result: { (result, url) in
            if result {
                if let url = url {
                    self.openURL(url)
                }
            }
        })
    }
    
    func alert() -> Alert {
        switch status {
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
                         message: Text("Connect to network and try again."),
                         dismissButton: .default(Text("Okay")))
        }
    }
    
}
