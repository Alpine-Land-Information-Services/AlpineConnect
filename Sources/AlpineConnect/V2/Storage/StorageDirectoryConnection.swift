//
//  StorageDirectoryConnection.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation

@Observable
public final class StorageDirectoryConnection: StorageConnection {
    
    public func open(_ directory: String) async -> [StorageItem]? {
        do {
            return try await fetchItems(in: directory)
        }
        catch {
            DispatchQueue.main.async { [self] in
                if let error = error as? ConnectError {
                    alert = ConnectAlert(title: "\(error.type.rawValue.capitalized) Error", message: error.message)
                    status = .issue(error.message)
                }
                else {
                    alert = ConnectAlert(title: "Something Went Wrong", message: "\(error)")
                    status = .issue("\(error)")
                }
                isAlertPresented.toggle()
            }
            return nil
        }
    }
    
    private func fetchItems(in directory: String) async throws -> [StorageItem]? {
        guard let sessionToken else { return nil }
        
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
            return try await decodeSuccessfulResponse(from: data)
        case 400...599:
            try await decodeErrorResponse(from: data)
            return nil
        default:
            throw ConnectError("Unregognized HTTP response code: \(httpResponse.statusCode)", type: .storage)
        }
    }
}

private extension StorageDirectoryConnection {
    
    func decodeSuccessfulResponse(from data: Data) async throws -> [StorageItem] {
        try ConnectManager.decoder.decode([StorageItem].self, from: data)
    }
    
    func decodeErrorResponse(from data: Data) async throws {
        let problem = try ConnectManager.decoder.decode(ConnectionProblem.self, from: data)
        presentAlert(from: problem)
    }
}
