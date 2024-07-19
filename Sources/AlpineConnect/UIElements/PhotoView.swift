//
//  PhotoView.swift
//  
//
//  Created by Vladislav on 7/18/24.
//

import SwiftUI

public struct PhotoView: View {
    
    @Environment(\.dismiss) var dismiss
    
    public var photo: UIImage
    
    public init(photo: UIImage) {
        self.photo = photo
    }
    
    public var body: some View {
        VStack {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
