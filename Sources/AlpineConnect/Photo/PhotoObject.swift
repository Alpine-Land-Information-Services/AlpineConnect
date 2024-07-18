//
//  PhotoObject.swift
//  
//
//  Created by Vladislav on 7/18/24.
//

import Foundation
import SwiftUI
import CoreData

public protocol PhotoObject {
    
    static var photoFetchContext: NSManagedObjectContext { get }
    
    var name: String { get }
    var photoFetchPredicate: NSPredicate { get }
    
    func getPhotos() async -> [Camera.Photo]
    func addPhoto(_ : Camera.Photo) async
    func deletePhoto(_ photo: Camera.Photo)
    func assignPhoto(_ photo: NSManagedObject)
}
