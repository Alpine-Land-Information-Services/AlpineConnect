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
        let description = "\(error)"
        if description.contains("socketError") || description.contains("connectionClosed")
//            || (error as? AlpineError)?.message == "_test_connectionClosed_"
        {
//            Core.makeEvent("should show error to user", type: .sync)
            return false
        }
//        Core.makeEvent("should NOT show error to user", type: .sync)
        return isForeground
    }
    
    func shouldRepeat(onRepeat: () -> Void) -> Bool {
        if let error,
           "\(error)".contains("socketError") || "\(error)".contains("connectionClosed")
//            || (error as? AlpineError)?.message == "_test_connectionClosed_"
        {
            repeatAttempts -= 1
            if repeatAttempts > 0 {
                onRepeat()
//                Core.makeEvent("should attempt to repeat", type: .sync)
                return true
            }
        }
//        Core.makeEvent("should NOT attempt to repeat", type: .sync)
        return false
    }
}
