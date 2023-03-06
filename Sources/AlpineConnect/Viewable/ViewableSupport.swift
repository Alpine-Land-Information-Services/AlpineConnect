//
//  File.swift
//  
//
//  Created by Jenya Lebid on 3/6/23.
//

import Foundation

public class ViewableSupport {
    
    public struct ViewNav {
        
        public  init(text: String, view: (any Viewable)?) {
            self.text = text
            self.view = view
        }
        
        public var text: String
        public var view: (any Viewable)?
    }
}
