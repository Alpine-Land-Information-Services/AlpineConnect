//
//  PhotoButton.swift
//  Botany
//
//  Created by mkv on 5/17/22.
//


import SwiftUI

// TODO: Maybe add picking from library
struct PhotoButton: View {

    @State private var showCamera = false
    @Environment(PhotoViewModel.self) var viewModel

    var body: some View {
        Button {
            showCamera.toggle()
        } label: {
            Image(systemName: "camera")
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView()
                .environment(viewModel)
        }
    }
}
