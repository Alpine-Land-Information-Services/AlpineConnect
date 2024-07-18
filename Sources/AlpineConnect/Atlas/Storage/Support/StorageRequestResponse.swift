//
//  StorageRequestResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/12/23.
//

import Foundation

public struct StorageRequestResponse {
    
    public init(queueOrder: Int, taskIdentifier: Int) {
        self.queueOrder = queueOrder
        self.taskIdentifier = taskIdentifier
    }
    
    public var queueOrder: Int
    public var taskIdentifier: Int
}
