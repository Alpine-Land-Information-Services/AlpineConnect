//
//  GitReport.swift
//  AlpineConnect
//
//  Created by mkv on 5/1/23.
//

import Foundation

struct gitError: Error {
    var message: String
}

class GitReport {
    private let apiEndpoint: String = "https://api.github.com"
    
    func sendReport(owner: String,
                    repository: String,
                    token: String,
                    title: String,
                    message: String,
                    name: String,
                    email: String,
                    bug: Bool,
                    completion: @escaping (Result<[String: AnyObject], gitError>) -> Void)
    {
        let accessToken = token.data(using: .utf8)!.base64EncodedString()
        let path = "repos/\(owner)/\(repository)/issues"
        let url = URL(string: path, relativeTo: URL(string: apiEndpoint)!)
        guard url != nil else { return completion(.failure(gitError(message: "URL is not valid")))}
        
        var request = URLRequest(url: url!)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "accept")
        request.addValue("Basic \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let appVersion = getAppVersion()
        let params: [String: Any] = ["title": name + ", " + email + ", " + title,
                                     "body": (appVersion != nil ? "(v\(appVersion!)) " : "") + (bug ? "IS REPEATABLE. " : "") + message]
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        } catch {
            return completion(.failure(gitError(message: error.localizedDescription)))
        }
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            guard error == nil else { return completion(.failure(gitError(message: error!.localizedDescription))) }
            guard data != nil else { return completion(.failure(gitError(message: "Data is empty"))) }
            
            if let error = error {
                completion(.failure(gitError(message: error.localizedDescription)))
            } else {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                        if json["number"] != nil {
                            completion(.success(json))
                        } else {
                            completion(.failure(gitError(message: json["message"] as? String ?? "Unknown")))
                        }
                    } catch {
                        completion(.failure(gitError(message: error.localizedDescription)))
                    }
                }
            }
        }
        task.resume()
    }
    
    func getAppVersion() -> String? {
        return Tracker.appFullVersion()
//        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else { return nil }
//        let plist = NSDictionary(contentsOfFile: filePath)
//        guard let value = plist?.object(forKey: "CFBundleShortVersionString") as? String else { return nil }
//        return value
    }
}
