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
    
    static public var isInitial: Bool {
        CurrentUser.lastSync == nil
    }
        
    public var currentSyncStartDate = Date()
    
    @Published public var showSync = false
    
    @Published public var slowStatus = SyncStatus.none
    var internalStatus = SyncStatus.none
    
    @Published public var statusMessage = ""
    
    @Published var currentRecord: SyncableRecord?
    @Published var currentRecordProgress = 0.0
    
    @Published var syncRecords = [SyncableRecord]()
    var totalRecordsToSync = 0
    
    @Published var notExportedCount = 0
    
    
    public init() {}
}

extension SyncTracker {
    
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
            DispatchQueue.main.async {
                self.syncRecords.insert(currentRecord, at: 0)
            }
        }
    }
}

extension SyncTracker {
    
    func toggleSyncWindow(to value: Bool) {
        DispatchQueue.main.async {
            withAnimation {
                self.showSync = value
            }
        }
    }
}

public extension SyncTracker {
    
    func updateStatus(_ status: SyncStatus) {
        internalStatus = status
        DispatchQueue.main.async {
            self.slowStatus = status
        }
    }
    
    func statusMessage(_ message: String) {
        DispatchQueue.main.async {
            self.statusMessage = message
        }
    }

    var status: SyncStatus {
        internalStatus
    }
}

//extension SyncTracker {
//
//    func getNotExportedCount() {
//        for object in Sync
//    }
//}
