//
//  PhotoButton.swift
//  Botany
//
//  Created by mkv on 5/17/22.
//


import SwiftUI

struct PhotoButton: View {

    @State private var showCamera = false
    @EnvironmentObject var viewModel: PhotoViewModel

    var body: some View {
        Button {
            showCamera.toggle()
        } label: {
            Image(systemName: "camera")
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView()
                .environmentObject(viewModel)
        }
    }
}


// TODO: Maybe add picking from library
//        VStack() {
//            Button {
//                self.showImagePickerOptions = true
//            } label: {
//                Image(systemName: "camera")
//            }
//            .confirmationDialog("Choose or Take a Photo", isPresented: $showImagePickerOptions) {
//                Button("Choose from Library") {
//
//                }
//                Button("Open Camera") {
//                    showCamera.toggle()
//                }
//            } message: {
//                Text("Choose or Take a Photo")
//            }
//            .fullScreenCover(isPresented: $showCamera) {
//                CameraView(object: object, newPhotos: $newPhotos)
//            }
//        }
