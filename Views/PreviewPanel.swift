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
                        ChatboxPreview()
                    case "chat":
                        ChatPreview()
                    case "avatar":
                        AvatarPreview()
                    case "dashboard":
                        DashboardPreview()
                    case "nav":
                        NavigationPreview()
                    case "login":
                        LoginPreview()
                    case "embed_menu":
                        EmbedMenuPreview()
                    case "explore":
                        ExplorePreview()
                    case "layout":
                        LayoutPreview()
                    default:
                        GenericPreview()
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
    var body: some View {
        VStack(spacing: 12) {
            Text("Chatbox")
                .font(.headline)
            
            HStack {
                TextField("Type your message...", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 40)
                
                Button(action: {}) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ChatPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Chat Interface")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                    
                    VStack(alignment: .leading) {
                        Text("Zoë")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("Hello! How can I help you today?")
                            .font(.caption)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlAlternatingRowBackgroundColors[0]))
                .cornerRadius(12)
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Can you show me my dashboard?")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct AvatarPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("User Avatar")
                .font(.headline)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 60, height: 60)
                .overlay(
                    Text("GP")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct DashboardPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Dashboard")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                DashboardCard(title: "Total Users", value: "1,234", color: Color.blue)
                DashboardCard(title: "Revenue", value: "$45,678", color: Color.green)
                DashboardCard(title: "Orders", value: "567", color: Color.orange)
                DashboardCard(title: "Growth", value: "+12%", color: Color.purple)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct NavigationPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Navigation")
                .font(.headline)
            
            VStack(spacing: 8) {
                NavigationItem(icon: "house", title: "Dashboard", isActive: true)
                NavigationItem(icon: "chart.bar", title: "Analytics")
                NavigationItem(icon: "person", title: "Profile")
                NavigationItem(icon: "gear", title: "Settings")
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct LoginPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Login Form")
                .font(.headline)
            
            VStack(spacing: 12) {
                TextField("Email", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Sign In") {}
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct EmbedMenuPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Embed Menu")
                .font(.headline)
            
            VStack(spacing: 8) {
                MenuItem(icon: "link", title: "Copy Link")
                MenuItem(icon: "square.and.arrow.up", title: "Share")
                MenuItem(icon: "doc.on.doc", title: "Duplicate")
                MenuItem(icon: "trash", title: "Delete")
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ExplorePreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Explore")
                .font(.headline)
            
            VStack(spacing: 12) {
                TextField("Search...", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Run Query") {}
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct LayoutPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Layout Elements")
                .font(.headline)
            
            VStack(spacing: 8) {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                
                HStack {
                    Text("Section Divider")
                        .font(.caption)
                    Spacer()
                }
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct GenericPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Component Preview")
                .font(.headline)
            
            Text("Select a component to see its preview")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Helper Views

struct DashboardCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
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
    
    init(icon: String, title: String, isActive: Bool = false) {
        self.icon = icon
        self.title = title
        self.isActive = isActive
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isActive ? .blue : .gray)
            Text(title)
                .foregroundColor(isActive ? .blue : .primary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isActive ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

struct MenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(title)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(6)
    }
} 