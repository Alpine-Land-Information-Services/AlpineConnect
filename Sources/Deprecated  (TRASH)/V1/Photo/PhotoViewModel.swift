//
//  PhotoViewModel.swift
//  Botany
//
//  Created by Jenya Lebid on 3/13/23.
//

import Foundation

class PhotoViewModel: ObservableObject {
    
    @Published var photos = [Camera.Photo]()
    @Published var showGallery = false
    
    @Published var takingPhoto = false
    @Published var gettingPhotos = true
    
    var object: PhotoObject
    
    lazy var cameraVC: ImagePickerController = {
        let controller = ImagePickerController()
        controller.viewModel = self
        return controller
    }()
    
    init(object: PhotoObject) {
        self.object = object
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
