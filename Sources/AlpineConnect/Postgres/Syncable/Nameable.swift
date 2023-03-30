//
//  Nameable.swift
//  AlpineConnect
//  
//  Created by mkv on 3/27/23.
//


public protocol Nameable {
    
    static var entityName: String { get }
    static var entityDisplayName: String { get }
    
    var entityName: String { get }
    var entityDisplayName: String { get }
}

public extension Nameable {
    
    static var entityName: String {
        String(describing: Self.self)
    }
    
    static var entityDisplayName: String {
        var res = entityName
        //TODO: use regexp
        if res.hasSuffix("_V1") {
            res = res.replacingOccurrences(of: "_V1", with: "")
        }
        return res
    }
    
    var entityName: String {
        Self.entityName
    }
    
    var entityDisplayName: String {
        Self.entityDisplayName
    }
}
