//
//  ViewController.swift
//  ConnectTestUIKit
//
//  Created by Jenya Lebid on 4/7/22.
//

import UIKit
import AlpineConnect

//   600 - 10 min
//  3600 - 1 hour
// 86400 - 1 day

class ViewController: UIViewController {
    var notifier: UIKitNotifier?
    var tracker = Tracker.shared
    
    @IBAction func UpdateCheckAction(_ sender: Any) {
        let updater = UIKitUpdater(viewController: self)
        updater.checkForUpdate(automatic: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracker.start(timeIntervalInSeconds: 3600)
        notifier = UIKitNotifier(viewController: self)
        notifier?.check(timeIntervalInSeconds: 600, actions: notificationActions)
    }

    func notificationActions(action: String) {
        switch action {
        case "UPDATE":
            updateApp() 
        case "CLEARDATA":
            clearData()
        default:
            break
        }
    }

    // ***** EXAMPLE of ACTIONS *****
    func clearData() {
        print(#function)
    }
    
    func updateApp() {
        print(#function)
    }
}

