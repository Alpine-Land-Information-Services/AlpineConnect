//
//  ApplicationError.swift
//  AlpineConnect
//
//  Created by mkv on 1/17/24.
//

import Foundation
import SwiftData
import AlpineCore

@Model
public class ApplicationError {
    
    var guid = UUID()
    var date = Date()
    var onAction: String?
    var systemLog: String?
    var additionalInfo: String?
    var typeName: String?
    
//    var user: ConnectUser?
    
    private init(onAction: String?, error: Error, description: String?) {
        if let err = error as? AlpineError {
            self.typeName = err.getType()
        }
        self.systemLog = error.log()
        self.onAction = onAction
        self.additionalInfo = description
//        self.user = ConnectManager.shared.user
    }
    
    static func add(onAction: String?, error: Error, additionalInfo: String?, in context: ModelContext) throws {
        let error = ApplicationError(onAction: onAction, error: error, description: additionalInfo)
        context.insert(error)
        try context.save()
    }
    
    static func add(error: Error, in context: ModelContext) throws {
//        let error = ApplicationError(onAction: onAction, error: error, description: customDescription)
//        context.insert(error)
//        try context.save()
    }
}
