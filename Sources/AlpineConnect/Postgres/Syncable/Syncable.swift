//
//  Syncable.swift
//  AlpineConnect
//
//  Created by mkv on 2/6/23.
//

import CoreData
import PostgresClientKit

public protocol Syncable: CDObject {
 
    static var isImportable: Bool { get }
    static var isExportable: Bool { get }
}

public extension Syncable {
    
    static var isImportable: Bool {
        (self as? Importable.Type != nil) ? true : false
    }
    
    static var isExportable: Bool {
        (self as? any Exportable.Type != nil) ? true : false
    }
    
    static var type: Syncable.Type {
        self as Syncable.Type
    }
}
