import Foundation
import SwiftUI

class StyleEditorViewModel: ObservableObject {
    @Published var components: [StyleComponent] = []
    @Published var selectedComponent: StyleComponent?
    @Published var previewMode: PreviewMode = .light
    @Published var changedTokens: Set<String> = []
    
    private var tokenPalette: [String: Any] = [:]
    
    init() {
        print("StyleEditorViewModel: Initializing...")
        loadTokenPalette()
        loadSampleData()
        loadSampleTokens()
        print("StyleEditorViewModel: Initialization complete")
    }
    
    private func loadTokenPalette() {
        print("StyleEditorViewModel: Attempting to load token palette...")
        
        // Check if the file exists in the bundle
        if let url = Bundle.main.url(forResource: "token_palette", withExtension: "json") {
            print("StyleEditorViewModel: Found token_palette.json at: \(url)")
            
            do {
                let data = try Data(contentsOf: url)
                print("StyleEditorViewModel: Successfully read \(data.count) bytes from token_palette.json")
                
                if let palette = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    self.tokenPalette = palette
                    print("StyleEditorViewModel: Token palette loaded successfully with \(palette.count) top-level keys")
                } else {
                    print("StyleEditorViewModel: Failed to parse token_palette.json as dictionary")
                    loadFallbackTokenPalette()
                }
            } catch {
                print("StyleEditorViewModel: Error reading token_palette.json: \(error)")
                loadFallbackTokenPalette()
            }
        } else {
            print("StyleEditorViewModel: token_palette.json not found in bundle")
            print("StyleEditorViewModel: Available resources in bundle:")
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    for file in files.sorted() {
                        print("StyleEditorViewModel:   - \(file)")
                    }
                } catch {
                    print("StyleEditorViewModel: Error listing bundle contents: \(error)")
                }
            }
            loadFallbackTokenPalette()
        }
    }
    
    private func loadFallbackTokenPalette() {
        // Fallback token palette with basic colors
        tokenPalette = [
            "colors": [
                "background": [
                    "base": [
                        "level000": "#FFFFFF",
                        "level020": "#F8F9FA",
                        "level040": "#F1F3F4",
                        "level060": "#E8EAED",
                        "level080": "#DADCE0",
                        "level100": "#BDC1C6"
                    ],
                    "brand": [
                        "primary": [
                            "normal": "#1A73E8",
                            "hover": "#1557B0",
                            "active": "#174EA6"
                        ]
                    ]
                ],
                "text": [
                    "base": [
                        "level800": "#202124",
                        "level600": "#5F6368",
                        "level400": "#9AA0A6"
                    ]
                ]
            ]
        ]
    }
    
    private func loadSampleData() {
        if let url = Bundle.main.url(forResource: "interface_styles", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let decoder = JSONDecoder()
                let loadedComponents = try decoder.decode([StyleComponent].self, from: data)
                self.components = loadedComponents
                print("StyleEditorViewModel: Loaded \(loadedComponents.count) components from interface_styles.json")
            } catch {
                print("StyleEditorViewModel: Failed to decode interface_styles.json: \(error)")
                loadFallbackData()
            }
        } else {
            print("StyleEditorViewModel: interface_styles.json not found, using fallback data")
            loadFallbackData()
        }
    }
    
    private func loadFallbackData() {
        // Fallback sample data
        components = [
            StyleComponent(
                id: "chatbox",
                label: "Chatbox",
                keys: [
                    StyleKey(id: "background_color", label: "Background Color", type: .color, value: "background.base.level000", comment: "Main background color"),
                    StyleKey(id: "text_color", label: "Text Color", type: .color, value: "text.base.level800", comment: "Primary text color")
                ],
                comment: "Chat input box styling"
            ),
            StyleComponent(
                id: "avatar",
                label: "Avatar",
                keys: [
                    StyleKey(id: "background_color", label: "Background Color", type: .color, value: "background.brand.primary.normal", comment: "Avatar background"),
                    StyleKey(id: "text_color", label: "Text Color", type: .color, value: "#FFFFFF", comment: "Avatar text color")
                ],
                comment: "User avatar styling"
            )
        ]
    }
    
    private func loadSampleTokens() {
        // This method is no longer needed as we're using the real JSON data
        print("StyleEditorViewModel: Sample tokens loading skipped - using real data")
    }
    
    func selectComponent(_ component: StyleComponent) {
        selectedComponent = component
        print("StyleEditorViewModel: Selected component: \(component.label)")
    }
    
    func updateStyleValue(keyId: String, newValue: String) {
        guard let componentIndex = components.firstIndex(where: { $0.id == selectedComponent?.id }),
              let keyIndex = components[componentIndex].keys.firstIndex(where: { $0.id == keyId }) else {
            return
        }
        
        components[componentIndex].keys[keyIndex].value = newValue
        changedTokens.insert(keyId)
        
        // Update selected component reference
        selectedComponent = components[componentIndex]
        
        print("StyleEditorViewModel: Updated \(keyId) to \(newValue)")
    }
    
    func getResolvedValue(for keyId: String) -> String? {
        guard let component = selectedComponent,
              let key = component.keys.first(where: { $0.id == keyId }) else {
            return nil
        }
        
        // If it's already a hex color, return it
        if key.value.hasPrefix("#") {
            return key.value
        }
        
        // Try to resolve semantic token
        return resolveSemanticToken(key.value)
    }
    
    private func resolveSemanticToken(_ token: String) -> String? {
        let components = token.components(separatedBy: ".")
        var current: Any = tokenPalette
        
        for component in components {
            if let dict = current as? [String: Any],
               let value = dict[component] {
                current = value
            } else {
                return nil
            }
        }
        
        return current as? String
    }
    
    func snippetForSelectedComponent() -> String {
        guard let component = selectedComponent else { return "" }
        
        var snippet = "{\n"
        snippet += "  \"id\": \"\(component.id)\",\n"
        snippet += "  \"label\": \"\(component.label)\",\n"
        snippet += "  \"keys\": [\n"
        
        for (index, key) in component.keys.enumerated() {
            snippet += "    {\n"
            snippet += "      \"id\": \"\(key.id)\",\n"
            snippet += "      \"label\": \"\(key.label)\",\n"
            snippet += "      \"type\": \"\(key.type.rawValue)\",\n"
            snippet += "      \"value\": \"\(key.value)\""
            
            if let comment = key.comment {
                snippet += ",\n      \"comment\": \"\(comment)\""
            }
            
            snippet += "\n    }"
            if index < component.keys.count - 1 {
                snippet += ","
            }
            snippet += "\n"
        }
        
        snippet += "  ]"
        
        if let comment = component.comment {
            snippet += ",\n  \"comment\": \"\(comment)\""
        }
        
        snippet += "\n}"
        return snippet
    }
    
    func snippetForChangedTokens() -> String {
        guard !changedTokens.isEmpty else { return "" }
        
        var snippet = "{\n"
        snippet += "  \"updated_tokens\": {\n"
        
        for (index, tokenId) in changedTokens.enumerated() {
            if let component = selectedComponent,
               let key = component.keys.first(where: { $0.id == tokenId }) {
                snippet += "    \"\(tokenId)\": \"\(key.value)\""
                if index < changedTokens.count - 1 {
                    snippet += ","
                }
                snippet += "\n"
            }
        }
        
        snippet += "  }\n"
        snippet += "}"
        return snippet
    }
}

enum PreviewMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
} 