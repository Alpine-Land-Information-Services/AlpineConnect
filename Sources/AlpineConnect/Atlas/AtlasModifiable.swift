//
//  AtlasModifiable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/27/24.
//

import Foundation

public protocol AtlasModifiable: AtlasSyncable, Modifiable {
    
    static var isEditable: Bool { get }
    static var isTrackable: Bool { get }
    static var isEditingStarted: Bool { get set }
    
    var viewRepresentable: AtlasModifiable? { get }
    var parent: AtlasModifiable? { get }
}

public extension AtlasModifiable {
    
    static var isTrackable: Bool {
         false
    }
    
    var isTrackable: Bool {
        Self.isTrackable
    }
    
    var viewRepresentable: AtlasModifiable? {
        self
    }
}

public extension AtlasModifiable {
    
    var parent: AtlasModifiable? {
        nil
    }
}
