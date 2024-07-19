//
//  AtlasSyncField.swift
//  
//
//  Created by Vladislav on 7/19/24.
//

import Foundation

public struct AtlasSyncField {
    
    public var layerFieldName: String
    public var objectFieldName: String
    public var isReference: Bool
    public var fieldType: Any.Type
    
    public init(layerFieldName: String, objectFieldName: String, fieldType: Any.Type, isReference: Bool = false) {
        self.layerFieldName = layerFieldName
        self.objectFieldName = objectFieldName
        self.fieldType = fieldType
        self.isReference = isReference
    }
    
    public func convertToLayerType() -> Any.Type {
        switch fieldType {
        case is UUID.Type:
            return String.self
        default:
            return fieldType
        }
    }
}
