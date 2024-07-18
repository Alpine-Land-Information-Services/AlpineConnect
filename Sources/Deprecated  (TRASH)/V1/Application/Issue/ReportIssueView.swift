//
//  ReportIssueView.swift
//  AlpineConnect
//
//  Created by mkv on 5/1/23.
//

import SwiftUI
import AlpineUI

public struct ReportIssueView: View {
    
    @ObservedObject var viewModel: ReportIssueViewModel
    var network = NetworkMonitor.shared
    
    public init(userName: String = "", email: String = "", title: String = "", text: String = "") {
        viewModel = ReportIssueViewModel.shared
        DispatchQueue.main.async { [self] in
            viewModel.name = userName
            viewModel.email = email
            viewModel.title = title
            viewModel.message = text
        }
    }
    
    public var body: some View {
        ScrollView {
            VStack {
                TextFieldBlock(title: "Name", value: $viewModel.name, changed: .constant(false))
                TextFieldBlock(title: "Email", value: $viewModel.email, changed: .constant(false))
                Divider()
                    .padding()
                TextFieldBlock(title: "Subject", value: $viewModel.title, changed: .constant(false))
                TextAreaBlock(title: "Description", text: $viewModel.message, height: 260, changed: .constant(false))
                Toggle("If this is a bug, is it repeatable?", isOn: $viewModel.bug)
                    .padding(.vertical)
                    .frame(width: 350.0)
                Spacer().frame(height: 40)
            }
            .padding()
        }
        .overlay {
            if viewModel.spinner {
                Rectangle().fill(Color.black).opacity(0.5).ignoresSafeArea()
                ProgressView("Sending...").foregroundColor(Color.white).progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.spinner = true
                    viewModel.sendGitReport()
                } label: {
                    if network.connected {
                        Label("Send", systemImage: "paperplane")
                            .labelStyle(.titleAndIcon)
                            .foregroundColor(.green)
                    }
                    else {
                        Text("Connection Required To Send")
                    }
                }
                .disabled(viewModel.name.isEmpty || viewModel.title.isEmpty || viewModel.email.isEmpty || viewModel.message.isEmpty)
                .disabled(!network.connected)
            }
        }
    }
}

struct ReportIssueView_Previews: PreviewProvider {
    static var previews: some View {
        ReportIssueView()
    }
}
