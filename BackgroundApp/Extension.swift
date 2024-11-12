//
//  Extension.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/11.
//

import Foundation

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    let message = items.map { "\($0)" }.joined(separator: separator)
    Swift.print("[BackgroundApp][\(timestamp)] \(message)", terminator: terminator)
}

extension Data {
    func toHexString() -> String {
        return "0x" + self.map { String(format: "%02.2hhx", $0) }.joined(separator: "")
    }
}
