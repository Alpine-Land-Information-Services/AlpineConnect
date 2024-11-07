//
//  Tracker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import UIKit
import Network
import CoreLocation
//import PostgresClientKit

public class Tracker {
    
    public static let shared = Tracker()
    
    private let locationManager = LocationManager.shared
    
    private var trackingManager: TrackingManager?
    private var timer: Timer?
    
    public func start(timeIntervalInSeconds: TimeInterval = 10.0) {
        Task {
            if trackingManager == nil { try await initializeTrackingManager() }
            getData()
        }
        getData()
        timer = Timer.scheduledTimer(withTimeInterval: timeIntervalInSeconds, repeats: true) { timer in
            self.getData()
        }
    }
    
    public func initializeTrackingManager() async throws {
        trackingManager = try await TrackingManager.createInstance()
    }
    
    public static func appReleaseNotesURL(preview: Bool = false, name: String? = nil) -> URL {
        let releases = preview ? URL(string: "https://alpinesupport-preview.azurewebsites.net/Releases")! : URL(string: "https://alpinesupport.azurewebsites.net/Releases")!
        var appVersion = appVersion()
        guard appVersion != "Unknown" else { return releases }
        appVersion = appVersion.replacingOccurrences(of: ".", with: "_")
        let appName = name ?? appName().components(separatedBy: " ").first ?? appName()
        
        return releases.appending(path: appName).appending(path: appVersion)
    }
    
    
    public static func appVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    public static func appBuild() -> String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    public static func appFullVersion() -> String {
        appVersion() + "." + appBuild()
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

    func sendData(_ data: TrackingData, handler: @escaping ((Bool) -> Void)) {
        guard let deviceId = data.deviceInfo.deviceID, let trackingManager = trackingManager else {
            handler(false)
            return
        }
        
        Task {
            do {
                let insertDeviceSQL = """
                    INSERT INTO public.devices(id, type, name, ios_version, last_location, user_email) VALUES ($1, $2, $3, $4, $5, $6)
                    ON CONFLICT (id) DO UPDATE SET
                    type = EXCLUDED.type, name = EXCLUDED.name, ios_version = EXCLUDED.ios_version, last_location = EXCLUDED.last_location, user_email = EXCLUDED.user_email
                """
                let insertAppInfoSQL = """
                    INSERT INTO public.app_info(device_id, app_name, app_version, connection_type) VALUES ($1, $2, $3, $4)
                    ON CONFLICT (device_id, app_name) DO UPDATE SET
                    app_version = EXCLUDED.app_version, connection_type = EXCLUDED.connection_type
                """
                
                // Execute the first query for device information
                _ = try await trackingManager.querySequence(
                    insertDeviceSQL,
                    bindValues: [
                        deviceId.uuidString,
                        data.deviceInfo.deviceType,
                        data.deviceInfo.deviceName,
                        data.deviceInfo.deviceVersion,
                        data.deviceInfo.deviceLocation?.string() ?? "0 0",
                        data.deviceInfo.email
                    ]
                )
                
                // Execute the second query for app info
                _ = try await trackingManager.querySequence(
                    insertAppInfoSQL,
                    bindValues: [
                        deviceId.uuidString,
                        data.appInfo.appName,
                        data.appInfo.appVersion,
                        data.appInfo.connectionType
                    ]
                )
                
                handler(true)
            } catch {
                handler(false)
                print("Error exporting tracking data: \(error)")
            }
        }
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
               
                let data = TrackingData(deviceInfo: TrackingData.DeviceInfo(email: Connect.user?.fullName ?? "" ,
                                                                            deviceID: Tracker.deviceID(),
                                                                            deviceType: Tracker.deviceType(),
                                                                            deviceName: Tracker.deviceName(),
                                                                            deviceVersion: Tracker.deviceVersion(),
                                                                            deviceLocation: coordinates),
                                        appInfo: TrackingData.AppInfo(appVersion: Tracker.appVersion(),
                                                                      appName: Tracker.appName(),
                                                                      connectionType: connectionType))
                self.sendData(data, handler: { result in
                    if result {
                        print("Tracking Data Exported")
                    }
                })
            }
        })
    }
}
