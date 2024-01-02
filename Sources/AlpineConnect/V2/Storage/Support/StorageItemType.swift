//
//  StorageItemType.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/8/23.
//

import Foundation

public enum StorageItemType {
    case singleLayer
    case layerGroup
    case unknownFile
    case unknownGroup
    case folder
    case json
}

public enum StorageSortingCriteria {
    case date, downloaded, name, size
}
