//
//  ColoredLogPrint.swift
//  AlpineConnect
//
//  Created by mkv on 10/16/23.
//

import Foundation

public enum LogColorCode: String {
    case empty = ""
    case red = "🟥"
    case green = "🟩"
    case blue = "🟦"
    case yellow = "🟨"
    case orange = "🟧"
    case purple = "🟪"
    case gray = "⬜️"
    case eye = "👁"
    case flagR = "📕"
    case flagG = "📗"
    case flagB = "📘"
    case flagO = "📙"
    case warning = "⚠️"
    case error = "🛑"
    case info = "ℹ️"
    case circleR = "🔴"
    case circleY = "🟡"
    case circleG = "🟢"
    case circleB = "🔵"
}

public func print(code: LogColorCode, _ message: Any) {
    if code == .empty {
        print(message)
        return
    }
    print(code.rawValue, message)
}
