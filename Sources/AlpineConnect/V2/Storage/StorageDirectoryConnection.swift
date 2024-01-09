//
//  StorageDirectoryConnection.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation

@Observable
public final class StorageDirectoryConnection: StorageConnection {
    
    var baseURLString: String {
        switch location {
        case .myFolder:
            return "https://alpine-storage.azurewebsites.net/"
        case .cloud:
            return "https://alpine-storage.azurewebsites.net/info/"
        default:
            fatalError()
        }
    }
        
    public func open(_ directory: String) async -> StorageItemKind? {
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
    
    private func fetchItems(in directory: String) async throws -> StorageItemKind? {
        guard let sessionToken else { return nil }
        
        guard let url = URL(string: baseURLString + directory + "?maxdepth=1") else {
            throw ConnectError("Could not create directory URL.", type: .storage)
        }
        print(url)
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
            return try await decodeErrorResponse(from: data, from: directory)
        default:
            throw ConnectError("Unregognized HTTP response code: \(httpResponse.statusCode)", type: .storage)
        }
    }
}

private extension StorageDirectoryConnection {
    
    func decodeSuccessfulResponse(from data: Data) async throws -> StorageItemKind {
        let item = try ConnectManager.decoder.decode(StorageItemKind.self, from: data)
        lastUpdate = Date()

        return item
    }
    
    func decodeErrorResponse(from data: Data, from directory: String) async throws -> StorageItemKind? {
        let problem = try ConnectManager.decoder.decode(ConnectionProblem.self, from: data)
        if problem.detail == "Session not authorized (Access token is disabled, a newer session exists)" {
            guard let info else { return nil }
            await getToken(with: info, attemptFetchNew: true)
            return try await fetchItems(in: directory)
        }
        else {
            presentAlert(from: problem)
            return nil
        }
    }
}
