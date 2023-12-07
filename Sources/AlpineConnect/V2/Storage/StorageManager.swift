//
//  StorageManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation

@Observable
public class StorageManager {
    
    public static var shared = StorageManager()
    
    public let token = "OlTBTt1mKgZzYhKnC2ImFk3AQZp6jBA6m7m3pv2bJuqn5q0O4i5NtgGeFPMTHz8r?c=2023-12-07T22:01:28?e=2024-06-04T22:01:28"
    public var connections = [StorageConnection]()
}
