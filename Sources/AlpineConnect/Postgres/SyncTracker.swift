//
//  SyncTracker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import Foundation

public class SyncTracker: ObservableObject {
    
    public enum SyncStatus {
        case importing
        case exporting
        case actions
        case error
        case none
    }
    
    struct SyncableRecord: Identifiable {
        var id = UUID()
        var name: String
        var recordsCount: Double
    }
    
    static public var shared = SyncTracker()
    
    static public var isInitial: Bool {
        CurrentUser.lastSync == nil
    }
    
    @Published public var status = SyncStatus.none
    @Published public var statusMessage = ""
    
    @Published var currentRecord: SyncableRecord?
    @Published var currentRecordProgress = 0.0
    
    @Published var syncRecords = [SyncableRecord]()
    var totalReccordsToSync = 0

    public func progressUpdate() {
        DispatchQueue.main.async {
            self.currentRecordProgress += 1
        }
    }
    
    public func makeRecord(name: String, recordCount: Int) {
        DispatchQueue.main.async { [self] in
            currentRecordProgress = 0
            currentRecord = SyncableRecord(name: name, recordsCount: Double(recordCount))
            if recordCount == 0 {
                endRecordSync()
            }
        }
    }
    
    public func endRecordSync() {
        if let currentRecord {
            syncRecords.insert(currentRecord, at: 0)
        }
    }
}

extension SyncTracker {
    
    static public func updateStatus(_ status: SyncStatus) {
        DispatchQueue.main.async {
            SyncTracker.shared.status = status
        }
    }
    
    static public func statusMessage(_ message: String) {
        DispatchQueue.main.async {
            SyncTracker.shared.statusMessage = message
        }
    }
    
    static public func clear() {
        SyncTracker.shared = SyncTracker()
    }
}
