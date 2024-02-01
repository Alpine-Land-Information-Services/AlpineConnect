//
//  AppReset.swift
//  AlpineConnect
//
//  Created by mkv on 1/31/24.
//

import Foundation

public class AppReset {
    // "code_a.d.p.g"
    // delete files from:
    // a: "Application Support"  in application's Library folder
    // d: "Documents"            in application's folder
    // p: "Preferences"          in application's Library folder
    // g: Application Group      in "group.com.alpinelis.atlas"
    
    private enum DeleteSource: String {
        case a
        case d
        case p
        case g
    }
    
    private static let currectAppResetCode = "b3_a.d.p.g"
    private static let appResetCodeKey = "AC_app_reset_code"
    
    public static func checkNeedReset() {
        if let code = UserDefaults.standard.value(forKey: appResetCodeKey) as? String {
            if code == currectAppResetCode {
                return
            }
            performReset()
        }
        else {
            performReset()
        }
        
        UserDefaults.standard.setValue(currectAppResetCode, forKey: appResetCodeKey)
        UserDefaults.standard.synchronize()
    }
    
    private static func performReset() {
        let components = currectAppResetCode.components(separatedBy: "_")
        if components.count == 2 {
            let deletion = components[1].components(separatedBy: ".")
            for item in deletion {
                if let source = DeleteSource(rawValue: item) {
                    delete(from: source)
                }
            }
        }
    }
    
    private static func delete(from source: DeleteSource) {
        var url: URL?
        switch source {
        case .a:
            url = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .d:
            url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .p:
            url = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            url = url?.appending(component: "Preferences")
        case .g:
            url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas")
        }
        if let url {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
