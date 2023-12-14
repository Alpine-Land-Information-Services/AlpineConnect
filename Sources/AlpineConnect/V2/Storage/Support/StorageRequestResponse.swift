//
//  StorageRequestResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/12/23.
//

import Foundation

public struct StorageRequestResponse {
    
    public init(queueOrder: Int, taskIdentifier: Int, savePath: String?) {
        self.queueOrder = queueOrder
        self.taskIdentifier = taskIdentifier
        self.savePath = savePath
    }
    
    public var queueOrder: Int
    public var taskIdentifier: Int
    public var savePath: String?
}
