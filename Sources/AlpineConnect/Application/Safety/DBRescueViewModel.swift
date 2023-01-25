//
//  DBRescueViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/23.
//

import Foundation

class DBRescueViewModel: ObservableObject {
 
    static var shared = DBRescueViewModel()
    
    @Published var isShown = false
    @Published var failedDB = [DBResucue.ContainerInfo]()
}
