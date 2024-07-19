//
//  AppInformation.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import Foundation

class AppInformation {
    
    static func getBundle(key: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: key) as? String else {
            fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
}
