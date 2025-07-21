import SwiftUI

struct PreviewPanel: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Preview")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(previewMode == .light ? "Light Mode" : "Dark Mode")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    switch component.id {
                    case "chatbox":
                        ChatboxPreview(component: component, previewMode: previewMode)
                    case "chat":
                        ChatPreview(component: component, previewMode: previewMode)
                    case "avatar":
                        AvatarPreview(component: component, previewMode: previewMode)
                    case "dashboard":
                        DashboardPreview(component: component, previewMode: previewMode)
                    case "nav":
                        NavigationPreview(component: component, previewMode: previewMode)
                    case "login":
                        LoginPreview(component: component, previewMode: previewMode)
                    case "embed_menu":
                        EmbedMenuPreview(component: component, previewMode: previewMode)
                    case "explore":
                        ExplorePreview(component: component, previewMode: previewMode)
                    case "layout":
                        LayoutPreview(component: component, previewMode: previewMode)
                    default:
                        GenericPreview(component: component, previewMode: previewMode)
                    }
                }
                .padding()
            }
        }
        .background(previewMode == .light ? Color.white : Color.black)
        .foregroundColor(previewMode == .light ? Color.black : Color.white)
    }
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
}

// MARK: - Preview Components

struct ChatboxPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Chatbox")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            HStack {
                TextField("Type your message...", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 40)
                    .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
                    .background(getColor(for: "background_color", fallback: previewMode == .light ? "#FFFFFF" : "#2C2C2E"))
                
                Button(action: {}) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(getColor(for: "color", fallback: "#007AFF"))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct ChatPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Chat Interface")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            VStack(spacing: 8) {
                HStack {
                    Circle()
                        .fill(getColor(for: "avatar_background_color", fallback: "#007AFF"))
                        .frame(width: 30, height: 30)
                    
                    VStack(alignment: .leading) {
                        Text("Zoë")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(getColor(for: "name_color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
                        Text("Hello! How can I help you today?")
                            .font(.caption)
                            .foregroundColor(getColor(for: "message_color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(getColor(for: "message_background_color", fallback: previewMode == .light ? "#F2F2F7" : "#2C2C2E"))
                .cornerRadius(12)
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Can you show me my dashboard?")
                            .font(.caption)
                            .foregroundColor(getColor(for: "user_message_color", fallback: "#FFFFFF"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(getColor(for: "user_message_background_color", fallback: "#007AFF"))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct AvatarPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("User Avatar")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            Circle()
                .fill(getColor(for: "background_color", fallback: "#007AFF"))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("GP")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(getColor(for: "text_color", fallback: "#FFFFFF"))
                )
        }
        .padding()
        .background(getColor(for: "container_background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct DashboardPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Dashboard")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                DashboardCard(title: "Total Users", value: "1,234", color: getColor(for: "primary_color", fallback: "#007AFF"), component: component, previewMode: previewMode)
                DashboardCard(title: "Revenue", value: "$45,678", color: getColor(for: "success_color", fallback: "#34C759"), component: component, previewMode: previewMode)
                DashboardCard(title: "Orders", value: "567", color: getColor(for: "warning_color", fallback: "#FF9500"), component: component, previewMode: previewMode)
                DashboardCard(title: "Growth", value: "+12%", color: getColor(for: "secondary_color", fallback: "#AF52DE"), component: component, previewMode: previewMode)
            }
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct NavigationPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Navigation")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            VStack(spacing: 8) {
                NavigationItem(icon: "house", title: "Dashboard", isActive: true, component: component, previewMode: previewMode)
                NavigationItem(icon: "chart.bar", title: "Analytics", component: component, previewMode: previewMode)
                NavigationItem(icon: "person", title: "Profile", component: component, previewMode: previewMode)
                NavigationItem(icon: "gear", title: "Settings", component: component, previewMode: previewMode)
            }
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct LoginPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Login Form")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            VStack(spacing: 12) {
                TextField("Email", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
                    .background(getColor(for: "background_color", fallback: previewMode == .light ? "#FFFFFF" : "#2C2C2E"))
                
                SecureField("Password", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
                    .background(getColor(for: "background_color", fallback: previewMode == .light ? "#FFFFFF" : "#2C2C2E"))
                
                Button("Sign In") {}
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(getColor(for: "button_text_color", fallback: previewMode == .light ? "#FFFFFF" : "#FFFFFF"))
                    .background(getColor(for: "button_background_color", fallback: previewMode == .light ? "#007AFF" : "#007AFF"))
            }
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct EmbedMenuPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Embed Menu")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            VStack(spacing: 8) {
                MenuItem(icon: "link", title: "Copy Link", component: component, previewMode: previewMode)
                MenuItem(icon: "square.and.arrow.up", title: "Share", component: component, previewMode: previewMode)
                MenuItem(icon: "doc.on.doc", title: "Duplicate", component: component, previewMode: previewMode)
                MenuItem(icon: "trash", title: "Delete", component: component, previewMode: previewMode)
            }
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct ExplorePreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Explore")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            VStack(spacing: 12) {
                TextField("Search...", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
                    .background(getColor(for: "background_color", fallback: previewMode == .light ? "#FFFFFF" : "#2C2C2E"))
                
                Button("Run Query") {}
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(getColor(for: "button_text_color", fallback: previewMode == .light ? "#FFFFFF" : "#FFFFFF"))
                    .background(getColor(for: "button_background_color", fallback: previewMode == .light ? "#007AFF" : "#007AFF"))
            }
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct LayoutPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Layout Elements")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            VStack(spacing: 8) {
                Rectangle()
                    .fill(getColor(for: "divider_color", fallback: "#E0E0E0"))
                    .frame(height: 1)
                
                HStack {
                    Text("Section Divider")
                        .font(.caption)
                        .foregroundColor(getColor(for: "divider_text_color", fallback: "#808080"))
                    Spacer()
                }
                
                Rectangle()
                    .fill(getColor(for: "divider_color", fallback: "#E0E0E0"))
                    .frame(height: 1)
            }
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

struct GenericPreview: View {
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Component Preview")
                .font(.headline)
                .foregroundColor(getColor(for: "color", fallback: previewMode == .light ? "#000000" : "#FFFFFF"))
            
            Text("Select a component to see its preview")
                .font(.caption)
                .foregroundColor(getColor(for: "message_color", fallback: previewMode == .light ? "#808080" : "#B0B0B0"))
        }
        .padding()
        .background(getColor(for: "background_color", fallback: previewMode == .light ? "#F2F2F7" : "#1C1C1E"))
        .cornerRadius(8)
    }
}

// MARK: - Helper Views

struct DashboardCard: View {
    let title: String
    let value: String
    let color: Color
    let component: StyleComponent
    let previewMode: PreviewMode
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(getColor(for: "secondary_color", fallback: previewMode == .light ? "#808080" : "#B0B0B0"))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

struct NavigationItem: View {
    let icon: String
    let title: String
    let isActive: Bool
    let component: StyleComponent
    let previewMode: PreviewMode
    
    init(icon: String, title: String, isActive: Bool = false, component: StyleComponent, previewMode: PreviewMode) {
        self.icon = icon
        self.title = title
        self.isActive = isActive
        self.component = component
        self.previewMode = previewMode
    }
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isActive ? getColor(for: "active_nav_item_color", fallback: "#007AFF") : getColor(for: "nav_item_color", fallback: "#808080"))
            Text(title)
                .foregroundColor(isActive ? getColor(for: "active_nav_item_color", fallback: "#007AFF") : getColor(for: "nav_item_color", fallback: "#808080"))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isActive ? getColor(for: "active_nav_item_background_color", fallback: "#E0E0E0") : Color.clear)
        .cornerRadius(6)
    }
}

struct MenuItem: View {
    let icon: String
    let title: String
    let component: StyleComponent
    let previewMode: PreviewMode
    
    init(icon: String, title: String, component: StyleComponent, previewMode: PreviewMode) {
        self.icon = icon
        self.title = title
        self.component = component
        self.previewMode = previewMode
    }
    
    private func getValue(for key: String) -> String? {
        component.keys.first { $0.id == key }?.value
    }
    
    private func getColor(for key: String, fallback: String = "#CCCCCC") -> Color {
        let hexValue = getValue(for: key) ?? fallback
        return Color(hex: hexValue) ?? Color(hex: fallback) ?? Color.gray
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(getColor(for: "menu_item_color", fallback: "#808080"))
            Text(title)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(6)
    }
} 