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

    public struct AppInfo {
        var appVersion: String
        var appName: String
        var connectionType: String
    }
    
    public struct DeviceInfo {
        var deviceID: UUID?
        var deviceType: String
        var deviceName: String
        var deviceVersion: String
        var deviceLocation: Coordinates?
    }
    
    var deviceInfo: DeviceInfo
    var appInfo: AppInfo
}
