//
//  SwiftUINotifier.swift
//  AlpineConnect
//
//  Created by mkv on 4/12/22.
//

import SwiftUI

public class SwiftUINotifier: ObservableObject {
    
    @Published public var showAlert = false
    
    public var notifications = [acNotification]()

    public var actions: ((String)->Void)?
    
    public init(actions: ((String) -> Void)?) {
        self.actions = actions
    }
    
    public func check(timeIntervalInSeconds: TimeInterval) {
        Notifier.shared.startChecking(timeIntervalInSeconds: timeIntervalInSeconds, completion: { notifications in
            self.notifications.append(contentsOf: notifications)
            if !notifications.isEmpty {
                DispatchQueue.main.async {
                    self.showAlert = true
                }
            }
        })
    }
    
    func defaultAction(action: String) -> Void {
        print("Actions are not set")
        showAlert = false
    }
    
    private func _actions(_ actionName: String) -> Void {
        (actions ?? defaultAction)(actionName)
        if !(notifications.isEmpty) {
            DispatchQueue.main.async {
                self.showAlert = true
            }
        }
    }
    
    func removeNotification() {
        notifications.removeFirst()
    }
    
    public func alert() -> Alert {
        if let notification = notifications.first {
//            if notification.buttons.count == 1 {
//                return Alert(title: Text(notification.title ?? ""),
//                             message: Text(notification.body ?? ""),
//                             dismissButton: .default(Text(notification.buttons[0].title),
//                                                     action: { self._actions(notification.buttons[0].actionName) })
//                )
//            }
//            if notification.buttons.count >= 2 {
//                return Alert(title: Text(notification.title ?? ""),
//                             message: Text(notification.body ?? ""),
//                             primaryButton: .default(Text(notification.buttons[0].title),
//                                                     action: { self._actions(notification.buttons[0].actionName) }),
//                             secondaryButton: .default(Text(notification.buttons[1].title),
//                                                       action: { self._actions(notification.buttons[1].actionName) })
//                )
//            }
//        if notification.buttons.isEmpty
            return Alert(title: Text(notification.title ?? ""),
                         message: Text(notification.body ?? ""),
                         dismissButton: .default(Text(notification.buttons[0].title),
                                                 action: removeNotification))
        }
        return Alert(title: Text(""),
                     message: Text(""),
                     dismissButton: .default(Text("do nothing")))
    }
}

