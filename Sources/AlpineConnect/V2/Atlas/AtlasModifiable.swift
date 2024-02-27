//
//  AtlasModifiable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/27/24.
//

import Foundation

public protocol AtlasModifiable: AtlasSyncable, Modifiable {
    
    static var isEditable: Bool { get }
}
