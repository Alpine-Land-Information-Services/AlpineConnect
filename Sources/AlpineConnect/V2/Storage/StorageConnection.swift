//
//  StorageConnection.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation

@Observable
public class StorageConnection {
    
    var manager: StorageManager {
        StorageManager.shared
    }
    
    var sessionToken: Token
    public var items = [StorageItem]()
    
    var alert: ConnectAlert = .empty
    var isAlertPresented = false
    
    var isFetching = false
    
    public init(sessionToken: Token) {
        self.sessionToken = sessionToken
    }
    
    
    func presentAlert(from problem: ConnectionProblem) {
        DispatchQueue.main.async {
            self.alert = problem.alert
            self.isAlertPresented.toggle()
        }
    }
}
