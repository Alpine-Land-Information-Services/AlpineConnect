//
//  SyncErrorsResolver.swift
//  AlpineConnect
//
//  Created by mkv on 4/11/24.
//

import AlpineCore

class SyncErrorsResolver {
    
    var repeatAttempts: Int
    var error: Error?
    
    init(repeatAttempts: Int = 3) {
        self.repeatAttempts = repeatAttempts
    }
    
    func shouldShowToUser(_ isForeground: Bool) -> Bool {
        guard let error, repeatAttempts > 1 else { return isForeground }
        let description = error.localizedDescription
        if description.contains("socketError") || description.contains("connectionClosed")
//            || (error as? AlpineError)?.message == "_test_connectionClosed_"
        {
            return false
        }
        
        return isForeground
    }
    
    func shouldRepeat(onRepeat: () -> Void) -> Bool {
        if let error,
           error.localizedDescription.contains("socketError") || error.localizedDescription.contains("connectionClosed")
//            || (error as? AlpineError)?.message == "_test_connectionClosed_"
        {
            repeatAttempts -= 1
            if repeatAttempts > 0 {
                onRepeat()
                return true
            }
        }
        return false
    }
}
