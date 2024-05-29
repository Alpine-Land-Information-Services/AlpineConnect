//
//  SyncView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import SwiftUI
import AlpineUI

public struct SyncView: View {
    
    @StateObject var viewModel: SyncViewModel
    @ObservedObject var tracker: SyncTracker

    @Environment(\.dismiss) var dismiss
    
    public init(for sync: SyncManager) {
        self._tracker = ObservedObject(wrappedValue: sync.tracker)
        self._viewModel = StateObject(wrappedValue: SyncViewModel(sync: sync))
    }
    
    public var body: some View {
        NavigationBlock(title: "", mode: .inline) {
            VStack {
                VStack {
                    hello
                    Divider()
                    syncMessage
                    progress
                }
                .padding([.horizontal, .top])
                syncedRecords
            }
            .background(Color(uiColor: .systemGray6))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(role: .destructive) {
                            tracker.manager.userSyncCancelAlert()
                        } label: {
                            Label("Cancel Sync", systemImage: "exclamationmark.octagon")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .interactiveDismissDisabled(tracker.status != .none && tracker.status != .canceled)
        .onChange(of: tracker.status) { newValue in
            if newValue == .none || newValue == .canceled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    dismiss()
                }
            }
        }
        .onAppear {
            tracker.showingUI = true
        }
        .onDisappear {
            tracker.manager.clear()
        }
    }
    
    var hello: some View {
        HStack {
            Text(viewModel.greeting)
                .font(.title)
                .fontWeight(.medium)
            Spacer()
            Image(packageResource: viewModel.image, ofType: ".png").resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 100)
        }
    }
    
    var syncMessage: some View {
        HStack {
            if tracker.status != .none && tracker.status != .error && tracker.status != .canceled {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.horizontal, 6)
            }
            Text(viewModel.statusMessage)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(viewModel.statusColor)
        }
        .padding(20)
    }
    
    var progress: some View {
        VStack {
            if tracker.status == .error {
                VStack {
                    Text("Check error log and share with developer to resolve the issue.")
                        .font(.subheadline)
                        .foregroundColor(Color(uiColor: .systemGray))
                        .padding(10)
                    TextButtonBlock(text: "Dismiss", font: .headline, action: {
                        dismiss()
                    })
                }
            }
            else {
                Text(tracker.currentRecord?.name ?? "---")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .systemGray))
                ProgressView(value: tracker.currentRecordProgress, total: tracker.currentRecord?.recordsCount ?? 0)
                    .progressViewStyle(.linear)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.vertical)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(Color(UITraitCollection.current.userInterfaceStyle == .light ? .white : .systemGray3))
        .cornerRadius(10)
    }
    
    var syncedRecords: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Completed")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(uiColor: .systemGray))
                Spacer()
                Text("\(tracker.syncRecords.count) out of \(viewModel.totalToSync)")
                    .fontWeight(.bold)
                    .foregroundColor(Color(uiColor: .systemGray))
            }
            .padding()
            Divider()
            List {
                ForEach(tracker.syncRecords) { record in
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(record.type.rawValue.capitalized): \(record.name)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(uiColor: .systemGray))
                            Spacer()
                            Group {
                                Text("Status:")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(uiColor: .systemGray))
                                Text("\(record.recordsCount > 0 ? "Completed" : "No Change")")
                                    .font(.caption)
                                    .foregroundColor(Color(uiColor: .systemGray))
                            }
                        }
                        ProgressView(value: record.recordsCount, total: record.recordsCount)
                            .progressViewStyle(.linear)
                            .padding(.vertical)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .accentColor(Color(uiColor: .systemGray))
                    }
                }
            }
        }
    }
}

//struct SyncView_Previews: PreviewProvider {
//        
//    static var previews: some View {
//        SyncTest()
//    }
//    
//    struct SyncTest: View {
//        
//        var body: some View {
//            VStack {
//                
//            }
//            .sheet(isPresented: .constant(true)) {
//                SyncView(for: <#Sync#>)
//            }
//            .onAppear {
//                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", type: .import, recordsCount: 0))
//                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", type: .export, recordsCount: 0))
//                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", type: .import, recordsCount: 123))
//                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", type: .export, recordsCount: 123))
//                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", type: .export, recordsCount: 123))
//
//            }
//        }
//    }
//}
