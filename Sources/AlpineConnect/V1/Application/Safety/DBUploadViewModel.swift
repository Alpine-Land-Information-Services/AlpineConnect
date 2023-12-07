//
//  DBUploadViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/26/23.
//

import Foundation

class DBUploadViewModel: ObservableObject {
    
    var container: DBRescue.ContainerInfo
    
    init(container: DBRescue.ContainerInfo) {
        self.container = container
    }
}
