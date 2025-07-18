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
        ZStack {
            // Force a visible background
            Color.red.opacity(0.1)
                .ignoresSafeArea()
            
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
}

#Preview {
    ContentView()
}
