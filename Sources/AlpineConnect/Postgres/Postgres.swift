//
//  Postgres.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/9/23.
//

import Foundation


public extension Optional where Wrapped == UUID {
    
    func toPostgres() -> String {
        return self != nil ? "'\(self!.uuidString)'" : "NULL"
    }
}

public extension Optional where Wrapped == String {
    
    func geometryToPostgres() -> String {
        self != nil && self != "" ? "ST_AsText(ST_GeomFromText('\(self!)',26710))" : "NULL"
    }
    
    func toPostgres() -> String {
        self != nil && self != "" ? self! : "NULL"
    }
}

public extension Optional where Wrapped == NSNumber {
    
    func topPostgres() -> String {
        self != nil ? "\(self!)" : "NULL"
    }
}

public extension Optional where Wrapped == Date {
    
    func toPostgres() -> String {
        self != nil ? "'\(self!.toPostgresTimestamp())'" : "NULL"
    }
}

public extension Optional where Wrapped == Data {
    func toPostgres() -> String {
        self != nil ? "'\(self!)'" : "NULL"
    }
}

public extension Date {
    
    func toPostgresTimestamp() -> String {
        toStringTimeZonePST(dateFormat: "yyyy-MM-dd HH:mm:ss")
    }
    
    func toStringTimeZonePST(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return dateFormatter.string(from: self)
    }
}
