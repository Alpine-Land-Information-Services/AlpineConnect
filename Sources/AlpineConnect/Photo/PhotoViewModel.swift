//
//  PhotoViewModel.swift
//  Botany
//
//  Created by Jenya Lebid on 3/13/23.
//

import Foundation

class PhotoViewModel: ObservableObject {
    
    var cameraVC = ImagePickerController()
    
    @Published var photos = [Camera.Photo]()
    @Published var showGallery = false
    
    @Published var takingPhoto = false
    @Published var gettingPhotos = true

    var object: PhotoObject
    
    init(object: PhotoObject) {
        self.object = object
        cameraVC.viewModel = self
    }
    
    func takePhoto() {
        takingPhoto = true
        cameraVC.takePicture()
    }
    
    func addPhoto(photo: Camera.Photo) {
        Task {
            await object.addPhoto(photo)
            photos.append(photo)
            DispatchQueue.main.async {
                self.takingPhoto = false
            }
        }
    }
    
    func reloadPhotos() {
        Task {
            gettingPhotos = true
            photos = await object.getPhotos()
            gettingPhotos = false
        }
    }
    
    func deletePhoto(_ photo: Camera.Photo) {
        object.deletePhoto(photo)
        photos.removeAll(where: {$0.id == photo.id})
    }
}
