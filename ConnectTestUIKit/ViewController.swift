//
//  ViewController.swift
//  ConnectTestUIKit
//
//  Created by Jenya Lebid on 4/7/22.
//

import UIKit
import AlpineConnect

class ViewController: UIViewController {
    
    @IBAction func UpdateCheckAction(_ sender: Any) {
        let updater = UIKitUpdater(appName: "WBIS", viewController: self)
        updater.checkForUpdate(automatic: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tracker.start()
        Notifier.checkForNotification(completion: { notifications in
            for notification in notifications {
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: notification.title, message: notification.body, preferredStyle: .alert)
                    if notification.buttons.isEmpty {
                        alert.addAction(UIAlertAction(title: "Okay", style: .default) { (action: UIAlertAction) in
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                    for button in notification.buttons {
                        alert.addAction(UIAlertAction(title: button.title, style: .default) { (action: UIAlertAction) in
                            self.notificationActions(action: button.actionName)
                        })
                    }
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }

    func notificationActions(action: String) {
        switch action {
        case "UPDATE":
            print(action)
        case "CLEARDATA":
            print(action)
        default:
            break
        }
    }

}

