//
//  Notifier.swift
//  AlpineConnect
//
//  Created by  on 4/11/22.
//

import Foundation

public struct acNotifyButton {
    public var title: String
    public var actionName: String
}

public struct acNotification {
    public var title: String?
    public var body: String?
    public var buttons: [acNotifyButton]
    public init() {
        buttons = [acNotifyButton]()
    }
}

public class Notifier {
    
    public static func checkForNotification(appName: String, completion: @escaping ([acNotification]) -> Void) {
        guard let devID = Tracker.deviceID() else { return }
        PostgresClientManager.shared.pool?.withConnection { con_from_pool in
            do {
                let connection = try con_from_pool.get()
                defer { connection.close() }
                let text = """
                        SELECT
                        "title"
                        ,"body"
                        ,"buttons"
                        FROM public."notifications"
                        WHERE "app_name" = '\(appName)'
                          AND "device_id" = '\(devID)'
                        """
                print("---------------->>>Alpine Notification Checking<<<----------------")
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                var notifications = [acNotification]()
                let cursor = try statement.execute()
                defer { cursor.close() }
                do {
                    for row in cursor {
                        let columns = try row.get().columns
                        var n = acNotification()
                        n.title = try columns[0].optionalString()
                        n.body = try columns[1].optionalString()
                        if let buttonString = try columns[2].optionalString() {
                            let buttons = buttonString.components(separatedBy: [";"])
                            for button in buttons {
                                let bComponents = button.components(separatedBy: [":"])
                                if bComponents.count == 2 {
                                    let acButton = acNotifyButton(title: bComponents[0], actionName: bComponents[1])
                                    n.buttons.append(acButton)
                                }
                            }
                        }
                        notifications.append(n)
                    }
                } catch {
                }
                completion(notifications)
            } catch {
            }
        }
    }
    
    public static func clearDBMessages(appName: String) {
        guard let devID = Tracker.deviceID() else { return }
        PostgresClientManager.shared.pool?.withConnection { con_from_pool in
            do {
                let connection = try con_from_pool.get()
                defer { connection.close() }
                let text = "DELETE FROM public.\"notifications\" WHERE app_name = '\(appName)' AND device_id = '\(devID)'"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                let cursor = try statement.execute()
                cursor.close()
            }
            catch {
                fatalError("\(error)")
            }
        }
    }
}
