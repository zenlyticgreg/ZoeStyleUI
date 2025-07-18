import SwiftUI

struct SnippetOutputView: View {
    let styleSnippet: String
    let tokenSnippet: String
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            Picker("Snippet Type", selection: $selectedTab) {
                Text("Component Styles").tag(0)
                Text("Palette Tokens").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 4)
            if selectedTab == 0 {
                Text("JSON Snippet to Copy (Component Styles):")
                    .font(.headline)
                ScrollView(.horizontal) {
                    Text(styleSnippet)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                }
                Button("Copy to Clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(styleSnippet, forType: .string)
                }
                .padding(.top, 4)
            } else {
                Text("JSON Snippet to Copy (Palette Tokens):")
                    .font(.headline)
                ScrollView(.horizontal) {
                    Text(tokenSnippet)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                }
                Button("Copy to Clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(tokenSnippet, forType: .string)
                }
                .padding(.top, 4)
            }
        }
        .padding()
    }
} 