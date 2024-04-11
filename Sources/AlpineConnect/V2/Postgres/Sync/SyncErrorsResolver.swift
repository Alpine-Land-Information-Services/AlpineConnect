//
//  SyncErrorsResolver.swift
//  
//
//  Created by mkv on 4/11/24.
//

import AlpineCore

class SyncErrorsResolver {
    
    var repeatAttempts = 2
    var error: Error?
    
    init(repeatAttempts: Int = 2) {
        self.repeatAttempts = repeatAttempts
    }
    
    func shouldShowToUser(_ isForeground: Bool) -> Bool{
        if let error, 
            (error.localizedDescription.contains("socketError(cause:") 
             || error.localizedDescription.contains("connectionClosed")
//             || (error as? AlpineError)?.message == "connectionClosed"
            ) 
        {
            return false
        }
        return isForeground
    }
    
    func shouldRepeat() -> Bool {
        repeatAttempts -= 1
        return repeatAttempts > 0
    }
}
