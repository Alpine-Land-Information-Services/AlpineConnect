//
//  PasswordHash.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import Foundation
import CryptoKit
import CommonCrypto

extension String {
    
    func hashString() -> String {
        let stringData = Data(self.utf8)
        let hashedData = SHA256.hash(data: stringData)
        let hashedPassword = hashedData.compactMap {String(format: "%02X", $0)}.joined()
        return hashedPassword.lowercased()
    }
    
    func sha1(_ uppercase:Bool = false) -> String {
        /* 128 bit SHA1 sum hex string */
        let fmt = uppercase ? "%02hhX" : "%02hhx" // "%02hhx" -- "hh" for char/UInt8, "h" for short/UInt16, "" for int/Int32, "l" for long/Int/Int64
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        var sha = ""
        digest.forEach({
            sha += String(format: fmt, $0)
        })
        #if DEBUG
        assert(digest.map({ String(format: fmt, $0) }).joined() == sha )
        #endif
        return sha

    }
}
