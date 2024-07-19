//
//  File.swift
//  
//
//  Created by Vladislav on 7/19/24.
//

import Foundation

public struct LoginPageInfo {
    
    var appName: String
    var companyName: String
    var logoImageName: String
    
    public init(appName: String, companyName: String, logoImageName: String) {
        self.appName = appName
        self.companyName = companyName
        self.logoImageName = logoImageName
    }
}
