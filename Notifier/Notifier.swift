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
    
    public static func checkForNotification(completion: @escaping ([acNotification]) -> Void) {
        guard let devID = Tracker.deviceID() else { return }
        let appName = Tracker.appName()
        PostgresClientManager.shared.pool?.withConnection { con_from_pool in
            do {
                let connection = try con_from_pool.get()
                defer { connection.close() }
                let text = """
                        SELECT
                          n."title"
                        , n."body"
                        , n."buttons"
                        , p."notification_id"
                        FROM public."notification_pool" AS p
                        JOIN public."notifications"     AS n ON p."notification_id" = n."id"
                        WHERE p."app_name" = '\(appName)'
                          AND p."device_id" = '\(devID)'
                          AND p."read" = FALSE
                        """
                print("---------------->>>Alpine Notification Checking<<<----------------")
                print(text)
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
    
    public static func utilizeMessages() {
        guard let devID = Tracker.deviceID() else { return }
        let appName = Tracker.appName()
        PostgresClientManager.shared.pool?.withConnection { con_from_pool in
            do {
                let connection = try con_from_pool.get()
                defer { connection.close() }
                let text = """
                    INSERT INTO public."notification_pool" (device_id, app_name, read)
                    VALUES ('\(devID)', '\(appName)', TRUE)
                    ON CONFLICT (device_id, app_name, notification_id) DO UPDATE SET
                    read = EXCLUDED.read
                """
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
