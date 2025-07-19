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
        Group {
            if viewModel.components.isEmpty {
                // Fallback view while loading
                VStack {
                    Text("Loading Zenlytic Style Editor...")
                        .font(.title)
                        .foregroundColor(.secondary)
                    ProgressView()
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                NavigationSplitView {
                    SidebarView(viewModel: viewModel)
                } content: {
                    StyleEditorView(viewModel: viewModel)
                } detail: {
                    if let selectedComponent = viewModel.selectedComponent {
                        VStack {
                            PreviewPanel(component: selectedComponent, previewMode: viewModel.previewMode)
                            SnippetOutputView(viewModel: viewModel)
                        }
                    } else {
                        Text("Select a component to edit")
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("Zenlytic Style Editor")
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
        .onAppear {
            print("ContentView: onAppear called")
        }
    }
}

#Preview {
    ContentView()
}
