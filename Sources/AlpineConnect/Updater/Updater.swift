//
//  Updater.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import Foundation
//import PostgresClientKit

public class Updater {
    
    static let shared = Updater()
    
    public enum UpdateStatus {
        case error
        case notConnected
        case latestVersion
        case updatedAvailble
        case updateRequired
    }
    
    public var updateStatus = UpdateStatus.error
    
    private var trackingManager: TrackingManager?
    
    init() {
        Task {
           try await initializeTrackingManager()
        }
    }
    
     func initializeTrackingManager() async throws {
        trackingManager = try await TrackingManager.createInstance()
    }
    
    func checkVersion(name: String, automatic: Bool, showMessage: @escaping ((Bool, Bool) -> Void)) {
        if let currentVersion = AppInformation.getBundle(key: "CFBundleShortVersionString") {
            getAppInfo(name: name) { (info, error) in
                guard !(info?.isEmpty ?? true) else {
                    showMessage(false, false)
                    return
                }
                if let appStoreAppVersion = info?[0] {
                    if let error = error {
                        print("Error getting app version: ", error)
                        showMessage(true, false)
                        return
                    }
                    if appStoreAppVersion.compare(currentVersion, options: .numeric) != .orderedDescending {
                        print("Already on the latest app version: ", currentVersion, " (remote version: \(appStoreAppVersion))")
                        self.updateStatus = .latestVersion
                        if automatic {
                            showMessage(false, false)
                        }
                        else {
                            showMessage(true, false)
                        }
                        return
                    }
                    print("Needs update: App Store Version: \(appStoreAppVersion) > Current version: ", currentVersion)
                    if let minimumVersion = info?[1] {
                        self.updateStatus = .updateRequired
                        if minimumVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                            showMessage(true, true)
                            return
                        }
                    }
                    self.updateStatus = .updatedAvailble
                    showMessage(true, false)
                }
            }
        }
    }
    
    private func getAppInfo(name: String, completion: @escaping ([String?]?, Error?) -> Void) {
        guard let trackingManager = trackingManager else {
            completion(nil, NSError(domain: "TrackingManager is not initialized", code: 0, userInfo: nil))
            return
        }
        
        Task {
            do {
                let text = """
                    SELECT
                    version,
                    minimum_version
                    FROM public.applications
                    WHERE name = '\(name)'
                    """
                print("---------------->>>Alpine Updater Running<<<----------------")
                
                let rows = try await trackingManager.queryRows(text)
                let info = rows.map { row -> String? in
                    let randomAccessRow = row.makeRandomAccess()
                    return randomAccessRow[data: "version"].string
                }
                
                completion(info, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    

    func callUpdate(name: String, result: @escaping ((Bool, URL?) -> Void)) {
        // Ensure trackingManager is available
        guard let trackingManager = trackingManager else {
            result(false, nil)
            return
        }

        Task {
            do {
                let text = "SELECT * FROM public.redemption_codes WHERE application = '\(name)' LIMIT 1"
                let rows = try await trackingManager.queryRows(text)
                
                // Parse results
                var id: UUID?
                var path: String?
                for row in rows {
                    let randomAccessRow = row.makeRandomAccess()
                    id = UUID(uuidString: randomAccessRow[data: "id"].string ?? "")
                    path = randomAccessRow[data: "path"].string
                }
                
                if let id = id, let url = URL(string: path ?? "") {
                    try await redeemCode(id, using: trackingManager)  // Redeem code
                    result(true, url)
                } else {
                    result(false, nil)
                }
            } catch {
                result(false, nil)
                print("Error in callUpdate: \(error)")
            }
        }
    }
    
    private func redeemCode(_ id: UUID, using trackingManager: TrackingManager) async throws {
        let text = "DELETE FROM public.redemption_codes WHERE id = '\(id)'"
        _ = try await trackingManager.querySequence(text)
    }
}

