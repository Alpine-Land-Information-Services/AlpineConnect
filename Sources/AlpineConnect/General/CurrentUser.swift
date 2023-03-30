//
//  CurrentUser.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/16/23.
//

import Foundation

open class CurrentUser {
    
    public enum DBType: String, Codable {
        case production
        case sandbox
    }

    static private var data = [String: Any]()
    static private var userKey: String {
        data["email"] as! String
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
    
    static var lastSync: Date? {
        data["lastSync"] as? Date
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
    
    static var dbType: DBType {
        DBType(rawValue: data["dbType"] as! String)!
    }
    
    static var lastView: (String, UUID)? {
        let lastViewType = data["lastViewType"] as? String
        let lastViewID = data["lastViewID"] as? String
        
        guard let lastViewID, let lastViewType else {
            return nil
        }

        return (lastViewType, UUID(uuidString: lastViewID)!)
    }
}

public extension CurrentUser {
    
    static func updateSyncDate(_ date: Date?) {
        data["lastSync"] = date
        data.saveToDefaults(key: userKey)
    }
    
    static func updateDBType(to type: DBType) {
        data["dbType"] = type.rawValue
        data.saveToDefaults(key: userKey)
    }
    
    static func updateLastView(type: String?, id: UUID) {
        guard let type else { return }
        
        data["lastViewType"] = type
        data["lastViewID"] = id.uuidString
        data.saveToDefaults(key: userKey)
    }
}
