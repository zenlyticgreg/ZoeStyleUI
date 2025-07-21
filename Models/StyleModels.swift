import Foundation
import SwiftUI

enum StyleType: String, Codable, Hashable {
    case color, font, string, number, bool, borderRadius

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
    let lineNumber: Int? // Line number in the original JSON file
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: StyleKey, rhs: StyleKey) -> Bool {
        lhs.id == rhs.id
    }
}

struct StyleSubcomponent: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    var keys: [StyleKey]
    let comment: String?
    let startLineNumber: Int?
    let endLineNumber: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: StyleSubcomponent, rhs: StyleSubcomponent) -> Bool {
        lhs.id == rhs.id
    }
}

struct StyleComponent: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    var keys: [StyleKey] // Direct properties of the component
    var subcomponents: [StyleSubcomponent] // Nested subcomponents
    let comment: String?
    let startLineNumber: Int? // Starting line number of this component in the original JSON file
    let endLineNumber: Int? // Ending line number of this component in the original JSON file
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: StyleComponent, rhs: StyleComponent) -> Bool {
        lhs.id == rhs.id
    }
} 