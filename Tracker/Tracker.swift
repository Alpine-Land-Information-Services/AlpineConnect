//
//  Tracker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import UIKit
import Network
import CoreLocation
import PostgresClientKit

public class Tracker {
    
    static func appVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    static func appName() -> String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Unknown"
    }
    
    static func deviceID() -> UUID? {
        return UIDevice.current.identifierForVendor
    }
    
    static func deviceType() -> String {
        return UIDevice.current.type.rawValue
    }
    
    static func deviceName() -> String {
        return UIDevice.current.name
    }
    
    static func deviceVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    static func deviceLocation(location: @escaping (Bool, CLLocationCoordinate2D?) -> Void) {
        let locationManager = LocationManager.shared
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            for _ in 0...2 {
                print("Loop")
                if let coordinates = locationManager.currentCoordiante {
                    timer.invalidate()
                    print("done")
                    location(true, coordinates)
                }
            }
            location(false, nil)
        }
    }
    
    static func onlineStatus(status: @escaping (Bool, String?) -> Void) {
        var connectionType = "WIFI"
        
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "ConnectionReporter"))
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if path.isExpensive {
                    connectionType = "Cellular"
                }
                status(true, connectionType)
            }
            else {
                status(true, nil)
            }
        }
        monitor.cancel()
    }
    
    static func lastOnline() -> Date {
        return Date()
    }
    
    public static func getData() {
        var coordinates: TrackingData.Coordinates? = nil
        var status = TrackingData.Status(connected: false, connectionType: "Offline")

        onlineStatus(status: { (online, connectionType) in
            if online {
                deviceLocation(location: { (result, location) in
                    if result {
                        if let location = location {
                            coordinates = TrackingData.Coordinates(lat: Double(location.latitude), long: Double(location.longitude))
                        }
                    }
                })
                status = TrackingData.Status(connected: online, connectionType: connectionType!)
                let data = TrackingData(appVersion: appVersion(), appName: appName(), deviceID: deviceID(), deviceType: deviceType(), deviceName: deviceName(), deviceVersion: deviceVersion(), deviceLocation: coordinates, onlineStatus: status, lastOnline: lastOnline())
                
                sendData(data)
            }
        })
    }
    
    static func sendData(_ data: TrackingData) {
       print(data)
    }
}
