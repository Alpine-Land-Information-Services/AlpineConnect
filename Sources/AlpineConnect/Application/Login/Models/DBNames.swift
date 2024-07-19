//
//  DBNames.swift
//  
//
//  Created by Vladislav on 7/19/24.
//

import Foundation

public struct DBNames {
    
    private var productionName: String
    private var sandboxName: String
    
    public init(productionName: String, sandboxName: String) {
        self.productionName = productionName
        self.sandboxName = sandboxName
    }

    func getName(from type: DatabaseType) -> String {
        switch type {
        case .production:
            return productionName
        case .sandbox:
            return sandboxName
        }
    }
}
