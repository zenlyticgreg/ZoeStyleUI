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
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .defaultPosition(.center)
    }
}
