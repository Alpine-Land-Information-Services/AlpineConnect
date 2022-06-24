//
//  LoginViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    
    var info: LoginConnectionInfo
    
    init(info: LoginConnectionInfo) {
        self.info = info
        
        setLoginConnectionInfo()
    }
    
    func setLoginConnectionInfo() {
        NetworkMonitor.shared.start()
        LoginConnectionInfo.shared = info
    }
}
