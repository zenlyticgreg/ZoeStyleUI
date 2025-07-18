//
//  ZenlyticStyleEditorApp.swift
//  ZenlyticStyleEditor
//
//  Created by Greg Peters on 7/15/25.
//

import SwiftUI

@main
struct ZenlyticStyleEditorApp: App {
    init() {
        print("ZenlyticStyleEditorApp: Initializing...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("ContentView: onAppear called")
                    // Force window to front
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NSApp.activate(ignoringOtherApps: true)
                        if let window = NSApp.windows.first {
                            window.makeKeyAndOrderFront(nil)
                            window.orderFrontRegardless()
                            print("Window: Forced to front - frame: \(window.frame)")
                        }
                    }
                }
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .defaultPosition(.center)
    }
}
