//
//  UIKitNotifier.swift
//  AlpineConnect
//
//  Created by mkv on 4/12/22.
//

import Foundation
import UIKit

public class UIKitNotifier: NSObject {

    var viewController: UIViewController
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func check(timeIntervalInSeconds: TimeInterval = 10.0, actions: @escaping (String)->Void) {
        Notifier.shared.startChecking(timeIntervalInSeconds: timeIntervalInSeconds, completion: { notifications in
            for notification in notifications {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: notification.title, message: notification.body, preferredStyle: .alert)
                    if notification.buttons.isEmpty {
                        alert.addAction(UIAlertAction(title: "Okay", style: .default) { (action: UIAlertAction) in
                            alert.dismiss(animated: true, completion: nil)
                        })
                    }
                    for button in notification.buttons {
                        alert.addAction(UIAlertAction(title: button.title, style: .default) { (action: UIAlertAction) in
                            actions(button.actionName)
                        })
                    }
                    
                    var vc: UIViewController? = self.viewController
                    if vc?.viewIfLoaded?.window == nil {
                        vc = UIApplication.shared.windows.last?.rootViewController?.presentedViewController
                        if vc == nil {
                            vc = UIApplication.shared.windows.last?.rootViewController
                        }
                    }
                    vc?.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
}
