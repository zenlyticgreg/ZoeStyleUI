import SwiftUI

struct StyleEditorView: View {
    @ObservedObject var viewModel: StyleEditorViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let component = viewModel.selectedComponent {
                    // Component header
                    ComponentHeader(component: component)
                    
                    // Style properties
                    StylePropertiesSection(component: component, viewModel: viewModel)
                } else {
                    EmptyStateView()
                }
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Component Header
struct ComponentHeader: View {
    let component: StyleComponent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(component.label)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let comment = component.comment {
                        Text(comment)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Component type indicator
                ComponentTypeIndicator(component: component)
            }
            
            // Stats
            HStack(spacing: 24) {
                StatItem(label: "Properties", value: "\(component.keys.count)")
                StatItem(label: "Type", value: component.id.capitalized)
                StatItem(label: "Status", value: "Active")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Component Type Indicator
struct ComponentTypeIndicator: View {
    let component: StyleComponent
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Text(component.id.capitalized)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(componentColor)
        )
    }
    
    private var iconName: String {
        switch component.id {
        case "chatbox": return "message"
        case "chat": return "bubble.left.and.bubble.right"
        case "avatar": return "person.circle"
        case "dashboard": return "chart.bar"
        case "nav": return "list.bullet"
        case "login": return "person.badge.key"
        case "embed_menu": return "ellipsis.circle"
        case "explore": return "magnifyingglass"
        case "layout": return "rectangle.split.3x3"
        default: return "square"
        }
    }
    
    private var componentColor: Color {
        switch component.id {
        case "chatbox", "chat": return .blue
        case "avatar": return .purple
        case "dashboard": return .green
        case "nav": return .orange
        case "login": return .red
        case "embed_menu": return .pink
        case "explore": return .teal
        case "layout": return .gray
        default: return .blue
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Style Properties Section
struct StylePropertiesSection: View {
    let component: StyleComponent
    @ObservedObject var viewModel: StyleEditorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text("Style Properties")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Reset All") {
                    // Reset all properties
                }
                .buttonStyle(ModernButtonStyle())
            }
            
            // Properties grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(component.keys) { key in
                    StyleKeyRow(viewModel: viewModel, keyId: key.id)
                }
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintbrush")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Component Selected")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Select a component from the sidebar to start editing its styles")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

 