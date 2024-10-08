//
//  ConnectUser.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/18/24.
//

import Foundation
import Observation

@Observable
public class ConnectUser {
    
    private var data: [String: Any]
    
    public var email: String
    public var jwtToken: String?
    
    /// Init for WBIS login type.
    internal init(for serverUser: ServerUserResponse) { // user is created on login and should not be initialized elsewhere.
        data = Dictionary.getFromDefaults(key: serverUser.email) ?? Self.makeUser(for: serverUser)
        self.email = serverUser.email
        
        data["email"] = serverUser.email
        data["first_name"] = serverUser.firstName
        data["last_name"] = serverUser.lastName
        data["is_admin"] = serverUser.isAdmin
    }
    
    /// Init for Ursus login type.
    public init(email: String) {
        self.email = email
        let data = Dictionary.getFromDefaults(key: email) ?? Self.makeUser(email: email)
        self.data = data
    }
    
    /// Init for FMS login type.
    public init(for tokenData: JWTData, token: String) {
        data = Dictionary.getFromDefaults(key: tokenData.login) ?? Self.makeUser(for: tokenData)
        self.email = tokenData.login
        self.jwtToken = token
    }
    
    internal init?(for email: String) {
        self.email = email
        guard let data = Dictionary<String, Any>.getFromDefaults(key: email) else {
            return nil
        }
        self.data = data
    }
    
    public func save() {
        data.saveToDefaults(key: email)
    }
    
    public func setValue(_ value: Any?, for key: String, doSave: Bool = true) {
        data[key] = value
        doSave ? save() : nil
    }
    
    public func value(for key: String) -> Any? {
        data[key]
    }
}

public extension ConnectUser { //MARK: Ursus sync tokens.
    
    var accessToken: String? {
        get {
            value(for: "access_token") as? String
        }
        set {
            setValue(newValue, for: "access_token")
        }
    }
    
    var refreshToken: String? {
        get {
            value(for: "refresh_token") as? String
        }
        set {
            setValue(newValue, for: "refresh_token")
        }
    }
    
    var lastAccessTokenRefresh: Date? {
        get {
            value(for: "last_access_token_refresh") as? Date
        }
        set {
            setValue(newValue, for: "last_access_token_refresh")
        }
    }
}

public extension ConnectUser {
    
    var isSandbox: Bool {
        databaseType == .sandbox
    }
    
    var isAdmin: Bool {
        data["is_admin"] as? Bool ?? false
    }
    
    var isAppAdmin: Bool {
        data["is_application_admin"] as? Bool ?? false
    }
    
    var guid: UUID {
        let id = data["guid"] as? String ?? UUID().uuidString
        return UUID(uuidString: id)!
    }
    
    var firstName: String {
        data["first_name"] as? String ?? "No First Name"
    }
    
    var lastName: String {
        data["last_name"] as? String ?? "No Last Name"
    }
    
    var fullName: String {
        let first = data["first_name"] as? String ?? "No First Name"
        let last = data["last_name"] as? String ?? "No Last Name"
        
        return first + " " + last
    }
    
    var lastSync: Date? {
        get {
            switch databaseType {
            case .production:
                return value(for: "last_sync") as? Date
            case .sandbox:
                return value(for: "last_sync_sandbox") as? Date
            }
        }
        set {
            switch databaseType {
            case .production:
                setValue(newValue, for: "last_sync", doSave: false)
            case .sandbox:
                setValue(newValue, for: "last_sync_sandbox", doSave: false)
            }
            if newValue == nil {
                setValue(false, for: "requires_sync", doSave: false)
            }
            save()
        }
    }
    
    var databaseType: DatabaseType {
        get {
            let db = value(for: "database") as? String ?? DatabaseType.production.rawValue // CHANGED TO SANDBOX FOR TESTING
            return DatabaseType(rawValue: db) ?? .production
        }
        set {
            setValue(newValue.rawValue, for: "database")
        }
    }
    
    var syncTimeout: Int {
        get {
            value(for: "sync_timeout") as? Int ?? 60
        }
        set {
            setValue(newValue, for: "sync_timeout")
        }
    }
    
    var requiresSync: Bool {
        get {
            value(for: "requires_sync") as? Bool ?? false
        }
        set {
            setValue(newValue, for: "requires_sync")
        }
    }
    
    var notExportedCount: Int {
        get {
            value(for: "not_exported_count") as? Int ?? 0
        }
        set {
            setValue(newValue, for: "not_exported_count")
        }
    }
    
    var toolbarButtonMigrationVersion: Int  {
        get {
            value(for: "toolbar_button_migration_version") as? Int ?? 0
        }
        set {
            setValue(newValue, for: "toolbar_button_migration_version")
        }
    }
}

private extension ConnectUser {
    
    static func makeUser(email: String) -> [String: Any] {
        var data = [String: Any]()
        data["email"] = email
        
        data.saveToDefaults(key: email)
        return data
    }
    
    static func makeUser(for serverUser: ServerUserResponse) -> [String: Any] {
        var data = [String: Any]()
        data["email"] = serverUser.email
        data["first_name"] = serverUser.firstName
        data["last_name"] = serverUser.lastName
        data["is_admin"] = serverUser.isAdmin
        
        data.saveToDefaults(key: serverUser.email)
        return data
    }
    
    static func makeUser(for jwtToken: JWTData) -> [String: Any] {
        var data = [String: Any]()
        data["email"] = jwtToken.login
        data["first_name"] = jwtToken.firstName
        data["last_name"] = jwtToken.lastName
//        data["is_admin"] = serverUser.isAdmin
        
        data.saveToDefaults(key: jwtToken.login)
        return data
    }
}
