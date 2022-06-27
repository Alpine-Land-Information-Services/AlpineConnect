//
//  Image.swift
//  
//
//  Created by Jenya Lebid on 6/23/22.
//

import SwiftUI

extension Image {
    
    init(packageResource name: String, ofType type: String) {
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(uiImage: image)
    }
}

