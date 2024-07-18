//
//  Notification.swift
//  AlpineConnect
//
//  Created by mkv on 3/28/23.
//

import Foundation

public extension Notification.Name {
    static let mapObjectSelect = Notification.Name(rawValue: "AMK_Map_Object_Select")
    static let layersReinit = Notification.Name(rawValue: "CORE_Layer_ReInit")
    
    static let AC_UserLocationUpdate = Notification.Name("AC_UserLocationUpdate")
    static let AC_ConnectionRefresh = Notification.Name("AC_ConnectionRefresh")
    static let AC_DownloadUpdate = Notification.Name("AC_DownloadUpdate")
    static let AC_SessionStatusChange = Notification.Name("AC_SessionStatusChange")
    static let AC_DownloadComplete = Notification.Name("AC_DownloadComplete")
    static let AC_DataSessionComplete = Notification.Name("AC_DataSessionComplete")
    static let AC_SyncComplete = Notification.Name("AC_SyncComplete")
    static let AC_MyFolderUpdate = Notification.Name("AC_MyFolderUpdate")
    static let AC_MyFolderSyncCountUpdate = Notification.Name("AC_MyFolderSyncCountUpdate")
}
