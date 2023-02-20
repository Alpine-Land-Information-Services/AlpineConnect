//
//  SyncViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import SwiftUI

class SyncViewModel: ObservableObject {
    
    let hour = Calendar.current.component(.hour, from: Date())
    
    var statusColor: Color {
        switch SyncTracker.shared.status {
        case .error:
            return .red
        case .none:
            return .green
        default:
            return Color(uiColor: .systemGray)
        }
    }
    
    var statusMessage: String {
        switch SyncTracker.shared.status {
        case .error:
            return "Sync Error Accurred"
        case .none:
            return "Process Complete"
        default:
            return "Please Wait... \(SyncTracker.shared.statusMessage)"
        }
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
    
    var greeting: String {
        greetingText + ", " + CurrentUser.firstName.capitalized
        
    }
}
