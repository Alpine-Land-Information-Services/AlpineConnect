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
    
    public static func start() {
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
            getData()
        }
    }
    
    static func appVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    public static func appName() -> String {
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
    
    // TODO: Add location to tracking
    //    static func deviceLocation(location: @escaping (Bool, CLLocation?) -> Void) {
    //        let locationManager = LocationManager.shared
    //        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
    //            for _ in 0...2 {
    //                print("Loop")
    //                if let coordinates = locationManager.currentCoordiante {
    //                    timer.invalidate()
    //                    print("done")
    //                    location(true, coordinates)
    //                }
    //            }
    //            location(false, nil)
    //        }
    //    }
    
    static func onlineStatus(status: @escaping (Bool, String) -> Void) {
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
                status(false, "Offline")
            }
        }
        monitor.cancel()
    }

    static func getData() {
        let coordinates: TrackingData.Coordinates? = nil
        var connectionType = "Offline"
        
        onlineStatus(status: { (online, type) in
            if online {
                //                deviceLocation(location: { (result, location) in
                //                    if result {
                //                        if let location = location {
                //                            coordinates = TrackingData.Coordinates(lat: Double(location.coordinate.latitude), long: Double(location.coordinate.longitude))
                //                        }
                //                    }
                //                })
                connectionType = type
                let data = TrackingData(deviceInfo: TrackingData.DeviceInfo(deviceID: deviceID(), deviceType: deviceType(), deviceName: deviceName(), deviceVersion: deviceVersion(), deviceLocation: coordinates), appInfo: TrackingData.AppInfo(appVersion: appVersion(), appName: appName(), connectionType: connectionType))
                
                sendData(data, handler: { result in
                    if result {
                        print("Tracking Data Exported")
                    }
                })
            }
        })
    }
    
    static func sendData(_ data: TrackingData, handler: @escaping ((Bool) -> Void)) {
        PostgresClientManager.shared.pool?.withConnection(completionHandler: { pool in
            do {
                let connection = try pool.get()
                var text = """
                INSERT INTO public.devices(id, type, name, ios_version) VALUES ($1, $2, $3, $4)
                """
                text = text + """
                ON CONFLICT (id) DO UPDATE SET
                type = EXCLUDED.type, name = EXCLUDED.name, ios_version = EXCLUDED.ios_version
                """
                
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                if let id = data.deviceInfo.deviceID {
                    let cursor = try statement.execute(parameterValues: [id.uuidString, data.deviceInfo.deviceType, data.deviceInfo.deviceName, data.deviceInfo.deviceVersion])
                    defer { cursor.close() }
                    
                    sendAppInfo(data.appInfo, deviceId: id.uuidString, handler: { result in
                        if result {
                            handler(true)
                        }
                    })
                }
            }
            catch {
                handler(false)
                print("Error exporting device tracking data: \(error)")
            }
        })
    }
    
    static func sendAppInfo(_ info: TrackingData.AppInfo, deviceId: String, handler: @escaping ((Bool) -> Void)) {
        PostgresClientManager.shared.pool?.withConnection(completionHandler: { pool in
            do {
                let connection = try pool.get()
                var text = """
                INSERT INTO public.app_info(device_id, app_name, app_version, connection_type) VALUES ($1, $2, $3, $4)
                """
                text = text + """
                ON CONFLICT (device_id, app_name) DO UPDATE SET
                app_version = EXCLUDED.app_version, connection_type = EXCLUDED.connection_type
                """
                
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [deviceId, info.appName, info.appVersion, info.connectionType])
                defer { cursor.close() }
                
                handler(true)
            }
            catch {
                handler(false)
                print("Error exporting app tracking data: \(error)")
            }
        })
    }
}
