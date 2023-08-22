//
//  CurrentUser.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/16/23.
//

import Foundation

open class CurrentUser {
    
    public enum Database: String {
        case production
        case sandbox
    }

    static private var data = Dictionary.getFromDefaults(key: userKey) ?? [String: Any]()
    static private var userKey: String {
        UserManager.shared.userName
    }
    
    @available(*, unavailable) public init() {}
    
    static func makeUserData(email: String, name: String, id: UUID) {
        if let data = getUserDataFromDefaults(email: email) {
            self.data = data
            return
        }
        
        data["guid"] = id.uuidString
        data["email"] = email
        data["name"] = name
        data["isAdmin"] = isAdmin
        data["database"] = Database.production.rawValue
        
        data.saveToDefaults(key: email)
    }
    
    static func getUserDataFromDefaults(email: String) -> [String: Any]? {
        Dictionary<String, Any>.getFromDefaults(key: email)
    }
}

public extension CurrentUser {
    
    static var guid: UUID {
        UUID(uuidString: data["guid"] as! String)!
    }
    
    static var applicationUserGuid: UUID {
        UUID(uuidString: data["applicationUserGuid"] as! String)!
    }
    
    static var isAdmin: Bool {
        data["isAdmin"] as? Bool ?? false
    }
    
    static var lastSync: Date? {
        switch database {
        case .production:
            return data["lastSync"] as? Date
        case .sandbox:
            return data["lastSyncSandbox"] as? Date
        }
    }
    
    static var autoSync: Bool {
        get {
            data["autoSync"] as? Bool ?? true
        }
        set {
            data["autoSync"] = newValue
            data.saveToDefaults(key: userKey)
        }
    }
    
    
    static var syncWithCellular: Bool {
        get {
            data["syncWithCellular"] as? Bool ?? true
        }
        set {
            data["syncWithCellular"] = newValue
            data.saveToDefaults(key: userKey)
        }
    }
    
    static var syncPauseEndDate: Date? {
        get {
            data["syncPauseEndDate"] as? Date
        }
        set {
            data["syncPauseEndDate"] = newValue
            data.saveToDefaults(key: userKey)
        }
    }
    
    static var requiresSync: Bool {
        get {
            data["requiresSync"] as? Bool ?? false
        }
        set {
            data["requiresSync"] = newValue
            data.saveToDefaults(key: userKey)
        }
    }
    
    static var didBackgroundSync: Bool {
        get {
            data["didBackgroundSync"] as? Bool ?? false
        }
        set {
            data["didBackgroundSync"] = newValue
            data.saveToDefaults(key: userKey)
        }
    }
    
    static var email: String {
        data["email"] as! String
    }
    
    static var fullName: String {
        data["name"] as! String
    }
    
    static var firstName: String {
        fullName.components(separatedBy: .whitespaces)[0]
    }
    
    static var lastName: String {
        fullName.components(separatedBy: .whitespaces)[1]
    }
    
    static var defaultsGroup: Int {
        data["defaultsGroup"] as? Int ?? 0
    }
    
    static var database: Database {
        guard let db = data["database"] as? String else {
            return .production
        }
        return Database(rawValue: db)!
    }
}

public extension CurrentUser {
    
    static func updateSyncDate(_ date: Date?) {
        switch database {
        case .production:
            data["lastSync"] = date
        case .sandbox:
            data["lastSyncSandbox"] = date
        }
        if date == nil {
            data["requiresSync"] = false
        }
        data.saveToDefaults(key: userKey)
    }
    
    static func updateDatabase(to type: Database) {
        data["database"] = type.rawValue
        data.saveToDefaults(key: userKey)
    }
    
    static func setAdmin(to value: Bool) {
        data["isAdmin"] = value
    }
    
    static func setDefaultsGroup(to value: Int) {
        data["defaultsGroup"] = value
    }
    
    static func setApplicationUserGuid(to value: UUID) {
        data["applicationUserGuid"] = value.uuidString
    }
    
    static func saveDefaults() {
        data.saveToDefaults(key: userKey)
    }
}
