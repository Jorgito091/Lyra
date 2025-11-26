//
//  TimeFormatting.swift
//  Lyra
//
//  Utility for time formatting
//

import Foundation

extension TimeInterval {
    func formattedTime() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
