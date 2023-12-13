//
//  StorageDownloadRequestResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/12/23.
//

import Foundation

public struct StorageDownloadRequestResponse {
    
    public init(queueOrder: Int, savePath: String, remotePath: String) {
        self.queueOrder = queueOrder
        self.savePath = savePath
        self.remotePath = remotePath
    }
    
    public var queueOrder: Int
    public var savePath: String
    public var remotePath: String
}
