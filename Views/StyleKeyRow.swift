import SwiftUI

struct StyleKeyRow: View {
    @ObservedObject var viewModel: StyleEditorViewModel
    let keyId: String
    
    private var key: StyleKey? {
        viewModel.selectedComponent?.keys.first { $0.id == keyId }
    }
    
    var body: some View {
        if let key = viewModel.selectedComponent?.keys.first(where: { $0.id == keyId }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with label and type indicator
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key.label)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let comment = key.comment {
                            Text(comment)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    // Type badge
                    TypeBadge(type: key.type)
                }
                
                // Value editor based on type
                switch key.type {
                case .color:
                    ColorValueEditor(viewModel: viewModel, keyId: keyId)
                case .font:
                    FontValueEditor(key: key, viewModel: viewModel)
                case .string:
                    StringValueEditor(key: key, viewModel: viewModel)
                case .number:
                    NumberValueEditor(key: key, viewModel: viewModel)
                case .bool:
                    BoolValueEditor(key: key, viewModel: viewModel)
                case .borderRadius:
                    BorderRadiusValueEditor(viewModel: viewModel, keyId: keyId)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                    )
            )
        } else {
            Text("Key not found: \(keyId)")
                .foregroundColor(.red)
                .padding(16)
        }
    }
}

// MARK: - Type Badge
struct TypeBadge: View {
    let type: StyleType
    
    var body: some View {
        Text(type.rawValue.capitalized)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(typeColor)
            )
    }
    
    private var typeColor: Color {
        switch type {
        case .color: return Color.blue
        case .font: return Color.purple
        case .string: return Color.green
        case .number: return Color.orange
        case .bool: return Color.red
        case .borderRadius: return Color.orange // Assuming a color for border radius
        }
    }
}

// MARK: - Color Value Editor
struct ColorValueEditor: View {
    @ObservedObject var viewModel: StyleEditorViewModel
    let keyId: String
    @State private var selectedColor: Color = .gray
    @State private var showColorPicker = false
    
    private var key: StyleKey? {
        let foundKey = viewModel.selectedComponent?.keys.first { $0.id == keyId }
        print("ColorValueEditor: Looking for keyId '\(keyId)', found: \(foundKey?.value ?? "nil")")
        print("ColorValueEditor: Current component: \(viewModel.selectedComponent?.id ?? "nil")")
        print("ColorValueEditor: Available keys: \(viewModel.selectedComponent?.keys.map { $0.id } ?? [])")
        return foundKey
    }
    
