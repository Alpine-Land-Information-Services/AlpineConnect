//
//  UIKitUpdater.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import UIKit
import Network

public class UIKitUpdater: NSObject {
    
    let updater = Updater.shared
    var appName: String
    var viewController: UIViewController
    
    public init(appName: String, viewController: UIViewController) {
        self.appName = appName
        self.viewController = viewController
    }
    
    public func checkForUpdate(automatic: Bool) {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "UpdaterMonitor"))
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.updater.checkVersion(name: self.appName, automatic: automatic, showMessage: { result in
                    if result {
                        self.presentAlert(automatic: automatic)
                    }
                })
            }
            else {
                self.updater.updateStatus = .notConnected
                self.presentAlert(automatic: automatic)
            }
        }
        monitor.cancel()
    }
    
    func presentAlert(automatic: Bool) {
        DispatchQueue.main.async {
            let vc: UIViewController? = self.viewController
            vc?.present(self.alert(), animated: true, completion: nil)
        }
    }
    
    func callUpdate() {
        updater.callUpdate(name: appName, result: { (result, url) in
            if result {
                if let url = url {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        })
    }
    
    func alert() -> UIAlertController {
        switch updater.updateStatus {
        case .updatedRequired:
            let alert = UIAlertController(title: "New Version Avalible", message: "Update to the latest version for best functionality.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Update", style: .default) { (action:UIAlertAction) in
                self.callUpdate()
            })
            alert.addAction(UIAlertAction(title: "Not Now", style: .destructive))
            return alert
        case .latestVersion:
            let alert = UIAlertController(title: "No Updates Avalible", message: "You are already on the latest version.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            return alert
        case .error:
            let alert = UIAlertController(title: "Something Went Wrong", message: "Contact developer for support.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            return alert
        case .notConnected:
            let alert = UIAlertController(title: "No Connection", message: "Unable to check for update, connect to network and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            return alert
        }
    }
}
