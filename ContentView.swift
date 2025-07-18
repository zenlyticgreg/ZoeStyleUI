//
//  ContentView.swift
//  ZenlyticStyleEditor
//
//  Created by Greg Peters on 7/15/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StyleEditorViewModel()
    
    init() {
        print("ContentView: Initializing...")
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
        } content: {
            StyleEditorView(viewModel: viewModel)
        } detail: {
            if let selectedComponent = viewModel.selectedComponent {
                VStack {
                    PreviewPanel(component: selectedComponent, previewMode: viewModel.previewMode)
                    SnippetOutputView(
                        styleSnippet: viewModel.snippetForSelectedComponent(),
                        tokenSnippet: viewModel.snippetForChangedTokens()
                    )
                }
            } else {
                Text("Select a component to edit")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Zenlytic Style Editor")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("Preview Mode", selection: $viewModel.previewMode) {
                    Text("Light").tag(PreviewMode.light)
                    Text("Dark").tag(PreviewMode.dark)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

#Preview {
    ContentView()
}
