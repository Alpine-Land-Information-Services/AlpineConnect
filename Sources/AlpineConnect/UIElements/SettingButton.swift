//
//  SettingButton.swift
//  
//
//  Created by Vladislav on 7/18/24.
//

import SwiftUI
import AlpineUI
import AlpineCore

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
            SettingBlock(image: icon, color: .orange, title: title, eventTracker: Core.eventTracker, displayContent: {
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
