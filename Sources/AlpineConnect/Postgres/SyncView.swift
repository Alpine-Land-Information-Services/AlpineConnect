//
//  SyncView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import SwiftUI
import AlpineUI

public struct SyncView: View {
    
    @StateObject var viewModel = SyncViewModel()
    @ObservedObject var tracker = SyncTracker.shared
    
    @Environment(\.dismiss) var dismiss
    
    public init() {}
    
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
        }
        .interactiveDismissDisabled(tracker.status != .none)
        .onChange(of: tracker.status) { newValue in
            if newValue == .none {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
        .onDisappear {
            SyncTracker.clear()
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
            if tracker.status != .none && tracker.status != .error {
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
        .background(Color(.white))
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
                    ProgressView("\(record.name) - \(record.recordsCount > 0 ? "Done" : "No Change")", value: record.recordsCount, total: record.recordsCount)
                        .progressViewStyle(.linear)
                        .padding(.vertical)
                        .foregroundColor(Color(uiColor: .systemGray))
                        .accentColor(Color(uiColor: .systemGray))
                }
            }
        }
    }
}

struct SyncView_Previews: PreviewProvider {
        
    static var previews: some View {
        SyncTest()
    }
    
    struct SyncTest: View {
        
        var body: some View {
            VStack {
                
            }
            .sheet(isPresented: .constant(true)) {
                SyncView()
            }
            .onAppear {
                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", recordsCount: 123))
                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", recordsCount: 123))
                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", recordsCount: 123))
                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", recordsCount: 123))
                SyncTracker.shared.syncRecords.append(SyncTracker.SyncableRecord(name: "Test Site Calling", recordsCount: 123))

            }
        }
    }
}
