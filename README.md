# Zenlytic Style Editor

A modern macOS SwiftUI application for visually editing Zoe interface styles with real-time preview and semantic token support.

## 🎨 Features

### Modern User Interface
- **Color Palette Picker**: Advanced color selection with preset palette and hex support
- **Real-time Preview**: Live preview of Zoe UI components in both light and dark modes
- **Component-based Editing**: Edit individual UI components (chatbox, avatar, dashboard, etc.)
- **Visual Feedback**: Immediate visual updates as you edit styles

### Style Management
- **Semantic Token Support**: Resolves design tokens to actual color values
- **JSON Integration**: Loads and saves styles from `interface_styles.json`
- **Token Palette**: Comprehensive color and design token system
- **Safe Updates**: Generate JSON snippets for safe style updates

### Supported Components
- **Chatbox**: Chat input area styling
- **Chat**: Main chat panel styling
- **Avatar**: User avatar styling
- **Dashboard**: Dashboard interface styling
- **Navigation**: Navigation elements styling
- **Login**: Authentication interface styling
- **Embed Menu**: Embed functionality styling
- **Explore**: Search and exploration interface styling

## 🚀 Getting Started

### Prerequisites
- macOS 15.5 or later
- Xcode 16.0 or later
- Swift 5.0 or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/zenlyticgreg/ZoeStyleUI.git
cd ZoeStyleUI
```

2. Open the project in Xcode:
```bash
open ZenlyticStyleEditor.xcodeproj
```

3. Build and run the application:
   - Select the "ZenlyticStyleEditor" scheme
   - Press `Cmd + R` to build and run

## 📁 Project Structure

```
ZenlyticStyleEditor/
├── Models/
│   └── StyleModels.swift          # Data models for styles and components
├── ViewModels/
│   └── StyleEditorViewModel.swift # Main view model with business logic
├── Views/
│   ├── StyleEditorView.swift      # Main style editing interface
│   ├── StyleKeyRow.swift          # Individual style property editor
│   ├── PreviewPanel.swift         # Live component preview
│   ├── SidebarView.swift          # Component selection sidebar
│   └── SnippetOutputView.swift    # JSON snippet output
├── Resources/
│   ├── interface_styles.json      # Zoe interface style definitions
│   └── token_palette.json         # Design token palette
└── ContentView.swift              # Main app interface
```

## 🎯 Usage

### Editing Styles
1. **Select a Component**: Choose a component from the sidebar
2. **Edit Properties**: Modify style properties using the modern interface
3. **Preview Changes**: See real-time updates in the preview panel
4. **Generate Snippets**: Copy JSON snippets for safe deployment

### Color Selection
- **Click Color Squares**: Open the advanced color picker
- **Use Preset Palette**: Select from 18 common colors
- **Hex Input**: Enter custom hex color values
- **Token Resolution**: See resolved semantic token values

### Preview Modes
- **Light Mode**: Preview in light theme
- **Dark Mode**: Preview in dark theme
- **Component-specific**: Each component shows realistic Zoe UI previews

## 🔧 Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive data binding
- **Semantic Tokens**: Design system integration

### Key Components
- **StyleKeyRow**: Modern card-based property editor
- **ColorPickerSheet**: Full-screen color selection
- **PreviewPanel**: Realistic Zoe UI previews
- **Token Resolution**: Semantic token to value mapping

### Data Flow
1. Load `interface_styles.json` and `token_palette.json`
2. Resolve semantic tokens to actual values
3. Present editable interface with live preview
4. Generate JSON snippets for updates

## 🎨 Design System

The app uses a comprehensive design system with:
- **Semantic Tokens**: `background.brand.primary.normal`, `text.base.level800`
- **Color Palette**: 18 preset colors + custom hex support
- **Modern UI**: Rounded corners, shadows, and smooth animations
- **Responsive Layout**: Adapts to different screen sizes

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

For support and questions:
- Create an issue on GitHub
- Contact the development team
- Check the documentation

---

**Built with ❤️ for the Zoe interface team** 