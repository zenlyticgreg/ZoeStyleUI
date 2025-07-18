import SwiftUI

struct StyleKeyRow: View {
    let key: StyleKey
    @ObservedObject var viewModel: StyleEditorViewModel
    @State private var showingColorPicker = false
    @State private var tempColor: Color = .clear
    
    var body: some View {
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
                ColorValueEditor(key: key, viewModel: viewModel, showingColorPicker: $showingColorPicker, tempColor: $tempColor)
            case .font:
                FontValueEditor(key: key, viewModel: viewModel)
            case .string:
                StringValueEditor(key: key, viewModel: viewModel)
            case .number:
                NumberValueEditor(key: key, viewModel: viewModel)
            case .bool:
                BoolValueEditor(key: key, viewModel: viewModel)
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
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet(key: key, viewModel: viewModel, tempColor: $tempColor)
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
        }
    }
}

// MARK: - Color Value Editor
struct ColorValueEditor: View {
    let key: StyleKey
    @ObservedObject var viewModel: StyleEditorViewModel
    @Binding var showingColorPicker: Bool
    @Binding var tempColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Color preview
            Button(action: {
                tempColor = Color(hex: key.value) ?? .gray
                showingColorPicker = true
            }) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: key.value) ?? .gray)
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Color value display
            VStack(alignment: .leading, spacing: 4) {
                Text(key.value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                if let resolvedValue = viewModel.getResolvedValue(for: key.id) {
                    Text("→ \(resolvedValue)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Color picker button
            Button(action: {
                tempColor = Color(hex: key.value) ?? .gray
                showingColorPicker = true
            }) {
                Image(systemName: "eyedropper")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Font Value Editor
struct FontValueEditor: View {
    let key: StyleKey
    @ObservedObject var viewModel: StyleEditorViewModel
    @State private var text = ""
    
    var body: some View {
        HStack {
            TextField("Font value", text: Binding(
                get: { text.isEmpty ? key.value : text },
                set: { newValue in
                    text = newValue
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
    @State private var text = ""
    
    var body: some View {
        TextField("String value", text: Binding(
            get: { text.isEmpty ? key.value : text },
            set: { newValue in
                text = newValue
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
    @State private var text = ""
    
    var body: some View {
        HStack {
            TextField("Number value", text: Binding(
                get: { text.isEmpty ? key.value : text },
                set: { newValue in
                    text = newValue
                    viewModel.updateStyleValue(keyId: key.id, newValue: newValue)
                }
            ))
            .textFieldStyle(ModernTextFieldStyle())
            
            Stepper("", value: Binding(
                get: { Double(text.isEmpty ? key.value : text) ?? 0 },
                set: { newValue in
                    text = String(newValue)
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
            Text(key.value == "true" ? "Enabled" : "Disabled")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(key.value == "true" ? .green : .red)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { key.value == "true" },
                set: { newValue in
                    viewModel.updateStyleValue(keyId: key.id, newValue: newValue ? "true" : "false")
                }
            ))
            .toggleStyle(SwitchToggleStyle())
            .labelsHidden()
        }
    }
}

// MARK: - Color Picker Sheet
struct ColorPickerSheet: View {
    let key: StyleKey
    @ObservedObject var viewModel: StyleEditorViewModel
    @Binding var tempColor: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Color preview
                RoundedRectangle(cornerRadius: 16)
                    .fill(tempColor)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Color picker
                ColorPicker("Select Color", selection: $tempColor)
                    .labelsHidden()
                
                // Preset colors
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        Button(action: {
                            tempColor = color
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            .padding(24)
            .frame(width: 400, height: 500)
            .navigationTitle("Color Picker")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        let hexValue = tempColor.toHex() ?? "#000000"
                        viewModel.updateStyleValue(keyId: key.id, newValue: hexValue)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private let presetColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .gray, .black, .white, .brown, .mint, .teal, .cyan,
        .indigo, .red.opacity(0.8), .green.opacity(0.8), .blue.opacity(0.8)
    ]
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