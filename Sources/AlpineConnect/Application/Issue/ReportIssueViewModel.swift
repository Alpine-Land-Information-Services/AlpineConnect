//
//  ReportIssueViewModel.swift
//  AlpineConnect
//
//  Created by mkv on 5/1/23.
//

import Foundation

public class ReportIssueViewModel: ObservableObject {
    
    public static var shared = ReportIssueViewModel()
    
    @Published var title: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var message: String = ""
    var bug = false
    var resultText = ""
    @Published var showAlert = false
    @Published var spinner = false
    
    private var owner: String = ""
    private var repository: String = ""
    private var token: String = ""
    
    public func doInit(owner: String, repository: String, token: String) {
        self.owner = owner
        self.repository = repository
        self.token = token
    }
    
    func sendGitReport() {
        sendGitReport(title: title, message: message, name: name, email: email, bug: bug)
    }
    
    private func sendGitReport(title: String, message: String, name: String, email: String, bug: Bool) {
        guard !owner.isEmpty, !repository.isEmpty, !token.isEmpty else {
            resultText = "Repository is not initialized."
            return
        }
        
        GitReport().sendReport(owner: owner,
                               repository: repository,
                               token: token,
                               title: title,
                               message: message,
                               name: name,
                               email: email,
                               bug: bug) { result in
            switch result {
            case .success(let data):
                self.resultText = "Report sent.\nIssue #\(data["number"] as? Int ?? 0) created."
                DispatchQueue.main.async {
                    self.clear()
                }
            case .failure(let error):
                self.resultText = "Error sending report.\n\(error.message)"
            }
            DispatchQueue.main.async {
                self.showAlert = true
                self.spinner = false
            }
        }
    }
    
    func clear() {
        title = ""
        name = ""
        email = ""
        message = ""
        bug = false
    }
}
