//
//  SyncTracker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import SwiftUI

public class SyncTracker: ObservableObject {
    
    public enum SyncStatus {
        case exportReady
        case exporting
        case exportDone
        
        case importReady
        case importing
        case importDone
        
        case actions
        
        case error
        case none
    }
    
    struct SyncableRecord: Identifiable {
        
        enum RecordType: String {
            case `import`
            case export
        }
        
        var id = UUID()
        var name: String
        var type: RecordType
        var recordsCount: Double
    }
    
    static public var shared = SyncTracker()
    
    static public var isInitial: Bool {
        CurrentUser.lastSync == nil
    }
    
    @Published public var showSync = false
    
    @Published public var status = SyncStatus.none
    var internalStatus = SyncStatus.none
    
    @Published public var statusMessage = ""
    
    @Published var currentRecord: SyncableRecord?
    @Published var currentRecordProgress = 0.0
    
    @Published var syncRecords = [SyncableRecord]()
    var totalRecordsToSync = 0

    func progressUpdate() {
        DispatchQueue.main.async {
            self.currentRecordProgress += 1
        }
    }
    
    func makeRecord(name: String, type: SyncTracker.SyncableRecord.RecordType, recordCount: Int) {
        DispatchQueue.main.async { [self] in
            currentRecordProgress = 0
            currentRecord = SyncableRecord(name: name, type: type, recordsCount: Double(recordCount))
            if recordCount == 0 {
                endRecordSync()
            }
        }
    }
    
    func endRecordSync() {
        if let currentRecord {
            syncRecords.insert(currentRecord, at: 0)
        }
    }
}

extension SyncTracker {
    
    static func toggleSyncWindow(to value: Bool) {
        DispatchQueue.main.async {
            withAnimation {
                SyncTracker.shared.showSync = value
            }
        }
    }
}

public extension SyncTracker {
    
    static func updateStatus(_ status: SyncStatus) {
        SyncTracker.shared.internalStatus = status
        DispatchQueue.main.async {
            SyncTracker.shared.status = status
        }
    }
    
    static func statusMessage(_ message: String) {
        DispatchQueue.main.async {
            SyncTracker.shared.statusMessage = message
        }
    }
    
    static func clear() {
        SyncTracker.shared = SyncTracker()
    }
    
    static var status: SyncStatus {
        SyncTracker.shared.internalStatus
    }
}
