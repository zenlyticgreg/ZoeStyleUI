import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: StyleEditorViewModel
    @State private var selectedComponentId: String?
    @State private var selectedSubcomponentId: String?
    @State private var expandedComponents: Set<String> = []

    var body: some View {
        List {
            ForEach(viewModel.components) { component in
                ComponentRowView(
                    component: component,
                    isSelected: selectedComponentId == component.id,
                    isExpanded: expandedComponents.contains(component.id),
                    selectedSubcomponentId: selectedSubcomponentId,
                    onComponentSelect: { component in
                        selectedComponentId = component.id
                        selectedSubcomponentId = nil
                        viewModel.selectComponent(component)
                    },
                    onSubcomponentSelect: { subcomponent in
                        selectedSubcomponentId = subcomponent.id
                        viewModel.selectSubcomponent(subcomponent)
                    },
                    onToggleExpansion: { componentId in
                        if expandedComponents.contains(componentId) {
                            expandedComponents.remove(componentId)
                        } else {
                            expandedComponents.insert(componentId)
                        }
                    }
                )
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
        .onAppear {
            // Set initial selection if none is selected
            if viewModel.selectedComponent == nil && !viewModel.components.isEmpty {
                selectedComponentId = viewModel.components.first?.id
                if let firstComponent = viewModel.components.first {
                    viewModel.selectComponent(firstComponent)
                }
            } else if let selectedComponent = viewModel.selectedComponent {
                selectedComponentId = selectedComponent.id
            }
        }
    }
}

struct ComponentRowView: View {
    let component: StyleComponent
    let isSelected: Bool
    let isExpanded: Bool
    let selectedSubcomponentId: String?
    let onComponentSelect: (StyleComponent) -> Void
    let onSubcomponentSelect: (StyleSubcomponent) -> Void
    let onToggleExpansion: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main component row
            HStack {
                Button(action: {
                    onToggleExpansion(component.id)
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(component.subcomponents.isEmpty ? 0 : 1)
                
                Button(action: {
                    onComponentSelect(component)
                }) {
                    HStack {
                        Image(systemName: "square.3.layers.3d")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(component.label)
                            .font(.system(size: 14, weight: .medium))
                        
                        Spacer()
                        
                        if !component.subcomponents.isEmpty {
                            Text("\(component.subcomponents.count)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(isSelected ? .primary : .secondary)
                .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                .cornerRadius(6)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            
            // Subcomponents (if expanded)
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(component.subcomponents) { subcomponent in
                        SubcomponentRowView(
                            subcomponent: subcomponent,
                            isSelected: selectedSubcomponentId == subcomponent.id,
                            onSelect: {
                                onSubcomponentSelect(subcomponent)
                            }
                        )
                    }
                }
                .padding(.leading, 20)
            }
        }
    }
}

struct SubcomponentRowView: View {
    let subcomponent: StyleSubcomponent
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.system(size: 4))
                    .foregroundColor(.secondary)
                
                Text(subcomponent.label)
                    .font(.system(size: 13))
                
                Spacer()
                
                Text("\(subcomponent.keys.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(6)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isSelected ? .primary : .secondary)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(4)
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
    }
} 