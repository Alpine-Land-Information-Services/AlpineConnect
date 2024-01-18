//
//  DBRescueViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/23.
//

import CoreData
import AlpineUI

class DBRescueViewModel: ObservableObject {
 
    static var shared = DBRescueViewModel()
    
    @Published var isShown = false
    @Published var failedDB = [DBRescue.ContainerInfo]()
    
    func resetCointainer(_ container: NSPersistentContainer) {
        let alert = AppAlert(title: "Reset Container?", message: "This will delete your current database container and all data within it. \nAll not exported data will be lost.", dismiss: AlertAction(text: "Cancel", role: .dismiss, action: {}), actions: [
            AlertAction(text: "Reset", role: .destructive, action: {DBRescue.clearContainer(container)})])
        AppControlOld.makeAlert(alert: alert)
    }
}
