import SwiftUI

struct AnimationManager {
    // Message animations
    static func messageEntrance(index: Int) -> Animation {
        Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)
            .delay(Double(index) * 0.1)
    }
    
    // Custom transition for messages
    struct MessageTransition: ViewModifier {
        let isPresented: Bool
        
        func body(content: Content) -> some View {
            content
                .opacity(isPresented ? 1 : 0)
                .scaleEffect(isPresented ? 1 : 0.8)
                .offset(y: isPresented ? 0 : 20)
        }
    }
    
    // Loading animation
    struct PulsatingDots: View {
        @State private var isAnimating = false
        
        var body: some View {
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Theme.primaryColor)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .opacity(isAnimating ? 1 : 0.3)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
    
    // Typing animation
    struct TypingAnimation: View {
        let text: String
        @State private var displayedText = ""
        @State private var isAnimating = false
        
        var body: some View {
            Text(displayedText)
                .onAppear {
                    animateText()
                }
        }
        
        private func animateText() {
            var charIndex = 0
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                if charIndex < text.count {
                    let index = text.index(text.startIndex, offsetBy: charIndex)
                    displayedText += String(text[index])
                    charIndex += 1
                    HapticManager.shared.playSelection()
                } else {
                    timer.invalidate()
                }
            }
        }
    }
    
    // Search bar animation
    struct SearchBarAnimation: ViewModifier {
        @Binding var isSearching: Bool
        
        func body(content: Content) -> some View {
            content
                .scaleEffect(isSearching ? 0.95 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSearching)
        }
    }
}

// Custom view modifiers
extension View {
    func messageTransition(isPresented: Bool) -> some View {
        modifier(AnimationManager.MessageTransition(isPresented: isPresented))
    }
    
    func searchBarAnimation(isSearching: Binding<Bool>) -> some View {
        modifier(AnimationManager.SearchBarAnimation(isSearching: isSearching))
    }
}

// Enhanced MessageView with animations
struct AnimatedMessageView: View {
    let message: Message
    let index: Int
    @State private var isPresented = false
    
    var body: some View {
        MessageView(message: message)
            .messageTransition(isPresented: isPresented)
            .onAppear {
                withAnimation(AnimationManager.messageEntrance(index: index)) {
                    isPresented = true
                }
            }
    }
}

// Loading indicator with custom animation
struct LoadingIndicator: View {
    var body: some View {
        VStack {
            AnimationManager.PulsatingDots()
            Text("Thinking...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}

// Animated search bar
struct AnimatedSearchBar: View {
    @Binding var text: String
    @State private var isSearching = false
    let onSubmit: () -> Void
    
    var body: some View {
        SearchBar(text: $text, onSubmit: {
            withAnimation {
                isSearching = true
            }
            onSubmit()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isSearching = false
                }
            }
        })
        .searchBarAnimation(isSearching: $isSearching)
    }
}
