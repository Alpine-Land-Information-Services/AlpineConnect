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
    var file: String?
    var function: String?
    var line: Int?
    var message: String?
    var additionalInfo: String?
    var typeName: String?
    
//    var user: ConnectUser?
    
    public init(error: Error, additionalText: String? = nil) {
        if let err = error as? AlpineError {
            self.typeName = err.getType()
            self.file = err.file
            self.function = err.function
            self.line = err.line
            self.message = err.message
        } else {
            self.message = error.log()
        }
        self.additionalInfo = additionalText
    }
    
    public static func add(error: Error, additionalInfo: String? = nil, in context: ModelContext) {
        let err = ApplicationError(error: error, additionalText: additionalInfo)
        context.insert(err)
//        try? context.save()
    }
}
