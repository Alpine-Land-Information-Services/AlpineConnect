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
    
    @Published public var showAlert = false

    public let updater = Updater.shared
    
    public init() {
        
    }
    
    public func checkForUpdate(automatic: Bool) {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "UpdaterMonitor"))
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.updater.checkVersion(name: Tracker.appName(), automatic: automatic, showMessage: { result, updateRequired in
                    if result || updateRequired {
                        self.alertToggle(show: true)
                    }
                })
            }
            else {
                self.updater.updateStatus = .notConnected
                if automatic {
                    self.alertToggle(show: false)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("UpdateStatus"), object: nil)
                    }
                }
                else {
                    self.alertToggle(show: true)
                }
            }
        }
        monitor.cancel()
    }
    
    
    func alertToggle(show: Bool) {
        DispatchQueue.main.async {
            self.showAlert = show
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
    
    public func alert(dismissAction: @escaping () -> ()) -> Alert {
        switch updater.updateStatus {
        case .updateRequired:
            return Alert(title: Text("Update Required"),
                         message: Text("Your application version is no longer supported. \n\nPlease update to continue."),
                         dismissButton: .default(Text("Update Now"), action: callUpdate))
        case .updatedAvailble:
            return Alert(title: Text("New Version Avalible"),
                         message: Text("Update to the latest version for best functionality."),
                         primaryButton: .default(Text("Update"), action: callUpdate),
                         secondaryButton: .destructive(Text("Not Now"), action: dismissAction))
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
