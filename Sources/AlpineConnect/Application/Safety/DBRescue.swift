//
//  DBRescue.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/23.
//

import CoreData

public class DBResucue {
    
    public struct ContainerInfo: Identifiable {
        public init(container: NSPersistentContainer, error: Swift.Error, containedItems: [String], resetAction: @escaping () -> ()) {
            self.container = container
            self.error = "\(error)"
            self.containedItems = containedItems
            self.resetAction = resetAction
        }
        
        public var id = UUID()

        var container: NSPersistentContainer
        var error: String
        var containedItems: [String]
        
        var resetAction: () -> ()
    }
    
    static public func addDBFail(_ db: ContainerInfo, error: Swift.Error) {
        guard !DBRescueViewModel.shared.failedDB.contains(where: {$0.container.name == db.container.name}) else {
            return
        }
        
        AppControl.makeError(onAction: "Database Container Init", error: error, showToUser: false)
        
        DBRescueViewModel.shared.failedDB.append(db)
        if !DBRescueViewModel.shared.isShown {
            AppControl.showSheet(view: DBRescueView())
        }
    }
}
