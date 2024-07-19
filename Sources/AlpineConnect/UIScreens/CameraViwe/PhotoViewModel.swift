//
//  PhotoViewModel.swift
//  Botany
//
//  Created by Jenya Lebid on 3/13/23.
//

import Foundation

@Observable
class PhotoViewModel {
    
    var photos = [Camera.Photo]()
    var showGallery: Bool = false
    var takingPhoto: Bool = false
    var gettingPhotos: Bool = true
    
    var object: PhotoObject

    var cameraVC: ImagePickerController
    
    init(object: PhotoObject) {
        self.object = object
        self.cameraVC = ImagePickerController()
        self.cameraVC.viewModel = self
    }
    
    func takePhoto() {
        takingPhoto = true
        cameraVC.takePicture()
    }
    
    func addPhoto(photo: Camera.Photo) {
        Task {
            await object.addPhoto(photo)
            DispatchQueue.main.async {
                self.photos.append(photo)
                self.takingPhoto = false
            }
        }
    }
    
    func loadPhotos() {
        guard photos.isEmpty else { return }
        gettingPhotos = true
        Task {
            let photos = await object.getPhotos()
            DispatchQueue.main.async {
                self.photos = photos
                self.gettingPhotos = false
            }
        }
    }
    
    func deletePhoto(_ photo: Camera.Photo) {
        object.deletePhoto(photo)
        photos.removeAll(where: {$0.id == photo.id})
    }
    
    func clearMemory() {
        DispatchQueue.main.async {
            self.photos = []
        }
    }
}
