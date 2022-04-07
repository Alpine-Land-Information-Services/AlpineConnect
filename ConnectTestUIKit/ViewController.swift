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
        // Do any additional setup after loading the view.
    }


}

