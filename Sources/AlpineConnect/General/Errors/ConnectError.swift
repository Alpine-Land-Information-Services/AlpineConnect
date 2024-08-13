//
//  ConnectError.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation
import AlpineCore

public class ConnectError: AlpineError {
    
    var type: ConnectErrorType
    
    public init(_ message: String,
                type: ConnectErrorType,
                includedFile: [ExportType] = [],
                file: String = #file, function: String = #function, line: Int = #line) {
        self.type = type
        super.init(message, file: file, function: function, line: line, includedFile: includedFile)
    }
    
    public override func getType() -> String {
        "\(type.rawValue)"
    }
}
