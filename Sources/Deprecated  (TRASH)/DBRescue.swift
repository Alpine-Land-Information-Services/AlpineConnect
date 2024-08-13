//
//  DBRescue.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/23.
//

import CoreData
import AlpineUI
import AlpineCore
//import Zip
import PostgresClientKit
import UIKit

//public class DBRescue {
//    
//    public static func rescueDB(userName: String, url: URL, handler: @escaping ((Bool, String) -> Void)) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                let tempUrl = try Zip.quickZipFiles([url], fileName: "tempDB")
//                let data = try Data(contentsOf: tempUrl)
//
//                DispatchQueue.main.async {
//                    defer { try? FileManager.default.removeItem(at: tempUrl) }
//                    sendArchiveData(userName: userName, data: data, handler: { finished, text in
//                        handler(finished, text)
//                    })
//                }
//            }
//            catch {
//                handler(false, "\(error)")
//                print(error)
//            }
//        }
//    }
//
//    static func sendArchiveData(userName: String, data: Data, handler: @escaping ((Bool, String) -> Void)) {
//        TrackingManager.shared.pool?.withConnection { con_from_pool in
//            do {
//                let id = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
//                let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Unknown"
//                let dataValue = PostgresByteA.init(data: data)
//                let uploadDate = Date().toStringTimeZonePST(dateFormat: "yyyy-MM-dd HH:mm:ss")
//
//                let connection = try con_from_pool.get()
//                defer { connection.close() }
//
//                let query = """
//                    INSERT INTO public.recovery_files(
//                    id, application, user_name, data, upload_date)
//                    VALUES ($1, $2, $3, $4, $5)
//                    ON CONFLICT (id, application) DO UPDATE SET
//                    application = EXCLUDED.application,
//                    user_name = EXCLUDED.user_name,
//                    data = EXCLUDED.data,
//                    upload_date = EXCLUDED.upload_date
//                    """
//                
//                let statement = try connection.prepareStatement(text: query)
//                defer { statement.close() }
//
//                try statement.execute(parameterValues: [id, appName, userName, dataValue, uploadDate])
//
//                Core.makeSimpleAlert(title: "Database Sent", message: "Your local database was successfully sent.")
//                handler(true, "Export Successful")
//            }
//            catch {
//                Core.makeError(error: error, additionalInfo:  "Sending Database")
//                handler(false, "\(error)")
//            }
//        }
//    }
//    
//}

//extension DBRescue {
//    static public var dbFail: Bool {
//        return !DBRescueViewModel.shared.failedDB.isEmpty
//    }
//
//    static var restartAlert: CoreAlert {
//        CoreAlert(title: "Reset Successful", message: "Application must be restarted.",
//                  buttons: [CoreAlertButton(title: "Quit App", style: .default, action: {
//            Core.quit()
//        })])
//    }
//
//    public struct ContainerInfo: Identifiable {
//        public init(container: NSPersistentContainer, error: Swift.Error, containedItems: [String]) {
//            self.container = container
//            self.error = error
//            self.containedItems = containedItems
//        }
//
//        public var id = UUID()
//
//        var container: NSPersistentContainer
//        var error: Error
//        var containedItems: [String]
//    }
//
//    static public func addDBFail(_ db: ContainerInfo) {
//        guard !DBRescueViewModel.shared.failedDB.contains(where: {$0.container.name == db.container.name}) else {
//            return
//        }
//
//        Core.makeError(error: db.error, additionalInfo: "Database Container Init", showToUser: false)
//        DBRescueViewModel.shared.failedDB.append(db)
//        if !DBRescueViewModel.shared.isShown {
//            AppControlOld.showSheet(view: DBRescueView())
//        }
//    }
//
//    static func clearContainer(_ container: NSPersistentContainer) {
//        guard let url = container.persistentStoreDescriptions.first?.url else { return }
//
//        let persistentStoreCoordinator = container.persistentStoreCoordinator
//
//        do {
//            try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
//            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                Core.makeAlert(restartAlert)
//            }
//
//        } catch {
//            Core.makeError(error: error, additionalInfo: "Clearing Map Data")
//        }
//    }
//
//}
