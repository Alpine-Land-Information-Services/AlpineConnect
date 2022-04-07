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
        DispatchQueue.background(background: {
            Tracker.getData()
        }, completion: {
            
        })
        // Do any additional setup after loading the view.
    }


}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}

