//
//  Updater.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import Foundation
import PostgresClientKit

public class Updater {
    
    static let shared = Updater()
    
    public enum UpdateStatus {
        case error
        case notConnected
        case latestVersion
        case updatedRequired
    }
    
    public var updateStatus = UpdateStatus.error
    
    func checkVersion(name: String, automatic: Bool, showMessage: @escaping ((Bool) -> Void)) {
        if let currentVersion = self.getBundle(key: "CFBundleShortVersionString") {
            getAppInfo(name: name) { (info, error) in
                if let appStoreAppVersion = info {
                    if let error = error {
                        print("Error getting app version: ", error)
                        showMessage(true)
                    } else if appStoreAppVersion <= currentVersion {
                        print("Already on the latest app version: ", currentVersion)
                        self.updateStatus = .latestVersion
                        if automatic {
                            showMessage(false)
                        }
                        else {
                            showMessage(true)
                        }
                    } else {
                        print("Needs update: App Store Version: \(appStoreAppVersion) > Current version: ", currentVersion)
                        self.updateStatus = .updatedRequired
                        showMessage(true)
                    }
                }
            }
        }
    }
    
    private func getAppInfo(name: String, completion: @escaping (String?, Error?) -> Void) {
        PostgresClientManager.shared.pool?.withConnection { con_from_pool in
            do {
                let connection = try con_from_pool.get()
                defer { connection.close() }
                let text = """
                        SELECT
                        "version"
                        FROM public."app_version"
                        WHERE "name" = '\(name)'
                        """
                print("---------------->>>Alpine Updater Running<<<----------------")
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                var info: String?
                let cursor = try statement.execute()
                defer { cursor.close() }
                do {
                    for row in cursor {
                        let columns = try row.get().columns
                        info = try columns[0].string()
                    }
                } catch {
                    completion(nil, error)
                }
                completion(info, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func callUpdate(name: String, result: @escaping ((Bool, URL?) -> Void)) {
        PostgresClientManager.shared.pool?.withConnection { con_from_pool in
            do {
                let connection = try con_from_pool.get()
                defer { connection.close() }
                let text = "SELECT * FROM public.redemption_codes WHERE application = '\(name)' LIMIT 1"
                let statement = try connection.prepareStatement(text: text)
                let cursor = try statement.execute()
                
                var id: UUID!
                var path: String!
                
                for row in cursor {
                    let columns = try row.get().columns
                    id = try UUID(uuidString: columns[0].string())
                    path = try columns[3].string()
                }
                cursor.close()
                statement.close()
                self.reedemCode(id, connection)
                if let url = URL(string: path) {
                    result(true, url)
                }
            }
            catch {
                result(false, nil)
                fatalError("\(error)")
            }
        }
    }
    
    private func reedemCode(_ id: UUID, _ connection: Connection) {
        do {
            let text = "DELETE FROM public.redemption_codes WHERE id = '\(id)'"
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            let cursor = try statement.execute()
            cursor.close()
        }
        catch {
            fatalError("\(error)")
        }
    }
    
    private func getBundle(key: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: key) as? String else {
            fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
}
