# Zenlytic Style Editor

A macOS SwiftUI application for editing interface styles and generating style snippets.

## Features

- Visual style editor for interface components
- Real-time preview of style changes
- JSON snippet generation
- Color picker integration
- Border radius controls
- Token-based styling system

## Running the App

### From Xcode (Recommended)

1. Open `ZenlyticStyleEditor.xcodeproj` in Xcode
2. Select the "ZenlyticStyleEditor" target
3. Choose your Mac as the destination device
4. Click the "Run" button (▶️) or press `Cmd+R`

The app should launch and display the style editor interface.

### Troubleshooting Launch Issues

If the app doesn't launch from Xcode, try these steps:

1. **Clean Build Folder**: In Xcode, go to `Product` → `Clean Build Folder` (or press `Cmd+Shift+K`)
2. **Reset Package Caches**: In Xcode, go to `File` → `Packages` → `Reset Package Caches`
3. **Check Code Signing**: Ensure code signing is set to "Manual" in the project settings
4. **Verify Entitlements**: The app uses minimal entitlements to avoid sandboxing issues

### Debugger Stopping on Launch (Permanent Fix)

If Xcode stops at a breakpoint when launching the app:

#### Quick Fix:
- **Click the Continue button (▶️)** in the debugger toolbar
- Or press **Cmd+Option+P** to continue execution

#### Permanent Fix:
1. **Run the reset script**: `./reset_xcode_debugger.sh`
2. **Close Xcode completely**
3. **Reopen the project**
4. **Run the app** - it should launch without stopping

#### Manual Fix:
1. **Remove All Breakpoints**: Debug → Breakpoints → Remove All Breakpoints
2. **Toggle Breakpoints Off**: Press **Cmd+Y** to disable breakpoints
3. **Check Exception Breakpoints**: In Breakpoint Navigator, disable any exception breakpoints

### Recent Fixes Applied

The following changes were made to ensure the app launches properly from Xcode:

- **Code Signing**: Changed from "Automatic" to "Manual" to avoid signing issues
- **Hardened Runtime**: Disabled to prevent launch restrictions
- **Development Team**: Removed to avoid team-specific signing requirements
- **Bundle Identifier**: Updated to `com.zenlytic.styleeditor`
- **App Delegate**: Simplified window management to prevent launch hangs
- **Info.plist**: Added explicit Info.plist file for proper app metadata
- **Debugger Configuration**: Added settings to prevent unwanted debugger stops

## Project Structure

```
ZenlyticStyleEditor/
├── Models/
│   └── StyleModels.swift          # Data models for styles and components
├── ViewModels/
│   └── StyleEditorViewModel.swift # Main view model and business logic
├── Views/
│   ├── StyleEditorView.swift      # Main editor interface
│   ├── SidebarView.swift          # Component selection sidebar
│   ├── PreviewPanel.swift         # Live preview of selected component
│   ├── SnippetOutputView.swift    # JSON snippet output
│   ├── PaletteEditorView.swift    # Color palette editor
│   └── StyleKeyRow.swift          # Individual style key editor
├── Resources/
│   ├── interface_styles.json      # Sample interface styles
│   └── token_palette.json         # Color and token definitions
├── Assets.xcassets/               # App icons and assets
├── ContentView.swift              # Main content view
├── ZenlyticStyleEditorApp.swift   # App entry point
├── Info.plist                     # App metadata
└── reset_xcode_debugger.sh        # Script to reset debugger state
```

## Development

The app is built with SwiftUI and follows the MVVM pattern:

- **Models**: Define the data structures for styles, components, and tokens
- **ViewModels**: Handle business logic and state management
- **Views**: Provide the user interface using SwiftUI

### Key Components

- **StyleEditorViewModel**: Manages the main app state, loads data, and handles style updates
- **StyleComponent**: Represents a UI component with configurable style keys
- **StyleKey**: Individual style properties (colors, border radius, etc.)
- **Token System**: References to predefined design tokens for consistent styling

## Data Files

The app loads two main JSON files:

1. **interface_styles.json**: Contains component definitions with their style keys
2. **token_palette.json**: Contains the design token system (colors, spacing, etc.)

These files are bundled with the app and loaded at startup.

## Requirements

- macOS 15.5 or later
- Xcode 16.4 or later
- Swift 5.0+ 