//
//  ZenlyticStyleEditorApp.swift
//  ZenlyticStyleEditor
//
//  Created by Greg Peters on 7/15/25.
//

import SwiftUI
import AppKit

@main
struct ZenlyticStyleEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        print("ZenlyticStyleEditorApp: Initializing...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("ContentView: onAppear in WindowGroup")
                }
                .frame(minWidth: 1200, minHeight: 800)
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
                    print("ContentView: Window became key")
                }
        }
        .defaultSize(width: 1200, height: 800)
        .defaultPosition(.center)
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("AppDelegate: applicationDidFinishLaunching")
        
        // Set the app to be a regular application (not a background app)
        NSApplication.shared.setActivationPolicy(.regular)
        
        // Activate the app and bring it to front
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Ensure window is visible after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.makeWindowVisible()
        }
    }
    
    private func makeWindowVisible() {
        print("AppDelegate: makeWindowVisible called")
        
        // Get all windows and make sure they're visible
        for window in NSApplication.shared.windows {
            print("AppDelegate: Making window visible: \(window.title)")
            window.delegate = self
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            window.level = .normal
        }
        
        // If no windows found, create one
        if NSApplication.shared.windows.isEmpty {
            print("AppDelegate: No windows found, creating one")
            let window = NSWindow(
                contentRect: NSRect(x: 100, y: 100, width: 1200, height: 800),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.contentView = NSHostingView(rootView: ContentView())
            window.title = "Zenlytic Style Editor"
            window.delegate = self
            window.makeKeyAndOrderFront(nil)
            window.center()
        }
        
        // Force the app to be active and in front
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Bring the app to front again
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApplication.shared.activate(ignoringOtherApps: true)
            for window in NSApplication.shared.windows {
                window.orderFrontRegardless()
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        print("AppDelegate: applicationShouldHandleReopen, hasVisibleWindows: \(flag)")
        
        if !flag {
            makeWindowVisible()
        } else {
            // Even if windows exist, make sure they're visible
            NSApplication.shared.activate(ignoringOtherApps: true)
            for window in NSApplication.shared.windows {
                window.makeKeyAndOrderFront(nil)
            }
        }
        
        return true
    }
    
    // MARK: - NSWindowDelegate
    
    func windowDidBecomeKey(_ notification: Notification) {
        print("AppDelegate: windowDidBecomeKey")
    }
    
    func windowDidResignKey(_ notification: Notification) {
        print("AppDelegate: windowDidResignKey")
    }
    
    func windowWillClose(_ notification: Notification) {
        print("AppDelegate: windowWillClose")
        // Quit the app when the main window is closed
        NSApplication.shared.terminate(nil)
    }
}
