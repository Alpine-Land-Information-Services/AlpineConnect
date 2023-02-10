//
//  Export.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/9/23.
//

import CoreData

public class Export {
    
    public enum Error: Swift.Error {
        case empty
        case invalidStatus
        case internalActionsFail
        case makingFieldQueries
        case unknown
        case error(_ error: Swift.Error)
    }
    
    static public func postgresExport(with query: String, in context: NSManagedObjectContext, result: @escaping (Result<Void, Export.Error>) -> ()) {
        NetworkManager.shared.pool?.withConnection { con_from_pool in
            context.performAndWait {
                do {
                    let connection = try con_from_pool.get()
                    defer { connection.close() }
                    print(query)
                    let statement = try connection.prepareStatement(text: query)
                    defer { statement.close() }
                    try statement.execute()
                    
                    result(.success(()))
                }
                catch {
                    result(.failure(.error(error)))
                }
            }
        }
    }
}
