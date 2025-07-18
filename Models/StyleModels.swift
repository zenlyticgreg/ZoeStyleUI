import Foundation
import SwiftUI

enum StyleType: String, Codable, Hashable {
    case color, font, string, number, bool

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try? container.decode(String.self)
        self = StyleType(rawValue: raw ?? "") ?? .string
    }
}

struct StyleKey: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    let type: StyleType
    var value: String
    let comment: String?
}

struct StyleComponent: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    var keys: [StyleKey]
    let comment: String?
} 