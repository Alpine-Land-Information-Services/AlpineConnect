//
//  ViewController.swift
//  ConnectTestUIKit
//
//  Created by Jenya Lebid on 4/7/22.
//

import UIKit
import AlpineConnect

class ViewController: UIViewController {
    var notifier: UIKitNotifier?
    
    @IBAction func UpdateCheckAction(_ sender: Any) {
        let updater = UIKitUpdater(viewController: self)
        updater.checkForUpdate(automatic: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tracker.start()
        notifier = UIKitNotifier(viewController: self)
        notifier?.check(timeIntervalInSeconds: 20, actions: notificationActions)
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

