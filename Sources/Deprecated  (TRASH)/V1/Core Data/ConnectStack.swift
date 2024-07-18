//
//  ConnectStack.swift
//  
//
//  Created by Jenya Lebid on 1/19/23.
//

import Foundation
import CoreData

public class ConnectStack {
        
    static let identifier = "AlpineConnect"
    static let model = "ConnectData"

    public static var managedObjectModel: NSManagedObjectModel {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: model, withExtension: ".momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    public static var persitentContainer: NSPersistentContainer = {
        // deleting of core data sqlite file in case of significant changes in data structure
//        var url = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
//        do {
//            try FileManager.default.removeItem(atPath: url + "/\(model).sqlite")
//        }
//        catch {
//            print("\(error)")
//        }
        
        let container = NSPersistentContainer(name: model, managedObjectModel: managedObjectModel)
        container.loadPersistentStores { (description, error) in
            
            if let error = error {
                fatalError("Loading Core Data Store Failed.")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
}
