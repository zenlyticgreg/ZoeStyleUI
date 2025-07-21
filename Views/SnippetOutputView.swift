import SwiftUI

struct SnippetOutputView: View {
    @ObservedObject var viewModel: StyleEditorViewModel
    @State private var refreshID = UUID()
    @State private var displayedSnippet: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("JSON Output:")
                .font(.headline)
            
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading) {
                    // Display with line numbers (like a code editor)
                    HStack(alignment: .top, spacing: 0) {
                        // Line numbers column
                        VStack(alignment: .trailing, spacing: 0) {
                            ForEach(Array(displayedSnippet.components(separatedBy: .newlines).enumerated()), id: \.offset) { index, line in
                                // Calculate the actual line number from the original Zoe JSON file
                                let actualLineNumber = (viewModel.selectedComponent?.startLineNumber ?? 1) + index
                                Text("\(actualLineNumber)")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, alignment: .trailing)
                                    .padding(.trailing, 8)
                                    .padding(.vertical, 2)
                            }
                        }
                        .background(Color(.controlBackgroundColor).opacity(0.5))
                        
                        // JSON content with syntax highlighting
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(displayedSnippet.components(separatedBy: .newlines).enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
                    .frame(minWidth: 600, maxWidth: .infinity, alignment: .leading)
                    .id("\(displayedSnippet)-\(refreshID)") // Force refresh when content changes
                    .onChange(of: viewModel.currentSnippet) { oldValue, newValue in
                        print("SnippetOutputView: currentSnippet changed")
                        print("SnippetOutputView: Old snippet length: \(oldValue.count)")
                        print("SnippetOutputView: New snippet length: \(newValue.count)")
                        print("SnippetOutputView: New snippet preview: \(String(newValue.prefix(100)))...")
                        print("SnippetOutputView: Old and new are equal: \(oldValue == newValue)")
                        print("SnippetOutputView: Full new snippet: \(newValue)")
                        displayedSnippet = newValue
                        refreshID = UUID() // Force a complete refresh
                        print("SnippetOutputView: Updated displayedSnippet and refreshID")
                    }
                    .onAppear {
                        displayedSnippet = viewModel.currentSnippet
                        print("SnippetOutputView: Text view appeared with snippet length: \(displayedSnippet.count)")
                    }
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
                    NSPasteboard.general.setString(displayedSnippet, forType: .string)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .onAppear {
            displayedSnippet = viewModel.currentSnippet
            print("SnippetOutputView: onAppear")
        }
        .onChange(of: viewModel.selectedComponent?.id) { oldId, newId in
            print("SnippetOutputView: selectedComponent changed from \(oldId ?? "nil") to \(newId ?? "nil")")
            displayedSnippet = viewModel.currentSnippet
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
            displayedSnippet = viewModel.currentSnippet
        }
    }
} 