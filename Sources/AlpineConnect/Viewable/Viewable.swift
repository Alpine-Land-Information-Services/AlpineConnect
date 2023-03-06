//
//  Viewable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/6/23.
//

import Foundation

public protocol Viewable: Equatable {

    
    var parentView: ViewableSupport.ViewNav? {get}
}
