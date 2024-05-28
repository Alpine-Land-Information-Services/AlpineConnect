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
    
    public enum ContainerType {
        case filesystem
        case appData
    }
    
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
    
    
    public func upload(containerPath: String, containerType: ContainerType) async {
        do {
            let containerURL = getURL(path: containerPath, in: containerType)
            guard FS.fileExists(at: containerURL) else {
                throw ConnectError("Container does not exist at specified path: \(containerURL)", type: .upload)
            }
            setStatus(to: .packing)
            let zipURL = try Zip.quickZipFiles([containerURL], fileName: containerPath)
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
    
    private func getURL(path: String, in container: ContainerType) -> URL {
        switch container {
        case .filesystem:
            return FS.atlasGroupURL.appending(component: "Library").appending(component: "Application Support").appending(component: path)
        case .appData:
            return FS.appSupportURL.appending(path: path)
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
        
        var icon: String
        var title: String
        var containerType: ContainerType
        
        public init(containerPath: String, storageToken: String, icon: String, title: String, containerType: ContainerType) {
            self.containerPath = containerPath
            self.icon = icon
            self.title = title
            self.containerType = containerType
            _uploader = State(wrappedValue: DBUploader(token: storageToken))
        }
        
        public var body: some View {
            SettingBlock(image: icon, color: .orange, title: title, displayContent: {
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
                        await uploader.upload(containerPath: containerPath, containerType: containerType)
                    }
                }
                let alert = CoreAlert(title: "Upload Container?", message: "This will upload a copy of this container for debugging.\n\nPlease only do so if requested.\n\nThe process may take a while, do not leave this page while upload is in process.", buttons: [.cancel,  proceedButton])
    
                Core.makeAlert(alert)
            })
        }
    }
}
