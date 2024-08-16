//
//  AtlasConnectEvent.swift
//
//
//  Created by Vladislav on 8/15/24.
//

import Foundation
import AlpineCore

public enum AtlasConnectEvent: String {
    
    case applicationInForeground = "application_in_foreground"
    case applicationInBackground = "application_in_background"
    case initializingSync = "initializing_sync"
    case syncingFinished = "syncing_finished"
    case postgresPoolNil = "postgres_pool_nil"
    case poolConnectionFailure = "pool_connection_failure"
    case syncStatus = "sync_status"
    case syncRecordInfo = "sync_record_info"

}

extension CoreAppControl {
    /// Logs an event of type `AtlasConnectEvent` to Firebase Analytics.
    ///
    /// This method uses `logAtlasConnectEvent` to send the event to Firebase Analytics. The event is specified
    /// using the `AtlasConnectEvent` enumeration and can be accompanied by optional parameters.
    ///
    /// - Parameters:
    ///   - event: The event to be logged, from the `AtlasConnectEvent` enumeration.
    ///   - type: An optional type of the event, from the `AppEventType` enumeration. Defaults to `nil`.
    ///   - fileInfo: An optional string containing file information. Defaults to `nil`.
    ///   - parameters: An optional dictionary of parameters associated with the event. Defaults to `nil`.
    ///   - file: The name of the file from which the function is called. Defaults to the file where the function is called.
    ///   - function: The name of the function from which the function is called. Defaults to the function where the function is called.
    ///   - line: The line number from which the function is called. Defaults to the line where the function is called.
    ///
    /// - Example:
    ///   ```swift
    ///   CoreAppControl.logAtlasConnectEvent(.createdSiteCalling, parameters: ["key": "value"])
    ///   ```
    ///
    /// - Note:
    ///   Ensure that the `AtlasConnectEvent` enumeration includes all possible events you want to log.
    public static func logAtlasConnectEvent(_ event: AtlasConnectEvent,
                                            extendedEventName: String? = nil,
                                           type: AppEventType? = nil,
                                           fileInfo: String? = nil,
                                           parameters: [String: Any]? = nil,
                                           file: String = #file,
                                           function: String = #function,
                                           line: Int = #line) {
        let eventName = extendedEventName != nil ? "\(event.rawValue)_\(extendedEventName!.toSnakeCase())" : event.rawValue
        logEvent(eventName, type: type?.rawValue, parameters: parameters, fileInfo: fileInfo, file: file, function: function, line: line)
    }
}

