//
//  SyncViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import Foundation

class SyncViewModel: ObservableObject {
    
    let hour = Calendar.current.component(.hour, from: Date())
    
    var name: String {
        UserManager.shared.userInfo.firstName
    }
    
    var totalToSync: Int {
        SyncTracker.shared.totalReccordsToSync
    }
    
    var greetingText: String {
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<22:
            return "Good Evening"
        default:
            return "Great Night"
        }
    }
    
    var image: String {
        switch hour {
        case 5..<12:
            return "morning"
        case 12..<17:
            return "noon"
        case 17..<22:
            return "evening"
        default:
            return "night"
        }
    }
    
    var status: String {
        switch SyncTracker.shared.status {
        case .importing:
            return "Importing Records"
        case .actions:
            return "Making Geometry"
        default:
            return "Complete"
        }
    }
    
    var greeting: String {
        greetingText + ", " + name.capitalized
    }
}
