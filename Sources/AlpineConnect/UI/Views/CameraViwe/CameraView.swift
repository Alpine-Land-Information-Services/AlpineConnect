//
//  CameraView.swift
//  Botany
//
//  Created by Jenya Lebid on 3/10/23.
//

import SwiftUI

public struct CameraView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(PhotoViewModel.self) var viewModel
        
    public var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack(alignment: .trailing) {
            CameraRepresentable(viewModel: viewModel)
            VStack {
                backButton
                Spacer()
                photoButton
                Spacer()
                galleryButton
            }
            .padding()
        }
    }
    
    @ViewBuilder
    public var photoButton: some View {
        @Bindable var viewModel = viewModel
        
        Button {
            viewModel.takePhoto()
        } label: {
            ZStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)
            }
            .overlay {
                if viewModel.takingPhoto {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
        .disabled(viewModel.takingPhoto)
    }
    
    @ViewBuilder
    var galleryButton: some View {
        @Bindable var viewModel = viewModel
        
        Button {
            self.viewModel.showGallery.toggle()
        } label: {
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 50, maxHeight: 50)
        }
        .disabled(self.viewModel.takingPhoto)
        .sheet(isPresented: $viewModel.showGallery) {
            PhotoCollectionView(interior: true)
        }
    }
    
    var backButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor.opacity(0.75))
                .cornerRadius(10)
        }
        .disabled(viewModel.takingPhoto)
    }
}
