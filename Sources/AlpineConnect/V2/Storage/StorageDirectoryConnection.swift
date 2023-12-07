//
//  StorageDirectoryConnection.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation

@Observable
public final class StorageDirectoryConnection: StorageConnection {
    
    public func open(_ directory: String) async throws {
        guard let url = URL(string: "https://alpine-storage.azurewebsites.net/\(directory)") else {
            throw ConnectError("Could not create directory URL.", type: .storage)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(manager.token, forHTTPHeaderField: "ApiKey")
        request.addValue(sessionToken.rawValue, forHTTPHeaderField: "SessionToken")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConnectError("Could not get HTTP response back.", type: .storage)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            try await decodeSuccessfulResponse(from: data)
        case 400...599:
            try await decodeErrorResponse(from: data)
        default:
            throw ConnectError("Unregognized HTTP response code: \(httpResponse.statusCode)", type: .storage)
        }
    }
}

private extension StorageDirectoryConnection {
    
    func decodeSuccessfulResponse(from data: Data) async throws {
        let items = try ConnectManager.decoder.decode([StorageItem].self, from: data)
        DispatchQueue.main.async {
            self.items = items
        }
    }
    
    func decodeErrorResponse(from data: Data) async throws {
        let problem = try ConnectManager.decoder.decode(ConnectionProblem.self, from: data)
        presentAlert(from: problem)
    }
}
