import Foundation
import SwiftUI

class StyleEditorViewModel: ObservableObject {
    @Published var components: [StyleComponent] = []
    @Published var selectedComponent: StyleComponent?
    @Published var selectedSubcomponent: StyleSubcomponent?
    @Published var previewMode: PreviewMode = .light
    @Published var changedTokens: Set<String> = []
    @Published var currentSnippet: String = ""
    
    private var tokenPalette: [String: Any] = [:]
    private var originalComponents: [StyleComponent] = [] // Store original values
    
    init() {
        print("StyleEditorViewModel: Initializing...")
        loadTokenPalette()
        loadComponentsFromZoeJSON()
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
    
    private func loadComponentsFromZoeJSON() {
        print("StyleEditorViewModel: Loading components from Zoe JSON file...")
        
        // Try to load the actual Zoe JSON file
        if let url = Bundle.main.url(forResource: "json_orig", withExtension: "json") {
            print("StyleEditorViewModel: Found json_orig.json at: \(url)")
            do {
                let data = try Data(contentsOf: url)
                print("StyleEditorViewModel: Successfully read \(data.count) bytes from json_orig.json")
                
                // Print first 500 characters to verify content
                if let jsonString = String(data: data, encoding: .utf8) {
                    let preview = String(jsonString.prefix(500))
                    print("StyleEditorViewModel: JSON preview: \(preview)...")
                }
                
                let components = try parseZoeJSONComponents(data: data)
                self.components = components
                self.originalComponents = components
                print("StyleEditorViewModel: Successfully loaded \(components.count) components from Zoe JSON")
                print("StyleEditorViewModel: Component IDs: \(components.map { $0.id })")
            } catch {
                print("StyleEditorViewModel: Error loading Zoe JSON: \(error)")
                print("StyleEditorViewModel: Error details: \(error.localizedDescription)")
                loadFallbackData()
            }
        } else {
            print("StyleEditorViewModel: Zoe JSON file not found, using fallback data")
            print("StyleEditorViewModel: Available resources in bundle:")
            if let resources = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) {
                for resource in resources {
                    print("StyleEditorViewModel: - \(resource.lastPathComponent)")
                }
            }
            loadFallbackData()
        }
    }
    
