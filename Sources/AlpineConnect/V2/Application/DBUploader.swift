//
//  DBUploader.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/15/24.
//

import SwiftUI
import Zip

import AlpineCore
import AlpineUI

@Observable
public class DBUploader {
    
    public enum Status: String {
        case none = ""
        case packing = "Packing..."
        case uploading = "Uploading..."
        case error = "Issue occurred."
        case success = "Container was successfully uploaded."
    }
    
    var status = Status.none
    var token: String
    
    init(token: String) {
        self.token = token
    }
    
    
    public func upload(containerPath: String) async {
        do {
            let path = containerPath.appending(".sqlite")
            let containerURL = FS.appSupportURL.appending(path: path)
            guard FS.fileExists(at: containerURL) else {
                throw ConnectError("Container does not exist at specified path: \(containerURL)", type: .upload)
            }
            setStatus(to: .packing)
            let zipURL = try Zip.quickZipFiles([containerURL], fileName: path)
            try await doUpload(from: zipURL, to: containerPath)
            try FileManager.default.removeItem(at: zipURL)
            resetStatus()
        }
        catch {
            setStatus(to: .error)
            Core.makeError(error: error)
            resetStatus()
        }
    }
    
    func doUpload(from url: URL, to path: String) async throws {
        guard let uploadURL = URL(string: "https://alpine-storage.azurewebsites.net")?.appending(path: "ios-data").appending(path: "DB Files/") else {
            throw ConnectError("Could not create upload URL.", type: .upload)
        }
        
        setStatus(to: .uploading)
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "ApiKey")
        request.addValue(url.lastPathComponent, forHTTPHeaderField: "A3-File-Name")
        
        let session = URLSession.shared
        let response = try await session.upload(for: request, fromFile: url)
        
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw ConnectError("Invalid upload response.", type: .upload)
        }
        
//        let data = try JSONDecoder().decode(String.self, from: response.0)
//        print(data)
        
        switch httpResponse.statusCode {
        case 200...299:
            setStatus(to: .success)
        case 400...599:
            throw ConnectError("Something went wrong, HTTP response code: \(httpResponse.statusCode)", type: .upload)
        default:
            throw ConnectError("Unregognized HTTP response code: \(httpResponse.statusCode)", type: .login)
        }
    }
    
    func setStatus(to status: Status) {
        DispatchQueue.main.async {
            withAnimation {
                self.status = status
            }
        }
    }
    
    func resetStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.status = .none
            }
        }
    }
}

public extension DBUploader {
    
    struct SettingButton: View {
        
        @State private var uploader: DBUploader
        var containerPath: String
        
        public init(containerPath: String, token: String) {
            self.containerPath = containerPath
            _uploader = State(wrappedValue: DBUploader(token: token))
        }
        
        public var body: some View {
            SettingBlock(image: "square.and.arrow.up.on.square", color: .orange, title: "Upload Local Database", displayContent: {
                switch uploader.status {
                case .packing, .uploading:
                    HStack {
                        ProgressView()
                            .padding(.trailing)
                        Text(uploader.status.rawValue)
                    }
                default:
                    Text(uploader.status.rawValue)
                }
            }, action: {
                guard uploader.status == .none else { return }
                let proceedButton = CoreAlertButton(title: "Proceed", style: .destructive) {
                    Task {
                        await uploader.upload(containerPath: containerPath)
                    }
                }
                let alert = CoreAlert(title: "Upload Database?", message: "This will upload a copy of your local database for debugging.\n\nPlease only do so if requested.\n\nThe process may take a while, do not leave this page while upload is in process.", buttons: [.cancel,  proceedButton])
    
                Core.makeAlert(alert)
            })
        }
    }
}
