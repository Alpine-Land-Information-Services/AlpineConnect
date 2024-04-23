//
//  Syncable.swift
//  AlpineConnect
//
//  Created by mkv on 2/6/23.
//

import CoreData
import AlpineCore
import PostgresClientKit

public protocol Syncable: CDObject {
 
    static var isImportable: Bool { get }
    static var isExportable: Bool { get }
    
    static var syncManager: SyncManager { get }
    
    static var isSavedIndependently: Bool { get }
    
    var isLocal: Bool { get }
}

public extension Syncable {
    
    static var isSavedIndependently: Bool {
        false
    }
    
    static var isImportable: Bool {
        self as? Importable.Type != nil
    }
    
    static var isExportable: Bool {
        self as? any Exportable.Type != nil
    }
    
    var isLocal: Bool {
        value(forKey: "a_syncDate") == nil
    }
}

public extension Syncable {
    //we should check "Connect.user != nil" before sync starts
    static var syncUser: ConnectUser {
        Connect.user!
    }
}
