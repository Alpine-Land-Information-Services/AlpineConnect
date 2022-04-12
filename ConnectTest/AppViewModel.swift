//
//  AppViewModel.swift
//  ConnectTest
//
//  Created by mkv on 4/12/22.
//

import Foundation

public class AppViewModel {
    
    public func notificationActions(action: String) -> Void {
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
