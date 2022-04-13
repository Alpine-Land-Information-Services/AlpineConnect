//
//  AppViewModel.swift
//  ConnectTest
//
//  Created by mkv on 4/12/22.
//

import Foundation
import AlpineConnect

public class AppViewModel {
    public var tracker = Tracker.shared
    
    public func notificationActions(action: String) -> Void {
        switch action {
        case "UPDATE":
            print(action)
        case "CLEARDATA":
            print(action)
        default:
            print("No action called: \(action)")
        }
    }
}
