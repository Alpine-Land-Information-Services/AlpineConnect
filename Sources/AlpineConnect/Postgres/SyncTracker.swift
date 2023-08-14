//
//  SyncTracker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import SwiftUI
import CoreData
import AlpineCore

public class SyncTracker: ObservableObject {
    
    public enum SyncStatus {
        case exportReady
        case exportPreparing
        case exporting
        case exportDone
        
        case importReady
        case importPreparing
        case importing
        case importDone
        
        case actions
        case saving
        
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
    
    public var currentSyncStartDate = Date()
    
    @Published public var showSync = false
    
    @Published public var slowStatus = SyncStatus.none
    var internalStatus = SyncStatus.none
    
    @Published public var statusMessage = ""
    
    @Published var currentRecord: SyncableRecord?
    @Published var currentRecordProgress = 0.0
    
    @Published var syncRecords = [SyncableRecord]()
    var totalRecordsToSync = 0
    
    @Published public var notExported = [UUID]()
    
    weak var manager: SyncManager!
    var count = 0
    
    internal init() {}
}

extension SyncTracker {
    
    func progressUpdate(adding number: Double = 1) {
        DispatchQueue.main.async {
            self.currentRecordProgress += number
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
    
    var isInitial: Bool {
        CurrentUser.lastSync == nil
    }
    
    var status: SyncStatus {
        internalStatus
    }
    
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
}

extension SyncTracker {
    
    public func addToNotExported(_ guid: UUID) {
        DispatchQueue.main.async {
            self.notExported.appendIfNotExists(guid)
        }
    }

    public func removeFromNotExported(_ guid: UUID) {
        DispatchQueue.main.async {
            self.notExported.removeIfExists(guid)
        }
    }

    public func fillNotExported(for objects: [CDObject.Type], in context: NSManagedObjectContext) async {
        do {
            let notExported = try await getNotExported(for: objects, in: context)
            DispatchQueue.main.async {
                self.notExported = notExported
            }
        }
        catch {
            AppControl.makeError(onAction: "Fetching Object Count", error: error)
        }
    }
    
    private func getNotExported(for objects: [CDObject.Type], in context: NSManagedObjectContext) async throws -> [UUID] {
        var ids = [UUID]()
        for object in objects {
            ids.append(contentsOf: try await object.getNotExportedCount(in: context))
        }
        
        return ids
    }
}
