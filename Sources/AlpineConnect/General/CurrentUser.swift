//
//  CurrentUser.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/16/23.
//

import Foundation

public class CurrentUser {
    
    struct UserData: Codable {
        var guid: UUID
        var email: String
        var name: String
        
        var lastSync: Date?
        var syncStart: Date?
    }
    
    static var data: UserData!
    
    static func makeUserData(email: String, name: String, id: UUID) {
        if let data = getUserDataFromDefaults(email: email) {
            self.data = data
            return
        }
        
        data = UserData(guid: id, email: email, name: name, lastSync: nil, syncStart: nil)
        saveUserDataToDefaults(data)
    }
    
    static func getUserDataFromDefaults(email: String) -> UserData? {
        if let info = UserDefaults.standard.object(forKey: email) as? Data {
            if let loadedInfo = try? JSONDecoder().decode(UserData.self, from: info) {
                self.data = loadedInfo
                return loadedInfo
            }
        }
        return nil
    }
    
    static func saveUserDataToDefaults(_ data: UserData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: data.email)
        }
    }
}

public extension CurrentUser {
    
    static var guid: UUID {
        data.guid
    }
    
    static var lastSync: Date? {
        data.lastSync
    }
    
    static var email: String {
        data.email
    }
    
    static var syncStartDate: Date? {
        data.syncStart
    }
    
    static var firstName: String {
        data.name.components(separatedBy: .whitespaces)[0]
    }
    
    static var lastName: String {
        data.name.components(separatedBy: .whitespaces)[1]
    }
    
    static func updateSyncDate(_ date: Date?) {
        data.lastSync = date
        saveUserDataToDefaults(data)
    }
    
    static func changeStartSyncDate(_ date: Date) {
        data.syncStart = date
        saveUserDataToDefaults(data)
    }
}
