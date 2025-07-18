import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: StyleEditorViewModel

    var body: some View {
        List(viewModel.components, selection: $viewModel.selectedComponent) { component in
            Text(component.label)
                .help(component.comment ?? "")
                .tag(component)
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 180, idealWidth: 220, maxWidth: 250)
    }
} 