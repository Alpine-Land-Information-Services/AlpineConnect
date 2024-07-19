//
//  ImagePickerController.swift
//  Botany
//
//  Created by Jenya Lebid on 3/10/23.
//

import UIKit

class ImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var viewModel: PhotoViewModel?
    
    override func viewDidLoad() {
        sourceType = .camera
        showsCameraControls = false
        delegate.self = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let photo = info[.originalImage] as? UIImage else { return }
        let croppedImage = Camera.resizeImage(image: photo, targetSize: CGSize(width: 1920, height: 1080))
        
        viewModel?.addPhoto(photo: Camera.Photo(id: UUID(), date: Date(), image: croppedImage))
    }
}
