//
//  CDObject.swift
//
//  Created by  on 2/21/23.
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
