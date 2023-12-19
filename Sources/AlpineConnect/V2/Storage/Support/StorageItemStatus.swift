//
//  StorageItemStatus.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/8/23.
//

import Foundation

public enum StorageItemStatus: String, Codable {
    case cloud
    case downloading
    case uploading
    case pendingUpload
    case pendingDownload
    case uploadPaused
    case downloadPaused
    case downloaded
    case issue
}

public enum StorageItemIssueAction: String {
    case removeOrUpload
    case chooseLocalOrCloud
    case resetToCloud
    case resetToDownloaded
}
