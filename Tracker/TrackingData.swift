//
//  TrackingData.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import Foundation

public struct TrackingData {
    
    public struct Coordinates {
        var lat: Double
        var long: Double
    }
    
    public struct Status {
        var connected: Bool
        var connectionType: String
    }
    
    var appVersion: String
    var appName: String
    var deviceID: UUID?
    var deviceType: String
    var deviceName: String
    var deviceVersion: String
    var deviceLocation: Coordinates?
    var onlineStatus: Status
    var lastOnline: Date
}
