//
//  SyncError.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 8/14/23.
//

import Foundation

public enum SyncError: Error {
    case notSetAsReady(_ description: String)
}
