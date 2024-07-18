//
//  SyncErrorsResolver.swift
//  AlpineConnect
//
//  Created by mkv on 4/11/24.
//

import AlpineCore

/// A resolver class for handling synchronization errors and determining retry logic.
///
/// `SyncErrorsResolver` is responsible for tracking error occurrences during synchronization
/// and deciding whether to retry the synchronization process or display an error message to the user.
class SyncErrorsResolver {
    
    /// The number of remaining retry attempts.
    private var repeatAttempts: Int
    
    /// The error that occurred during synchronization.
    private var error: Error?
    
    /// Initializes a new instance of `SyncErrorsResolver`.
    ///
    /// - Parameter repeatAttempts: The number of retry attempts. Default is 3.
    init(repeatAttempts: Int = 3) {
        self.repeatAttempts = repeatAttempts
    }
    
    /// Sets the error that occurred during synchronization.
    ///
    /// - Parameter error: The error to set.
    func setError(_ error: Error) {
        self.error = error
    }
    
    /// Determines whether the error should be shown to the user.
    ///
    /// - Parameter isForeground: A boolean indicating whether the app is in the foreground.
    /// - Returns: A boolean indicating whether the error should be shown to the user.
    func shouldShowToUser(_ isForeground: Bool) -> Bool {
        guard let error, repeatAttempts > 1 else { return isForeground }
        let description = "\(error)"
        if description.contains("socketError") || description.contains("connectionClosed") {
            return false
        }
        return isForeground
    }
    
    /// Determines whether the synchronization should be retried.
    ///
    /// - Parameter onRepeat: A closure to execute if a retry is attempted.
    /// - Returns: A boolean indicating whether the synchronization should be retried.
    func shouldRepeat(onRepeat: () -> Void) -> Bool {
        if let error, "\(error)".contains("socketError") || "\(error)".contains("connectionClosed") {
            repeatAttempts -= 1
            if repeatAttempts > 0 {
                onRepeat()
                return true
            }
        }
        return false
    }
}
