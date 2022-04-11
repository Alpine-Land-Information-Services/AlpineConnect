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
        Notifier.checkForNotification(appName: Tracker.appName(), completion: { notifications in
            for notification in notifications {
                let alert = UIAlertController(title: notification.title, message: notification.body, preferredStyle: .alert)
                for button in notification.buttons {
                    alert.addAction(UIAlertAction(title: button.title, style: .default) { (action: UIAlertAction) in
                        switch button.actionName {
                        case "ACTION1":
                            // self.action1()
                            break
                        default:
                            break
                        }
                    })
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }


}

