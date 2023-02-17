//
//  AppError.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/19/23.
//

import CoreData
import AlpineUI

extension AppError {
    
    static public func add(onAction: String, log: String, in context: NSManagedObjectContext = .newBackground()) {
        context.perform {
            let error = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: AppError.entityName, in: context)!, insertInto: context) as! AppError
            error.guid = UUID()
            error.date = Date()
            
            error.log = log
            error.onAction = onAction
            
            try? context.save()
        }
    }
}

extension Error {
    
    public func log() -> String {
        "\(self)"
    }
}
