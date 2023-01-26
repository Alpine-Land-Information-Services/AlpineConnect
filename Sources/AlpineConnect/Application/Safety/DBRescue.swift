//
//  DBRescue.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/23.
//

import CoreData
import AlpineUI

public class DBRescue {
    
    static public var dbFail: Bool {
        return !DBRescueViewModel.shared.failedDB.isEmpty
    }
    
    static var restartAlert: AppAlert {
        return AppAlert(title: "Reset Successful", message: "Application must be restarted.",
                        dismiss: AlertAction(text: "Quit App", role: .regular, action: {
                exit(0)
            }))
    }
    
    public struct ContainerInfo: Identifiable {
        public init(container: NSPersistentContainer, error: Swift.Error, containedItems: [String]) {
            self.container = container
            self.error = error
            self.containedItems = containedItems
        }
        
        public var id = UUID()

        var container: NSPersistentContainer
        var error: Error
        var containedItems: [String]
    }
    
    static public func addDBFail(_ db: ContainerInfo) {
        guard !DBRescueViewModel.shared.failedDB.contains(where: {$0.container.name == db.container.name}) else {
            return
        }
        
        AppControl.makeError(onAction: "Database Container Init", error: db.error, showToUser: false)
        
        DBRescueViewModel.shared.failedDB.append(db)
        if !DBRescueViewModel.shared.isShown {
            AppControl.showSheet(view: DBRescueView())
        }
    }
    
    static func clearContainer(_ container: NSPersistentContainer) {
        guard let url = container.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = container.persistentStoreCoordinator

         do {
             try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
             try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
             
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 AppControl.makeAlert(alert: restartAlert)
             }
             
         } catch {
             AppControl.makeError(onAction: "Clearing Map Data", error: error)
         }
    }
}
