//
//  ReportIssueView.swift
//  AlpineConnect
//
//  Created by mkv on 5/1/23.
//

import SwiftUI

public struct ReportIssueView: View {
    
    @ObservedObject var viewModel: ReportIssueViewModel
    @State var placeholder = "Issue Description"
    
    public init(userName: String = "", email: String = "", title: String = "", text: String = "") {
        viewModel = ReportIssueViewModel.shared
        viewModel.name = userName
        viewModel.email = email
        viewModel.title = title
        viewModel.message = text
    }
    
    public var body: some View {
        ScrollView {
            ScrollViewReader { value in
                Group {
                    TextField("name", text: $viewModel.name, prompt: Text("User Name"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top)
                    TextField("email", text: $viewModel.email, prompt: Text("User Email"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Divider().padding()
                Group {
                    TextField("header", text: $viewModel.title, prompt: Text("Issue Header"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextEditor(text: $viewModel.message)
                        .id(4)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.lightGray), lineWidth: 0.5))
                        .frame(height: 100)
                }
                Group {
                    Toggle("If this is a bug, is it repeatable?", isOn: $viewModel.bug)
                        .padding(.vertical)
                        .frame(width: 350.0)
                    Spacer().frame(height: 40)
                    Button("Send") {
                        viewModel.spinner = true
                        viewModel.sendGitReport()
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.title.isEmpty || viewModel.email.isEmpty || viewModel.message.isEmpty/*!viewModel.isSendingEnable*/)
                }
            }
        }
        .padding(.horizontal)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Report Status"), message: Text("\(viewModel.resultText)"), dismissButton: .default(Text("OK")))
        }
        .overlay {
            if viewModel.spinner {
                Rectangle().fill(Color.black).opacity(0.5).ignoresSafeArea()
                ProgressView("Sending...").foregroundColor(Color.white).progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .navigationTitle("Report Issue")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.clear()
                } label: {
                    Text("Clear Fields")
                }
            }
        }
    }
}
