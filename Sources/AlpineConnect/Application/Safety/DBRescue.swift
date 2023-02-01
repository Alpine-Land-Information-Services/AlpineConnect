//
//  DBRescue.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/23.
//

import CoreData
import AlpineUI
import Zip
import PostgresClientKit
import UIKit

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
    
    static func RescueDB(userName: String, url: URL, handler: @escaping ((Bool, String) -> Void)) {
        fatalError("need to fix compile error in quickZipFiles")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let tempUrl = URL(string: "")!//try Zip.quickZipFiles([url], fileName: "tempDB")
                let data = try Data(contentsOf: tempUrl)

                DispatchQueue.main.async {
                    defer { try? FileManager.default.removeItem(at: tempUrl) }
                    SendArchiveData(userName: userName, data: data, handler: { finished, text in
                        handler(finished, text)
                        print("Database Sent")
                    })
                }
            }
            catch {
                handler(false, "\(error)")
                print(error)
            }
        }
    }

    static func SendArchiveData(userName: String, data: Data, handler: @escaping ((Bool, String) -> Void)) {
        TrackingManager.shared.pool?.withConnection { con_from_pool in
            do {
                let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Unknown"
                let connection = try con_from_pool.get()
                defer { connection.close() }
                let query1 = """
                    INSERT INTO public.recovery_files(
                    id
                    , application
                    , user_name
                    , data
                    , upload_date)
                    VALUES (
                      '\(UIDevice.current.identifierForVendor ?? UUID())'
                    , '\(appName)'
                    , '\(userName)'
                    , '\(PostgresByteA.init(data: data).postgresValue)'
                    , '\(DatetoStringTimeZonePST())')

                    ON CONFLICT (id, application) DO UPDATE SET
                    application = EXCLUDED.application,
                    user_name = EXCLUDED.user_name,
                    data = EXCLUDED.data,
                    upload_date = EXCLUDED.upload_date
                    """
                let statement1 = try connection.prepareStatement(text: query1)
                defer { statement1.close() }
                try statement1.execute()

                handler(true, "Export Successful")
            }
            catch {
                handler(false, "\(error)")
                print(error)
            }
        }
    }
    
    static func DatetoStringTimeZonePST(date: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return dateFormatter.string(from: date)
    }
}
