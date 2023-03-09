//
//  CurrentUser.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/16/23.
//

import Foundation

public class CurrentUser {
    
    public enum DBType: String, Codable {
        case production
        case sandbox
    }
    
    struct LastView: Codable {
        var viewType: String
        var viewID: UUID
    }
    
    struct UserData: Codable {
        var guid: UUID
        
        var email: String
        var name: String
        
        var lastSync: Date?
        
        var lastView: LastView?
        var dbType: DBType = .production
    }
    
    static var data: UserData!
    
    static func makeUserData(email: String, name: String, id: UUID) {
        if let data = getUserDataFromDefaults(email: email) {
            self.data = data
            return
        }
        
        data = UserData(guid: id, email: email, name: name, lastSync: nil)
        data.saveToDefaults(key: email)
    }
    
    static func getUserDataFromDefaults(email: String) -> UserData? {
        if let info = UserData.getFromDefaults(key: email) {
            if let loadedInfo = try? JSONDecoder().decode(UserData.self, from: info) {
                self.data = loadedInfo
                return loadedInfo
            }
        }
        return nil
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
    
    static var fullName: String {
        data.name
    }
    
    static var firstName: String {
        data.name.components(separatedBy: .whitespaces)[0]
    }
    
    static var lastName: String {
        data.name.components(separatedBy: .whitespaces)[1]
    }
    
    static var dbType: DBType {
        data.dbType
    }
    
    static var lastView: (String, UUID)? {
        guard let viewType = data.lastView?.viewType, let id = data.lastView?.viewID else {
            return nil
        }
        return (viewType, id)
    }
}

public extension CurrentUser {
    
    static func updateSyncDate(_ date: Date?) {
        data.lastSync = date
        data.saveToDefaults(key: data.email)
    }
    
    static func updateDBType(to type: DBType) {
        data.dbType = type
        data.saveToDefaults(key: data.email)
    }
    
    static func updateLastView(type: String?, id: UUID) {
        guard let type else { return }
        let view = LastView(viewType: type, viewID: id)
        data.lastView = view
        data.saveToDefaults(key: data.email)
    }
}
