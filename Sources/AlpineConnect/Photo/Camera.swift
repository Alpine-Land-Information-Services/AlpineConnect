//
//  Camera.swift
//  Botany
//
//  Created by Jenya Lebid on 3/10/23.
//

import UIKit
import SwiftUI
import CoreData

public class Camera {
    
    public struct Photo: Identifiable {
        
        public var id: UUID
        public var date: Date
        public var image: UIImage
        
        public init(id: UUID, date: Date, image: UIImage) {
            self.id = id
            self.date = date
            self.image = image
        }
    }
    
    public static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    static func containerSize(image: UIImage) -> CGSize {
        let container = CGSize(width: 200, height: 200)
        let ratio = image.size.width / image.size.height
        
        let newWidth = container.height * ratio
        let newHeight = container.width / ratio
        return CGSize(width: newWidth <= container.width ? newWidth : container.width, height: newHeight <= container.height ? newHeight : container.height)
    }
}
