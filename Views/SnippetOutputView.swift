import SwiftUI

struct SnippetOutputView: View {
    @ObservedObject var viewModel: StyleEditorViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("JSON Output:")
                .font(.headline)
            
            ScrollView(.horizontal) {
                Text(viewModel.currentSnippet)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                    .onChange(of: viewModel.currentSnippet) { oldValue, newValue in
                        print("SnippetOutputView: currentSnippet changed")
                        print("SnippetOutputView: Old snippet: \(oldValue)")
                        print("SnippetOutputView: New snippet: \(newValue)")
                    }
            }
            .onChange(of: viewModel.changedTokens.count) { _, _ in
                print("SnippetOutputView: changedTokens count changed")
            }
            .onChange(of: viewModel.selectedComponent?.keys.count) { _, _ in
                print("SnippetOutputView: selectedComponent keys count changed")
            }
            .onChange(of: viewModel.selectedComponent?.keys.first?.value) { _, _ in
                print("SnippetOutputView: selectedComponent first key value changed")
            }
            
            HStack {
                Button("Copy to Clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(viewModel.currentSnippet, forType: .string)
                }
                
                Button("Test Update") {
                    print("SnippetOutputView: Manual test update triggered")
                    print("SnippetOutputView: Current snippet: \(viewModel.currentSnippet)")
                    print("SnippetOutputView: Selected component: \(viewModel.selectedComponent?.id ?? "nil")")
                    if let component = viewModel.selectedComponent {
                        print("SnippetOutputView: Component keys: \(component.keys.map { "\($0.id)=\($0.value)" })")
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .onAppear {
            print("SnippetOutputView: onAppear")
        }
        .onChange(of: viewModel.selectedComponent?.id) { oldId, newId in
            print("SnippetOutputView: selectedComponent changed from \(oldId ?? "nil") to \(newId ?? "nil")")
        }
        .onChange(of: viewModel.selectedComponent?.keys) { oldKeys, newKeys in
            print("SnippetOutputView: selectedComponent keys changed")
            print("SnippetOutputView: Old keys count: \(oldKeys?.count ?? 0)")
            print("SnippetOutputView: New keys count: \(newKeys?.count ?? 0)")
            if let newKeys = newKeys {
                for key in newKeys {
                    print("SnippetOutputView: Key \(key.id) = \(key.value)")
                }
            }
        }
    }
} 