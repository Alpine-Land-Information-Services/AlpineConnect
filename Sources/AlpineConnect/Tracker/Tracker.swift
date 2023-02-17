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
    
    public static let shared = Tracker()
    var timer: Timer?
    let locationManager = Location.shared
    
    public func start(timeIntervalInSeconds: TimeInterval = 10.0) {
        getData()
        timer = Timer.scheduledTimer(withTimeInterval: timeIntervalInSeconds, repeats: true) { timer in
            self.getData()
        }
    }
    
    public static func appVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    public static func appBuild() -> String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    public static func appName() -> String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Unknown"
    }
    
    public static func deviceID() -> UUID? {
        UIDevice.current.identifierForVendor
    }
    
    public static func deviceType() -> String {
        UIDevice.current.type.rawValue
    }
    
    public static func deviceName() -> String {
        UIDevice.current.name
    }
    
    public static func deviceVersion() -> String {
        UIDevice.current.systemVersion
    }
    
//    static func deviceLocation(location: @escaping (Bool, CLLocation?) -> Void) {
//        if let coordinates = shared.locationManager.lastLocation {
//            location(true, coordinates)
//        }
//        location(false, nil)
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

    func getData() {
        var coordinates: TrackingData.Coordinates? = nil
        var connectionType = "Offline"
        
        Tracker.onlineStatus(status: { (online, type) in
            if online {
                if let location = self.locationManager.lastLocation {
                    coordinates = TrackingData.Coordinates(lat: Double(location.coordinate.latitude), long: Double(location.coordinate.longitude))
                }
                
                connectionType = type
                let data = TrackingData(deviceInfo: TrackingData.DeviceInfo(email: UserManager.shared.userName, deviceID: Tracker.deviceID(),
                                                                            deviceType: Tracker.deviceType(),
                                                                            deviceName: Tracker.deviceName(),
                                                                            deviceVersion: Tracker.deviceVersion(),
                                                                            deviceLocation: coordinates),
                                        appInfo: TrackingData.AppInfo(appVersion: Tracker.appVersion(),
                                                                      appName: Tracker.appName(),
                                                                      connectionType: connectionType))
                Tracker.sendData(data, handler: { result in
                    if result {
                        print("Tracking Data Exported")
                    }
                })
            }
        })
    }
    
    static func sendData(_ data: TrackingData, handler: @escaping ((Bool) -> Void)) {
        guard let deviceId = data.deviceInfo.deviceID else { return }
        TrackingManager.shared.pool?.withConnection(completionHandler: { pool in
            do {
                print(#function, data)
                let connection = try pool.get()
                var text = """
                    INSERT INTO public.devices(id, type, name, ios_version, last_location, user_email) VALUES ($1, $2, $3, $4, $5, $6)
                    ON CONFLICT (id) DO UPDATE SET
                    type = EXCLUDED.type, name = EXCLUDED.name, ios_version = EXCLUDED.ios_version, last_location = EXCLUDED.last_location, user_email = EXCLUDED.user_email
                """
                var statement = try connection.prepareStatement(text: text)
                var cursor = try statement.execute(parameterValues: [deviceId.uuidString, data.deviceInfo.deviceType, data.deviceInfo.deviceName, data.deviceInfo.deviceVersion, data.deviceInfo.deviceLocation?.string() ?? "0 0", data.deviceInfo.email])
                cursor.close()
                statement.close()
                
                text = """
                    INSERT INTO public.app_info(device_id, app_name, app_version, connection_type) VALUES ($1, $2, $3, $4)
                    ON CONFLICT (device_id, app_name) DO UPDATE SET
                    app_version = EXCLUDED.app_version, connection_type = EXCLUDED.connection_type
                """
                statement = try connection.prepareStatement(text: text)
                cursor = try statement.execute(parameterValues: [deviceId.uuidString, data.appInfo.appName, data.appInfo.appVersion, data.appInfo.connectionType])
                cursor.close()
                statement.close()
                handler(true)
            }
            catch {
                handler(false)
                print("Error exporting tracking data: \(error)")
            }
        })
    }
}
