//
//  ConnectionProblem.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public struct ConnectionProblem: Decodable {
    
    enum CodingKeys: CodingKey {
        case type
        case title
        case status
        case detail
    }
    
    public let type: String?
    public let title: String?
    public let status: Int?
    public let detail: String?
    
    var customAlert: ConnectAlert?
    
    var alertDetail: String {
        detail ?? "Unknown issue, try again later. \n\n If the problem persists, contact support."
    }
    
    var alert: ConnectAlert {
        customAlert ??
        ConnectAlert(title: title ?? "Unable to Sign In", message: alertDetail)
    }
    
    public init(type: String? = nil, title: String? = nil, status: Int? = nil, detail: String? = nil, customAlert: ConnectAlert?) {
        self.type = type
        self.title = title
        self.status = status
        self.detail = detail
        self.customAlert = customAlert
    }
}

extension ConnectionProblem {
    
    static func timeout(offlineAction: @escaping () -> Void) -> ConnectionProblem {
        let alert = ConnectAlert(title: "Timeout", message: "Could not connect to server in reasonable time.", buttons: [ConnectAlertButton(label: "Sign In Offline", action: offlineAction)], dismissButton: ConnectAlertButton(label: "Cancel", role: .cancel, action: {}))
        
        return ConnectionProblem(customAlert: alert)
    }
    
    static func missingInfo() -> ConnectionProblem {
        let alert = ConnectAlert(title: "Internal Error", message: "Could not retrieve information required for login. \n\nTry again by relaunching application. If the issue persists, contact support.", buttons: nil, dismissButton: nil)
        
        return ConnectionProblem(customAlert: alert)
    }
}
