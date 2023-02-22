//
//  CDObject.swift
//
//  Created by mkv on 2/21/23.
//

import CoreData

public protocol CDObject: NSManagedObject {
    var guid: UUID { get }
}

public extension CDObject {
    
    var guid: UUID {
        value(forKey: "guid") as! UUID
    }
}
