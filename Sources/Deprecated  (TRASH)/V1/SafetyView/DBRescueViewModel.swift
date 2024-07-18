//
//  DBRescueViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/23.
//

import SwiftUI
import CoreData
import AlpineUI
import AlpineCore
import PopupKit

//class DBRescueViewModel: ObservableObject {
// 
//    static var shared = DBRescueViewModel()
//    
//    @Published var isShown = false
//    @Published var failedDB = [DBRescue.ContainerInfo]()
//    
//    func resetCointainer(_ container: NSPersistentContainer) {
//        let alert = CoreAlert(title: "Reset Container?",
//                              message: "This will delete your current database container and all data within it. \nAll not exported data will be lost.",
//                              buttons: [AlertButton(title: "Cancel", style: .cancel, action: {}),
//                                        AlertButton(title: "Reset", style: .destructive, action: { DBRescue.clearContainer(container) })
//                                       ])
//        Core.makeAlert(alert)
//    }
//}
