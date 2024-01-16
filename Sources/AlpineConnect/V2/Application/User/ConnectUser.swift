//
//  ConnectUser.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/16/24.
//

import Foundation
import SwiftData

import SwiftUI

@Model
public class ConnectUser {
    
    @Attribute(.unique)
    public var id: String
    
    init(id: String) {
        self.id = id
    }
}
