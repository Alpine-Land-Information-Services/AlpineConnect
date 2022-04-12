//
//  SwiftUINotifier.swift
//  AlpineConnect
//
//  Created by mkv on 4/12/22.
//

import SwiftUI

public class SwiftUINotifier: ObservableObject {
    
    @Published var showAlert = false
    var notifications: [acNotification]?
    public var actions: ((String)->Void)?
    
    public func check(timeIntervalInSeconds: TimeInterval = 10.0) {
        Notifier.shared.startChecking(timeIntervalInSeconds: timeIntervalInSeconds, completion: { notifications in
            self.notifications = notifications
            if !notifications.isEmpty {
                DispatchQueue.main.async {
                    self.showAlert = true
                }
            }
        })
    }
    
    func defaultAction(action: String) -> Void {
        showAlert = false
    }
    
    func alert() -> Alert {
        if let notification = notifications?.first {
            notifications?.removeFirst()
            if notification.buttons.count == 1 {
                return Alert(title: Text(notification.title ?? ""),
                             message: Text(notification.body ?? ""),
                             dismissButton: .default(Text(notification.buttons[0].title),
                                                     action: { (self.actions ?? self.defaultAction)(notification.buttons[0].actionName) })
                )
            }
            if notification.buttons.count >= 2 {
                return Alert(title: Text(notification.title ?? ""),
                             message: Text(notification.body ?? ""),
                             primaryButton: .default(Text(notification.buttons[0].title),
                                                     action: { (self.actions ?? self.defaultAction)(notification.buttons[0].actionName) }),
                             secondaryButton: .default(Text(notification.buttons[1].title),
                                                     action: { (self.actions ?? self.defaultAction)(notification.buttons[1].actionName) })
                )
            }
//        if notification.buttons.isEmpty
            return Alert(title: Text(notification.title ?? ""),
                         message: Text(notification.body ?? ""),
                         dismissButton: .default(Text("Okay")))
        }
        return Alert(title: Text(""),
                     message: Text(""),
                     dismissButton: .default(Text("do nothing")))
    }
}

