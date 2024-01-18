//
//  ConnectUser_CORE.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/16/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
public class ConnectUser_MOVED_TO_CORE {
    
    @Attribute(.unique)
    public var id: String
    
//    @Relationship(deleteRule: .cascade, inverse: \ApplicationError.user)
    @Relationship(deleteRule: .cascade)
    var errors: [ApplicationError] = []
    
//    var bools = [String: AnyHashable]()
    
    init(id: String) {
        self.id = id
    }
}
