//
//  StorageDownloadRequestResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/12/23.
//

import Foundation

public struct StorageDownloadRequestResponse {
    
    public init(status: StorageItemStatus, savePath: String, remotePath: String) {
        self.status = status
        self.savePath = savePath
        self.remotePath = remotePath
    }
    
    public var status: StorageItemStatus
    public var savePath: String
    public var remotePath: String
}