    private func parseZoeJSONComponents(data: Data) throws -> [StyleComponent] {
        print("StyleEditorViewModel: Parsing Zoe JSON components...")
        
        // Parse the JSON as a dictionary
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let json = json else {
            throw NSError(domain: "JSONParsing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
        }
        
        print("StyleEditorViewModel: JSON root keys: \(json.keys.sorted())")
        
        var components: [StyleComponent] = []
        
        // Extract components from the root level
        for (componentId, componentData) in json {
            // Skip semantic_tokens as it's confusing for users - they should edit actual colors in components
            if componentId == "semantic_tokens" {
                print("StyleEditorViewModel: Skipping semantic_tokens component (not user-friendly)")
                continue
            }
            
            print("StyleEditorViewModel: Processing component: \(componentId)")
            if let componentDict = componentData as? [String: Any] {
                print("StyleEditorViewModel: Component \(componentId) has \(componentDict.count) keys")
                let (keys, subcomponents) = parseComponentWithHierarchy(componentDict, componentId: componentId)
                let component = StyleComponent(
                    id: componentId,
                    label: componentId.replacingOccurrences(of: "_", with: " ").capitalized,
                    keys: keys,
                    subcomponents: subcomponents,
                    comment: "Component from Zoe JSON",
                    startLineNumber: getComponentStartLine(componentId),
                    endLineNumber: getComponentEndLine(componentId)
                )
                components.append(component)
                print("StyleEditorViewModel: Added component \(componentId) with \(keys.count) direct keys and \(subcomponents.count) subcomponents")
            } else {
                print("StyleEditorViewModel: Component \(componentId) is not a dictionary, skipping")
            }
        }
        
        print("StyleEditorViewModel: Extracted \(components.count) components from Zoe JSON")
        return components
    }
    
    private func extractKeysFromComponent(_ componentDict: [String: Any], componentId: String, parentPath: String = "") -> [StyleKey] {
        var keys: [StyleKey] = []
        
        for (keyId, value) in componentDict {
            let fullKeyId = parentPath.isEmpty ? keyId : "\(parentPath).\(keyId)"
            
            if let nestedDict = value as? [String: Any] {
                // Recursively extract keys from nested objects
                let nestedKeys = extractKeysFromComponent(nestedDict, componentId: componentId, parentPath: fullKeyId)
                keys.append(contentsOf: nestedKeys)
            } else {
                // Handle primitive values
                let stringValue = String(describing: value)
                
                // Skip properties that shouldn't be editable in a style editor
                if shouldSkipProperty(keyId: keyId, value: stringValue, parentPath: parentPath) {
                    continue
                }
                
                let keyType: StyleType
                
                // Check if this is a color-related key by name
                let isColorKey = keyId.contains("color") || keyId.contains("background") || keyId.contains("border")
                
                if stringValue.hasPrefix("#") || isColorKey {
                    keyType = .color
                } else if stringValue == "true" || stringValue == "false" {
                    keyType = .bool
                } else if let _ = Int(stringValue) {
                    keyType = .number
                } else {
                    keyType = .string
                }
                
                let key = StyleKey(
                    id: fullKeyId,
                    label: createUserFriendlyLabel(keyId: keyId, value: stringValue),
                    type: keyType,
                    value: stringValue,
                    comment: createHelpfulComment(keyId: keyId, value: stringValue),
                    lineNumber: getKeyLineNumber(for: componentId, keyId: fullKeyId)
                )
                keys.append(key)
            }
        }
        
        return keys
    }
    
    private func parseComponentWithHierarchy(_ componentDict: [String: Any], componentId: String) -> (keys: [StyleKey], subcomponents: [StyleSubcomponent]) {
        var directKeys: [StyleKey] = []
        var subcomponents: [StyleSubcomponent] = []
        
        for (keyId, value) in componentDict {
            if let nestedDict = value as? [String: Any] {
                // Check if this nested object should be a subcomponent or just nested properties
                if shouldBeSubcomponent(keyId: keyId, nestedDict: nestedDict) {
                    // Create a subcomponent
                    let subcomponentKeys = extractKeysFromComponent(nestedDict, componentId: componentId, parentPath: keyId)
                    let subcomponent = StyleSubcomponent(
                        id: keyId,
                        label: createUserFriendlyLabel(keyId: keyId, value: ""),
                        keys: subcomponentKeys,
                        comment: createHelpfulComment(keyId: keyId, value: ""),
                        startLineNumber: getSubcomponentStartLine(componentId: componentId, subcomponentId: keyId),
                        endLineNumber: getSubcomponentEndLine(componentId: componentId, subcomponentId: keyId)
                    )
                    subcomponents.append(subcomponent)
                } else {
                    // Extract as nested keys
                    let nestedKeys = extractKeysFromComponent(nestedDict, componentId: componentId, parentPath: keyId)
                    directKeys.append(contentsOf: nestedKeys)
                }
            } else {
                // Handle primitive values
                let stringValue = String(describing: value)
                
                // Skip properties that shouldn't be editable in a style editor
                if shouldSkipProperty(keyId: keyId, value: stringValue, parentPath: "") {
                    continue
                }
                
                let keyType: StyleType
                
                // Check if this is a color-related key by name
                let isColorKey = keyId.contains("color") || keyId.contains("background") || keyId.contains("border")
                
                if stringValue.hasPrefix("#") || isColorKey {
                    keyType = .color
                } else if stringValue == "true" || stringValue == "false" {
                    keyType = .bool
                } else if let _ = Int(stringValue) {
                    keyType = .number
                } else {
                    keyType = .string
                }
                
                let key = StyleKey(
                    id: keyId,
                    label: createUserFriendlyLabel(keyId: keyId, value: stringValue),
                    type: keyType,
                    value: stringValue,
                    comment: createHelpfulComment(keyId: keyId, value: stringValue),
                    lineNumber: getKeyLineNumber(for: componentId, keyId: keyId)
                )
                directKeys.append(key)
            }
        }
        
        return (keys: directKeys, subcomponents: subcomponents)
    }
    
    private func shouldBeSubcomponent(keyId: String, nestedDict: [String: Any]) -> Bool {
        // Check if this nested object represents a logical subcomponent
        // Look for common subcomponent patterns in the JSON structure
        
        // Skip certain keys that should always be nested properties
        let skipSubcomponentKeys = ["__comment", "hover", "active", "disabled", "focused", "selected", "normal"]
        if skipSubcomponentKeys.contains(keyId) {
            return false
        }
        
        // Check if the nested dict contains style properties (indicating it's a subcomponent)
        let stylePropertyPatterns = ["color", "background", "border", "font", "padding", "margin", "width", "height"]
        let hasStyleProperties = nestedDict.keys.contains { key in
            stylePropertyPatterns.contains { pattern in
                key.lowercased().contains(pattern)
            }
        }
        
        // If it has style properties and isn't a state modifier, it's likely a subcomponent
        return hasStyleProperties
    }
    
    private func shouldSkipProperty(keyId: String, value: String, parentPath: String) -> Bool {
        // Skip null values
        if value == "nil" || value == "null" {
            return true
        }
        
        // Skip embedded image data URIs
        if value.hasPrefix("data:image/") {
            return true
        }
        
        // Skip base64 encoded data
        if value.hasPrefix("data:image/png;base64,") || value.hasPrefix("data:image/svg+xml;base64,") {
            return true
        }
        
        // Skip very long strings (likely embedded assets)
        if value.count > 100 {
            return true
        }
        
        // Skip certain parent paths that contain non-style data
        let skipParentPaths = ["logo_image", "icons"]
        for skipPath in skipParentPaths {
            if parentPath.contains(skipPath) {
                return true
            }
        }
        
        // Skip certain key patterns that are not style-related
        let skipKeyPatterns = ["src", "data", "image", "logo", "icon"]
        for pattern in skipKeyPatterns {
            if keyId.lowercased().contains(pattern) {
                return true
            }
        }
        
        return false
    }
    
    private func getComponentStartLine(_ componentId: String) -> Int? {
        switch componentId {
        case "avatar": return 3
        case "chat": return 8
        case "dashboard": return 133
        case "embed_menu": return 153
        case "explore": return 163
        case "layout": return 173
        case "login": return 181
        case "nav": return 186
        case "semantic_tokens": return 248
        case "site_customization": return 549
        default: return nil
        }
    }
    
    private func getComponentEndLine(_ componentId: String) -> Int? {
        switch componentId {
        case "avatar": return 8 // inclusive of closing brace
        case "chat": return 133
        case "dashboard": return 153
        case "embed_menu": return 163
        case "explore": return 173
        case "layout": return 181
        case "login": return 186
        case "nav": return 248
        case "semantic_tokens": return 549
        case "site_customization": return 553
        default: return nil
        }
    }
    
    private func getSubcomponentStartLine(componentId: String, subcomponentId: String) -> Int? {
        switch componentId {
        case "chat":
            switch subcomponentId {
            case "accordion": return 10
            case "chat_agent_avatar": return 25
            case "chatbox": return 30
            case "explore_chat_toggle": return 45
            case "feedback": return 60
            case "loading_indicator": return 100
            case "message": return 105
            case "recommended_content": return 110
            case "share_button": return 115
            case "suggestion": return 121
            case "welcome_text": return 128
            default: return nil
            }
        case "dashboard":
            switch subcomponentId {
            case "dashboard_folder": return 135
            case "dashboard_search": return 140
            case "new_dashboard_button": return 146
            default: return nil
            }
        case "embed_menu":
            switch subcomponentId {
            case "icon": return 158
            default: return nil
            }
        case "nav":
            switch subcomponentId {
            case "hover": return 192
            case "icon": return 196
            case "icons": return 202
            case "logo_image": return 213
            case "search_buttons": return 230
            case "search_input": return 234
            case "search_panel": return 240
            case "search_result": return 244
            default: return nil
            }
        default: return nil
        }
    }
    
    private func getSubcomponentEndLine(componentId: String, subcomponentId: String) -> Int? {
        switch componentId {
        case "chat":
            switch subcomponentId {
            case "accordion": return 24
            case "chat_agent_avatar": return 30
            case "chatbox": return 44
            case "explore_chat_toggle": return 59
            case "feedback": return 99
            case "loading_indicator": return 104
            case "message": return 109
            case "recommended_content": return 114
            case "share_button": return 120
            case "suggestion": return 127
            case "welcome_text": return 132
            default: return nil
            }
        case "dashboard":
            switch subcomponentId {
            case "dashboard_folder": return 139
            case "dashboard_search": return 145
            case "new_dashboard_button": return 152
            default: return nil
            }
        case "embed_menu":
            switch subcomponentId {
            case "icon": return 161
            default: return nil
            }
        case "nav":
            switch subcomponentId {
            case "hover": return 195
            case "icon": return 201
            case "icons": return 213
            case "logo_image": return 229
            case "search_buttons": return 233
            case "search_input": return 239
            case "search_panel": return 243
            case "search_result": return 247
            default: return nil
            }
        default: return nil
        }
    }
    
    private func getKeyLineNumber(for componentId: String, keyId: String) -> Int? {
        switch componentId {
        case "avatar":
            switch keyId {
            case "background_color": return 5
            case "color": return 6
            default: return nil
            }
        case "chat":
            switch keyId {
            case "background_color": return 24
            case "color": return 44
            case "secondary_color": return 95
            default: return nil
            }
        default:
            return nil
        }
    }
    
    private func getZoeJSONLineRange(for componentId: String) -> String {
        switch componentId {
        case "avatar":
            return "2-5"  // Lines 2-5 in Zoe JSON
        case "chat":
            return "6-105"  // Lines 6-105 in Zoe JSON
        case "dashboard":
            return "106-121"  // Lines 106-121 in Zoe JSON
        case "embed_menu":
            return "122-129"  // Lines 122-129 in Zoe JSON
        case "explore":
            return "130-137"  // Lines 130-137 in Zoe JSON
        case "layout":
            return "138-143"  // Lines 138-143 in Zoe JSON
        case "login":
            return "144-147"  // Lines 144-147 in Zoe JSON
        case "nav":
            return "148-200"  // Lines 148-200 in Zoe JSON
        case "semantic_tokens":
            return "201-498"  // Lines 201-498 in Zoe JSON
        case "site_customization":
            return "499-502"  // Lines 499-502 in Zoe JSON
        default:
            return "unknown"
        }
    }
    
    private func getZoeJSONKeyLineNumber(for componentId: String, keyId: String) -> Int {
        switch componentId {
        case "avatar":
            switch keyId {
            case "background_color":
                return 3  // Line 3 in Zoe JSON
            case "color":
                return 4  // Line 4 in Zoe JSON
            default:
                return 0
            }
        case "chat":
            switch keyId {
            case "background_color":
                return 18  // Line 18 in Zoe JSON (based on your json_orig.json)
            case "color":
                return 34  // Line 34 in Zoe JSON (based on your json_orig.json)
            case "secondary_color":
                return 95  // Line 95 in Zoe JSON (based on your json_orig.json)
            case "accordion":
                return 7  // Line 7 in Zoe JSON (start of accordion object)
            case "chat_agent_avatar":
                return 19  // Line 19 in Zoe JSON (start of chat_agent_avatar object)
            case "chatbox":
                return 23  // Line 23 in Zoe JSON (start of chatbox object)
            case "explore_chat_toggle":
                return 35  // Line 35 in Zoe JSON (start of explore_chat_toggle object)
            case "feedback":
                return 47  // Line 47 in Zoe JSON (start of feedback object)
            case "loading_indicator":
                return 65  // Line 65 in Zoe JSON (start of loading_indicator object)
            case "message":
                return 69  // Line 69 in Zoe JSON (start of message object)
            case "recommended_content":
                return 73  // Line 73 in Zoe JSON (start of recommended_content object)
            case "share_button":
                return 76  // Line 76 in Zoe JSON (start of share_button object)
            case "suggestion":
                return 81  // Line 81 in Zoe JSON (start of suggestion object)
            case "welcome_text":
                return 87  // Line 87 in Zoe JSON (start of welcome_text object)
            default:
                return 0
            }
        case "dashboard":
            switch keyId {
            case "dashboard_folder":
                return 97  // Line 97 in Zoe JSON (start of dashboard_folder object)
            case "dashboard_search":
                return 101  // Line 101 in Zoe JSON (start of dashboard_search object)
            case "new_dashboard_button":
                return 106  // Line 106 in Zoe JSON (start of new_dashboard_button object)
            default:
                return 0
            }
        case "embed_menu":
            switch keyId {
            case "background_color":
                return 123  // Line 123 in Zoe JSON
            case "border_color":
                return 124  // Line 124 in Zoe JSON
            case "color":
                return 125  // Line 125 in Zoe JSON
            case "icon":
                return 126  // Line 126 in Zoe JSON (start of icon object)
            default:
                return 0
            }
        case "explore":
            switch keyId {
            case "run_button":
                return 131  // Line 131 in Zoe JSON (start of run_button object)
            case "background_color":
                return 132  // Line 132 in Zoe JSON
            case "border_color":
                return 133  // Line 133 in Zoe JSON
            case "color":
                return 134  // Line 134 in Zoe JSON
            case "hover_background_color":
                return 135  // Line 135 in Zoe JSON
            default:
                return 0
            }
        case "layout":
            switch keyId {
            case "site_dividers":
                return 139  // Line 139 in Zoe JSON (start of site_dividers object)
            case "border_color":
                return 140  // Line 140 in Zoe JSON
            case "hovered_border_color":
                return 141  // Line 141 in Zoe JSON
            default:
                return 0
            }
        case "login":
            switch keyId {
            case "background_color":
                return 145  // Line 145 in Zoe JSON
            case "color":
                return 146  // Line 146 in Zoe JSON
            default:
                return 0
            }
        case "nav":
            switch keyId {
            case "background_color":
                return 135  // Line 135 in Zoe JSON
            case "border_color":
                return 136  // Line 136 in Zoe JSON
            case "color":
                return 137  // Line 137 in Zoe JSON
            case "divider_color":
                return 138  // Line 138 in Zoe JSON
            case "hover":
                return 139  // Line 139 in Zoe JSON (start of hover object)
            case "icon":
                return 143  // Line 143 in Zoe JSON (start of icon object)
            case "icons":
                return 148  // Line 148 in Zoe JSON (start of icons object)
            case "logo_image":
                return 159  // Line 159 in Zoe JSON (start of logo_image object)
            case "search_buttons":
                return 162  // Line 162 in Zoe JSON (start of search_buttons object)
            case "search_input":
                return 165  // Line 165 in Zoe JSON (start of search_input object)
            case "search_panel":
                return 171  // Line 171 in Zoe JSON (start of search_panel object)
            case "search_result":
                return 175  // Line 175 in Zoe JSON (start of search_result object)
            case "secondary_color":
                return 185  // Line 185 in Zoe JSON
            default:
                return 0
            }
        case "semantic_tokens":
            switch keyId {
            case "colors":
                return 202  // Line 202 in Zoe JSON (start of colors object)
            case "fonts":
                return 502  // Line 502 in Zoe JSON (start of fonts object)
            default:
                return 0
            }
        case "site_customization":
            switch keyId {
            case "show_help_blurbs":
                return 505  // Line 505 in Zoe JSON
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    private func loadFallbackData() {
        // Fallback sample data
        components = [
            StyleComponent(
                id: "chatbox",
                label: "Chatbox",
                keys: [
                    StyleKey(id: "background_color", label: "Background Color", type: .color, value: "background.base.level000", comment: "Main background color", lineNumber: 1),
                    StyleKey(id: "text_color", label: "Text Color", type: .color, value: "text.base.level800", comment: "Primary text color", lineNumber: 2)
                ],
                subcomponents: [],
                comment: "Chat input box styling",
                startLineNumber: 1,
                endLineNumber: 10
            ),
            StyleComponent(
                id: "avatar",
                label: "Avatar",
                keys: [
                    StyleKey(id: "background_color", label: "Background Color", type: .color, value: "background.brand.primary.normal", comment: "Avatar background", lineNumber: 11),
                    StyleKey(id: "text_color", label: "Text Color", type: .color, value: "#FFFFFF", comment: "Avatar text color", lineNumber: 12)
                ],
                subcomponents: [],
                comment: "User avatar styling",
                startLineNumber: 11,
                endLineNumber: 20
            )
        ]
        originalComponents = components // Store original values
        print("StyleEditorViewModel: Stored fallback original values for reset functionality")
    }
    
    private func loadSampleTokens() {
        // This method is no longer needed as we're using the real JSON data
        print("StyleEditorViewModel: Sample tokens loading skipped - using real data")
    }
    
    func selectComponent(_ component: StyleComponent) {
        print("StyleEditorViewModel: selectComponent called for \(component.id)")
        print("StyleEditorViewModel: Component keys: \(component.keys.map { "\($0.id)=\($0.value)" })")
        
        selectedComponent = component
        selectedSubcomponent = nil // Clear subcomponent selection when selecting a component
        currentSnippet = snippetForSelectedComponent
        
        print("StyleEditorViewModel: Selected component: \(component.label)")
        print("StyleEditorViewModel: Initialized currentSnippet for \(component.id)")
        
        // Debug: Check if secondary_color exists in chat component
        if component.id == "chat" {
            print("StyleEditorViewModel: Chat component selected in selectComponent!")
            if let secondaryColorKey = component.keys.first(where: { $0.id == "secondary_color" }) {
                print("StyleEditorViewModel: Found secondary_color key with value: \(secondaryColorKey.value)")
            } else {
                print("StyleEditorViewModel: secondary_color key NOT found in chat component!")
            }
        }
    }
    
    func selectSubcomponent(_ subcomponent: StyleSubcomponent) {
        print("StyleEditorViewModel: selectSubcomponent called for \(subcomponent.id)")
        print("StyleEditorViewModel: Subcomponent keys: \(subcomponent.keys.map { "\($0.id)=\($0.value)" })")
        
        selectedSubcomponent = subcomponent
        currentSnippet = snippetForSelectedSubcomponent
        
        print("StyleEditorViewModel: Selected subcomponent: \(subcomponent.label)")
        print("StyleEditorViewModel: Initialized currentSnippet for subcomponent \(subcomponent.id)")
    }
    
    func updateStyleValue(keyId: String, newValue: String) {
        print("StyleEditorViewModel: updateStyleValue called for \(keyId) with value \(newValue)")
        print("StyleEditorViewModel: Current selectedComponent: \(selectedComponent?.id ?? "nil")")
        print("StyleEditorViewModel: Current selectedSubcomponent: \(selectedSubcomponent?.id ?? "nil")")
        
        // Try to update in selected subcomponent first
        if let selectedSubcomponent = selectedSubcomponent,
           let componentIndex = components.firstIndex(where: { $0.id == selectedComponent?.id }),
           let subcomponentIndex = components[componentIndex].subcomponents.firstIndex(where: { $0.id == selectedSubcomponent.id }),
           let keyIndex = components[componentIndex].subcomponents[subcomponentIndex].keys.firstIndex(where: { $0.id == keyId }) {
            
            print("StyleEditorViewModel: Found subcomponent key at index \(keyIndex)")
            print("StyleEditorViewModel: Old value: \(components[componentIndex].subcomponents[subcomponentIndex].keys[keyIndex].value)")
            
            // Update the subcomponent key in the array
            components[componentIndex].subcomponents[subcomponentIndex].keys[keyIndex].value = newValue
            changedTokens.insert(keyId)
            
            print("StyleEditorViewModel: Updated subcomponent value to: \(components[componentIndex].subcomponents[subcomponentIndex].keys[keyIndex].value)")
            
            // Force a UI update by reassigning the selected subcomponent
            let updatedSubcomponent = components[componentIndex].subcomponents[subcomponentIndex]
            self.selectedSubcomponent = updatedSubcomponent
            
            print("StyleEditorViewModel: Reassigned selectedSubcomponent")
            
            // Update the current snippet immediately
            DispatchQueue.main.async {
                let newSnippet = self.snippetForSelectedSubcomponent
                self.currentSnippet = newSnippet
                print("StyleEditorViewModel: Updated currentSnippet for subcomponent: \(self.currentSnippet)")
            }
            
        } else if let componentIndex = components.firstIndex(where: { $0.id == selectedComponent?.id }),
                  let keyIndex = components[componentIndex].keys.firstIndex(where: { $0.id == keyId }) {
            
            print("StyleEditorViewModel: Found component key at index \(keyIndex)")
            print("StyleEditorViewModel: Old value: \(components[componentIndex].keys[keyIndex].value)")
            
            // Update the component key in the array
            components[componentIndex].keys[keyIndex].value = newValue
            changedTokens.insert(keyId)
            
            print("StyleEditorViewModel: Updated component value to: \(components[componentIndex].keys[keyIndex].value)")
            
            // Force a UI update by reassigning the selected component
            let updatedComponent = components[componentIndex]
            selectedComponent = updatedComponent
            
            print("StyleEditorViewModel: Reassigned selectedComponent")
            
            // Update the current snippet immediately
            DispatchQueue.main.async {
                let newSnippet = self.snippetForSelectedComponent
                self.currentSnippet = newSnippet
                print("StyleEditorViewModel: Updated currentSnippet for component: \(self.currentSnippet)")
            }
            
        } else {
            print("StyleEditorViewModel: Could not find component, subcomponent, or key for \(keyId)")
            if let component = selectedComponent {
                print("StyleEditorViewModel: Available component keys in \(component.id): \(component.keys.map { $0.id })")
                print("StyleEditorViewModel: Available subcomponents: \(component.subcomponents.map { $0.id })")
                if let selectedSubcomponent = selectedSubcomponent {
                    print("StyleEditorViewModel: Available subcomponent keys in \(selectedSubcomponent.id): \(selectedSubcomponent.keys.map { $0.id })")
                }
            }
            return
        }
        
        // Trigger objectWillChange to ensure SwiftUI updates
        objectWillChange.send()
        
        print("StyleEditorViewModel: Sent objectWillChange")
    }
    
    func getResolvedValue(for keyId: String) -> String? {
        // Try to find the key in the selected subcomponent first
        if let selectedSubcomponent = selectedSubcomponent,
           let key = selectedSubcomponent.keys.first(where: { $0.id == keyId }) {
            
            // If it's already a hex color, return it
            if key.value.hasPrefix("#") {
                return key.value
            }
            
            // Try to resolve semantic token
            return resolveSemanticToken(key.value)
        }
        
        // Fall back to the selected component
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
    
    var snippetForSelectedComponent: String {
        guard let component = selectedComponent else { 
            print("StyleEditorViewModel: No selected component for snippet")
            return "" 
        }
        
        print("StyleEditorViewModel: Generating snippet for component \(component.id)")
        
        // Load the original JSON file as text to extract exact lines
        guard let url = Bundle.main.url(forResource: "json_orig", withExtension: "json"),
              let jsonString = try? String(contentsOf: url, encoding: .utf8) else {
            print("StyleEditorViewModel: Failed to load original JSON file")
            return ""
        }
        
        let lines = jsonString.components(separatedBy: .newlines)
        
        // Get the start and end line numbers for this component
        guard let startLine = component.startLineNumber,
              let endLine = component.endLineNumber,
              startLine <= lines.count,
              endLine <= lines.count else {
            print("StyleEditorViewModel: Invalid line numbers for component \(component.id)")
            return ""
        }
        
        // Extract the exact lines from the original file
        var componentLines = Array(lines[(startLine - 1)..<endLine])
        
        // Apply user changes to the extracted lines
        for key in component.keys {
            if changedTokens.contains(key.id) {
                print("StyleEditorViewModel: Found changed token: \(key.id) with value: \(key.value)")
                // Find the line that contains this key and update it
                for (lineIndex, line) in componentLines.enumerated() {
                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                    print("StyleEditorViewModel: Checking line \(lineIndex): '\(trimmedLine)'")
                    if trimmedLine.hasPrefix("\"\(key.id)\":") {
                        // Update the line with the new value
                        let indent = String(line.prefix(while: { $0.isWhitespace }))
                        let newLine = "\(indent)\"\(key.id)\": \"\(key.value)\","
                        componentLines[lineIndex] = newLine
                        print("StyleEditorViewModel: Updated line for \(key.id) to: \(newLine)")
                        break
                    }
                }
            }
        }
        
        let snippet = componentLines.joined(separator: "\n")
        
        print("StyleEditorViewModel: Extracted lines \(startLine)-\(endLine) for component \(component.id)")
        print("StyleEditorViewModel: Generated snippet with changes: \(snippet)")
        return snippet
    }
    
    var snippetForSelectedSubcomponent: String {
        guard let subcomponent = selectedSubcomponent else { 
            print("StyleEditorViewModel: No selected subcomponent for snippet")
            return "" 
        }
        
        print("StyleEditorViewModel: Generating snippet for subcomponent \(subcomponent.id)")
        
        // Load the original JSON file as text to extract exact lines
        guard let url = Bundle.main.url(forResource: "json_orig", withExtension: "json"),
              let jsonString = try? String(contentsOf: url, encoding: .utf8) else {
            print("StyleEditorViewModel: Failed to load original JSON file")
            return ""
        }
        
        let lines = jsonString.components(separatedBy: .newlines)
        
        // Get the start and end line numbers for this subcomponent
        guard let startLine = subcomponent.startLineNumber,
              let endLine = subcomponent.endLineNumber,
              startLine <= lines.count,
              endLine <= lines.count else {
            print("StyleEditorViewModel: Invalid line numbers for subcomponent \(subcomponent.id)")
            return ""
        }
        
        // Extract the exact lines from the original file
        var subcomponentLines = Array(lines[(startLine - 1)..<endLine])
        
        // Apply user changes to the extracted lines
        for key in subcomponent.keys {
            if changedTokens.contains(key.id) {
                print("StyleEditorViewModel: Found changed token: \(key.id) with value: \(key.value)")
                // Find the line that contains this key and update it
                for (lineIndex, line) in subcomponentLines.enumerated() {
                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                    print("StyleEditorViewModel: Checking line \(lineIndex): '\(trimmedLine)'")
                    if trimmedLine.hasPrefix("\"\(key.id)\":") {
                        // Update the line with the new value
                        let indent = String(line.prefix(while: { $0.isWhitespace }))
                        let newLine = "\(indent)\"\(key.id)\": \"\(key.value)\","
                        subcomponentLines[lineIndex] = newLine
                        print("StyleEditorViewModel: Updated line for \(key.id) to: \(newLine)")
                        break
                    }
                }
            }
        }
        
        let snippet = subcomponentLines.joined(separator: "\n")
        
        print("StyleEditorViewModel: Extracted lines \(startLine)-\(endLine) for subcomponent \(subcomponent.id)")
        print("StyleEditorViewModel: Generated snippet with changes: \(snippet)")
        return snippet
    }
    

    
    func snippetForChangedTokens() -> String {
        guard !changedTokens.isEmpty else { return "" }
        
        var snippet = "{\n"
        snippet += "  \"component_updates\": {\n"
        snippet += "    \"\(selectedComponent?.id ?? "")\": {\n"
        
        for (index, tokenId) in changedTokens.enumerated() {
            if let component = selectedComponent,
               let key = component.keys.first(where: { $0.id == tokenId }) {
                snippet += "      \"\(tokenId)\": \"\(key.value)\""
                if index < changedTokens.count - 1 {
                    snippet += ","
                }
                snippet += "\n"
            }
        }
        
        snippet += "    }\n"
        snippet += "  }\n"
        snippet += "}"
        return snippet
    }
    
    func resetToOriginalValues() {
        print("StyleEditorViewModel: Resetting to original values...")
        components = originalComponents
        changedTokens.removeAll()
        
        // Update the selected component if one is selected
        if let selectedId = selectedComponent?.id {
            selectedComponent = components.first { $0.id == selectedId }
            print("StyleEditorViewModel: Updated selected component after reset")
        }
        
        // Update the selected subcomponent if one is selected
        if let selectedSubcomponentId = selectedSubcomponent?.id,
           let updatedComponent = selectedComponent {
            selectedSubcomponent = updatedComponent.subcomponents.first { $0.id == selectedSubcomponentId }
            print("StyleEditorViewModel: Updated selected subcomponent after reset")
        }
        
        // Update the current snippet
        if selectedSubcomponent != nil {
            currentSnippet = snippetForSelectedSubcomponent
        } else {
            currentSnippet = snippetForSelectedComponent
        }
        print("StyleEditorViewModel: Reset complete. Current components: \(components.count)")
        print("StyleEditorViewModel: Updated current snippet after reset")
    }
    
    private func createUserFriendlyLabel(keyId: String, value: String) -> String {
        // Create more descriptive labels based on the key name and context
        let baseLabel = keyId.replacingOccurrences(of: "_", with: " ").capitalized
        
        // Add context based on the key name
        if keyId.contains("background_color") {
            return "Background Color"
        } else if keyId.contains("color") && !keyId.contains("background") && !keyId.contains("border") {
            return "Text Color"
        } else if keyId.contains("border_color") {
            return "Border Color"
        } else if keyId.contains("border_radius") {
            return "Border Radius"
        } else if keyId.contains("height") {
            return "Height"
        } else if keyId.contains("width") {
            return "Width"
        } else if keyId.contains("padding") {
            return "Padding"
        } else if keyId.contains("margin") {
            return "Margin"
        } else if keyId.contains("font") {
            return "Font"
        } else if keyId.contains("size") {
            return "Size"
        } else if keyId.contains("opacity") {
            return "Opacity"
        } else if keyId.contains("shadow") {
            return "Shadow"
        }
        
        return baseLabel
    }
    
    private func createHelpfulComment(keyId: String, value: String) -> String? {
        // Provide helpful context about what each property does
        if keyId.contains("background_color") {
            return "Sets the background color of this element"
        } else if keyId.contains("color") && !keyId.contains("background") && !keyId.contains("border") {
            return "Sets the text color of this element"
        } else if keyId.contains("border_color") {
            return "Sets the border color of this element"
        } else if keyId.contains("border_radius") {
            return "Sets how rounded the corners are"
        } else if keyId.contains("height") {
            return "Sets the height of this element"
        } else if keyId.contains("width") {
            return "Sets the width of this element"
        } else if keyId.contains("hover") {
            return "Style applied when hovering over this element"
        } else if keyId.contains("active") {
            return "Style applied when this element is active/clicked"
        } else if keyId.contains("disabled") {
            return "Style applied when this element is disabled"
        } else if keyId.contains("focused") {
            return "Style applied when this element is focused"
        } else if keyId.contains("selected") {
            return "Style applied when this element is selected"
        }
        
        return nil
    }
}

enum PreviewMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
} 