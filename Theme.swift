import SwiftUI

enum Theme {
    static let primaryColor = Color.blue
    static let secondaryColor = Color.purple
    static let backgroundColor = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    
    static let padding: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let iconSize: CGFloat = 24
    
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
    
    struct Shadow {
        static let small = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// Custom modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.padding)
            .background(Theme.backgroundColor)
            .cornerRadius(Theme.cornerRadius)
            .shadow(radius: 4)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, Theme.padding / 2)
            .background(Theme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(Theme.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(Theme.Animation.spring, value: configuration.isPressed)
    }
}

// View extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
