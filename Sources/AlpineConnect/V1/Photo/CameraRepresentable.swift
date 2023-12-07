//
//  CameraRepresentable.swift
//  Botany
//
//  Created by Jenya Lebid on 3/10/23.
//

import SwiftUI

struct CameraRepresentable: UIViewControllerRepresentable {
    
    @ObservedObject var viewModel: PhotoViewModel
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        viewModel.cameraVC
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
}
