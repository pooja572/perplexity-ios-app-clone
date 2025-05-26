# Perplexity iOS App Clone

A SwiftUI implementation of a Perplexity-like AI search interface for iOS.

## Download and Setup Instructions

1. Clone the repository:
```bash
git clone <repository-url>
cd PerplexitySwift
```

2. Open the Xcode project:
```bash
open PerplexitySwift.xcodeproj
```

3. In Xcode:
   - Select your development team in the Signing & Capabilities section
   - Choose a target device (iOS 15.0 or later)
   - Click the Run button (▶️) or press Cmd+R to build and run the app

## Project Structure

```
PerplexitySwift/
├── App/
│   └── PerplexityApp.swift      # Main app entry point and ContentView
├── Models/
│   └── Models.swift             # Data models
├── ViewModels/
│   └── SearchViewModel.swift    # Business logic
├── Managers/
│   ├── NetworkManager.swift     # API handling
│   ├── HapticManager.swift      # Haptic feedback
│   ├── AnimationManager.swift   # Custom animations
│   └── Theme.swift             # UI theming
```

## Features

- 🔍 Real-time AI-powered search
- 💬 Chat-like interface for search results
- 🌐 Web sources with citations
- 📱 Responsive design for all iOS devices
- 🎨 Dark/Light mode support
- 🔄 Search history tracking
- ⚡️ Smooth animations and transitions
- 📱 Haptic feedback for better UX

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Configuration

Before running the app, make sure to:

1. Update the API endpoint in `NetworkManager.swift`:
```swift
private let baseURL = "https://api.example.com" // Replace with your API endpoint
```

2. Configure your development team in Xcode:
   - Open the project settings
   - Select the target
   - Under Signing & Capabilities, select your team

## Customization

The app's appearance can be customized through:
- `Theme.swift` for colors and styling
- `AnimationManager.swift` for animations
- Settings view for user preferences

## Troubleshooting

If you encounter any issues:

1. Clean the build folder (Cmd+Shift+K)
2. Clean the build cache (Cmd+Option+Shift+K)
3. Close Xcode and delete the derived data:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```
4. Reopen the project and rebuild

## License

MIT License