    var body: some View {
        // Always show the color picker for color keys, even if the key doesn't exist yet
        // This ensures the UI is always available
        VStack(alignment: .leading, spacing: 8) {
                // Color preview and picker button
                HStack(spacing: 8) {
                    // Color preview
                    RoundedRectangle(cornerRadius: 6)
                        .fill(selectedColor)
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                    
                    // Manual text input
                    TextField("Enter hex color", text: Binding(
                        get: { 
                            let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
                            print("ColorValueEditor: Getting value for \(keyId): \(currentValue)")
                            return currentValue
                        },
                        set: { newValue in
                            print("ColorValueEditor: Text field changed to \(newValue) for keyId \(keyId)")
                            // Update color preview if it's a valid hex
                            if let color = Color(hex: newValue) {
                                selectedColor = color
                            }
                            // Update the value immediately
                            print("ColorValueEditor: About to call updateStyleValue for keyId: \(keyId) with value: \(newValue)")
                            viewModel.updateStyleValue(keyId: keyId, newValue: newValue)
                            print("ColorValueEditor: updateStyleValue call completed for keyId: \(keyId)")
                        }
                    ))
                    .textFieldStyle(ModernTextFieldStyle())
                    .frame(width: 120)
                    
                    // Picker button
                    Button(action: {
                        showColorPicker.toggle()
                    }) {
                        HStack {
                            Text("Color")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $showColorPicker) {
                        ColorPickerView(
                            selectedColor: $selectedColor,
                            onSelect: { color in
                                selectedColor = color
                                let hexValue = color.toHex() ?? "#000000"
                                print("ColorValueEditor: Color picker selected \(hexValue)")
                                print("ColorValueEditor: About to call updateStyleValue for keyId: \(keyId)")
                                // Update the value immediately
                                viewModel.updateStyleValue(keyId: keyId, newValue: hexValue)
                                print("ColorValueEditor: updateStyleValue call completed")
                                showColorPicker = false
                            }
                        )
                        .frame(width: 300, height: 400)
                    }
                }
                
                // Show resolved value if different from current value
                let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
                if let resolvedValue = viewModel.getResolvedValue(for: keyId),
                   resolvedValue != currentValue {
                    HStack {
                        Text("→ \(resolvedValue)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .onAppear {
                // Initialize the color picker with the current value
                let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
                selectedColor = Color(hex: currentValue) ?? .gray
                print("ColorValueEditor: onAppear with value \(currentValue) for keyId \(keyId)")
            }
            .onChange(of: viewModel.selectedComponent) { _, _ in
                // Update the color picker when the value changes externally
                let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
                selectedColor = Color(hex: currentValue) ?? .gray
                print("ColorValueEditor: onChange detected for \(keyId) to \(currentValue)")
            }
    }
}

// MARK: - Color Picker View
struct ColorPickerView: View {
    @Binding var selectedColor: Color
    let onSelect: (Color) -> Void
    
    private let predefinedColors: [(String, Color)] = [
        ("Red", .red),
        ("Orange", .orange),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Blue", .blue),
        ("Purple", .purple),
        ("Pink", .pink),
        ("Gray", .gray),
        ("Black", .black),
        ("White", .white)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Color Picker")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            // Native color picker
            ColorPicker("Select Color", selection: $selectedColor, supportsOpacity: false)
                .labelsHidden()
            
            Divider()
            
            // Predefined colors
            Text("Quick Colors")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(predefinedColors, id: \.0) { colorOption in
                    Button(action: {
                        selectedColor = colorOption.1
                    }) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(colorOption.1)
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
            
            // Apply button
            Button("Apply Color") {
                onSelect(selectedColor)
            }
            .buttonStyle(ModernButtonStyle())
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Font Value Editor
struct FontValueEditor: View {
    let key: StyleKey
    @ObservedObject var viewModel: StyleEditorViewModel
    
    var body: some View {
        HStack {
            TextField("Font value", text: Binding(
                get: { 
                    let currentValue = viewModel.selectedComponent?.keys.first { $0.id == key.id }?.value ?? ""
                    return currentValue
                },
                set: { newValue in
                    print("FontValueEditor: Text field changed to \(newValue)")
                    viewModel.updateStyleValue(keyId: key.id, newValue: newValue)
                }
            ))
            .textFieldStyle(ModernTextFieldStyle())
            
            Button("Preview") {
                // Font preview action
            }
            .buttonStyle(ModernButtonStyle())
        }
    }
}

// MARK: - String Value Editor
struct StringValueEditor: View {
    let key: StyleKey
    @ObservedObject var viewModel: StyleEditorViewModel
    
    var body: some View {
        TextField("String value", text: Binding(
            get: { 
                let currentValue = viewModel.selectedComponent?.keys.first { $0.id == key.id }?.value ?? ""
                return currentValue
            },
            set: { newValue in
                print("StringValueEditor: Text field changed to \(newValue)")
                viewModel.updateStyleValue(keyId: key.id, newValue: newValue)
            }
        ))
        .textFieldStyle(ModernTextFieldStyle())
    }
}

// MARK: - Number Value Editor
struct NumberValueEditor: View {
    let key: StyleKey
    @ObservedObject var viewModel: StyleEditorViewModel
    
    var body: some View {
        HStack {
            TextField("Number value", text: Binding(
                get: { 
                    let currentValue = viewModel.selectedComponent?.keys.first { $0.id == key.id }?.value ?? ""
                    return currentValue
                },
                set: { newValue in
                    print("NumberValueEditor: Text field changed to \(newValue)")
                    viewModel.updateStyleValue(keyId: key.id, newValue: newValue)
                }
            ))
            .textFieldStyle(ModernTextFieldStyle())
            
            Stepper("", value: Binding(
                get: { 
                    let currentValue = viewModel.selectedComponent?.keys.first { $0.id == key.id }?.value ?? ""
                    return Double(currentValue) ?? 0
                },
                set: { newValue in
                    print("NumberValueEditor: Stepper changed to \(newValue)")
                    viewModel.updateStyleValue(keyId: key.id, newValue: String(newValue))
                }
            ), in: 0...1000, step: 1)
            .labelsHidden()
        }
    }
}

// MARK: - Bool Value Editor
struct BoolValueEditor: View {
    let key: StyleKey
    @ObservedObject var viewModel: StyleEditorViewModel
    
    var body: some View {
        HStack {
            let currentValue = viewModel.selectedComponent?.keys.first { $0.id == key.id }?.value ?? ""
            Text(currentValue == "true" ? "Enabled" : "Disabled")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(currentValue == "true" ? .green : .red)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { 
                    let currentValue = viewModel.selectedComponent?.keys.first { $0.id == key.id }?.value ?? ""
                    return currentValue == "true"
                },
                set: { newValue in
                    print("BoolValueEditor: Toggle changed to \(newValue)")
                    viewModel.updateStyleValue(keyId: key.id, newValue: newValue ? "true" : "false")
                }
            ))
            .toggleStyle(SwitchToggleStyle())
            .labelsHidden()
        }
    }
}

// MARK: - Border Radius Value Editor
struct BorderRadiusValueEditor: View {
    @ObservedObject var viewModel: StyleEditorViewModel
    let keyId: String
    @State private var selectedRadius: String = ""
    @State private var showPicker = false
    
    private var key: StyleKey? {
        let foundKey = viewModel.selectedComponent?.keys.first { $0.id == keyId }
        print("BorderRadiusValueEditor: Looking for keyId '\(keyId)', found: \(foundKey?.value ?? "nil")")
        return foundKey
    }
    
    private let radiusOptions = [
        ("none", "0px", "No border radius"),
        ("xs", "2px", "Extra small radius"),
        ("sm", "4px", "Small radius"),
        ("md", "6px", "Medium radius"),
        ("lg", "8px", "Large radius"),
        ("xl", "12px", "Extra large radius"),
        ("2xl", "16px", "2X large radius"),
        ("3xl", "24px", "3X large radius"),
        ("full", "9999px", "Fully rounded")
    ]
    
    var body: some View {
        let _ = print("BorderRadiusValueEditor: body called for keyId \(keyId)")
        if viewModel.selectedComponent?.keys.first(where: { $0.id == keyId }) != nil {
            HStack {
                // Border radius preview and picker
                HStack(spacing: 8) {
                    // Visual preview
                    RoundedRectangle(cornerRadius: getCornerRadius())
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 40, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: getCornerRadius())
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    
                    // Picker button
                    Button(action: {
                        showPicker.toggle()
                    }) {
                        HStack {
                            let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
                            Text(selectedRadius.isEmpty ? currentValue : selectedRadius)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $showPicker) {
                        BorderRadiusPickerView(
                            selectedRadius: $selectedRadius,
                            onSelect: { radius in
                                selectedRadius = radius
                                print("BorderRadiusValueEditor: Selected radius \(radius) for keyId \(keyId)")
                                print("BorderRadiusValueEditor: About to call updateStyleValue...")
                                viewModel.updateStyleValue(keyId: keyId, newValue: radius)
                                print("BorderRadiusValueEditor: updateStyleValue call completed")
                                showPicker = false
                            }
                        )
                        .frame(width: 280, height: 320)
                    }
                }
                
                Spacer()
                
                // Show resolved value if different from current value
                let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
                if let resolvedValue = viewModel.getResolvedValue(for: keyId),
                   resolvedValue != currentValue {
                    Text("→ \(resolvedValue)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
                selectedRadius = currentValue
                print("BorderRadiusValueEditor: onAppear with value \(currentValue)")
            }
            .onChange(of: viewModel.selectedComponent) { _, _ in
                let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
                selectedRadius = currentValue
                print("BorderRadiusValueEditor: onChange detected for \(keyId) to \(currentValue)")
            }
        } else {
            Text("Key not found: \(keyId)")
                .foregroundColor(.red)
        }
    }
    
    private func getCornerRadius() -> CGFloat {
        let currentValue = viewModel.selectedComponent?.keys.first { $0.id == keyId }?.value ?? ""
        let value = selectedRadius.isEmpty ? currentValue : selectedRadius
        switch value {
        case "none": return 0
        case "xs": return 2
        case "sm": return 4
        case "md": return 6
        case "lg": return 8
        case "xl": return 12
        case "2xl": return 16
        case "3xl": return 24
        case "full": return 16
        default: return 8
        }
    }
}

// MARK: - Border Radius Picker View
struct BorderRadiusPickerView: View {
    @Binding var selectedRadius: String
    let onSelect: (String) -> Void
    
    private let radiusOptions = [
        ("none", "0px", "No border radius"),
        ("xs", "2px", "Extra small radius"),
        ("sm", "4px", "Small radius"),
        ("md", "6px", "Medium radius"),
        ("lg", "8px", "Large radius"),
        ("xl", "12px", "Extra large radius"),
        ("2xl", "16px", "2X large radius"),
        ("3xl", "24px", "3X large radius"),
        ("full", "9999px", "Fully rounded")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Border Radius")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            // Options grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(radiusOptions, id: \.0) { option in
                    BorderRadiusOptionView(
                        option: option,
                        isSelected: selectedRadius == option.0,
                        onSelect: {
                            selectedRadius = option.0
                            onSelect(option.0)
                        }
                    )
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Border Radius Option View
struct BorderRadiusOptionView: View {
    let option: (String, String, String)
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Visual preview
                RoundedRectangle(cornerRadius: getCornerRadius())
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 60, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: getCornerRadius())
                            .stroke(Color.blue, lineWidth: 2)
                    )
                
                // Label
                Text(option.0)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                
                // Value
                Text(option.1)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color(NSColor.separatorColor), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getCornerRadius() -> CGFloat {
        switch option.0 {
        case "none": return 0
        case "xs": return 2
        case "sm": return 4
        case "md": return 6
        case "lg": return 8
        case "xl": return 12
        case "2xl": return 16
        case "3xl": return 24
        case "full": return 20
        default: return 8
        }
    }
}

// MARK: - Modern Styles
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
            )
            .font(.system(size: 14))
    }
}

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            )
            .foregroundColor(.white)
            .font(.system(size: 13, weight: .medium))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Color Extensions
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        guard let components = NSColor(self).cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

extension NSColor {
    func toHex() -> String? {
        guard let components = self.cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
} 