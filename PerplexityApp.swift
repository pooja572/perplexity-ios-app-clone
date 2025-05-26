import SwiftUI

@main
struct PerplexityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @State private var showingHistory = false
    @State private var showingSettings = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                AnimatedSearchBar(text: $searchText) {
                    viewModel.performAPISearch(query: searchText)
                }
                .padding()
                .cardStyle()
                .padding(.horizontal)
                
                // Chat Interface
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            AnimatedMessageView(message: message, index: index)
                        }
                        
                        if viewModel.isLoading {
                            LoadingIndicator()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Perplexity")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gear")
                            .hapticFeedback()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingHistory.toggle() }) {
                        Image(systemName: "clock.fill")
                            .hapticFeedback()
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(searches: viewModel.searchHistory)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

// Enhanced Message View Component
struct MessageView: View {
    let message: Message
    @State private var showingSources = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: message.isUser ? "person.circle.fill" : "brain.head.profile")
                    .foregroundColor(message.isUser ? Theme.primaryColor : Theme.secondaryColor)
                    .font(.title2)
                
                Text(message.isUser ? "You" : "AI")
                    .font(.headline)
                
                Spacer()
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.isUser {
                Text(message.content)
                    .padding()
                    .background(Theme.primaryColor.opacity(0.1))
                    .cornerRadius(Theme.cornerRadius)
            } else {
                AnimationManager.TypingAnimation(text: message.content)
                    .padding()
                    .background(Theme.secondaryColor.opacity(0.1))
                    .cornerRadius(Theme.cornerRadius)
            }
            
            if !message.sources.isEmpty {
                Button(action: { showingSources.toggle() }) {
                    HStack {
                        Text("\(message.sources.count) Sources")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: showingSources ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .hapticFeedback()
                
                if showingSources {
                    SourcesView(sources: message.sources)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadius)
        .shadow(radius: 2)
    }
}

// Enhanced Sources View Component
struct SourcesView: View {
    let sources: [Source]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(sources) { source in
                Link(destination: source.url) {
                    HStack {
                        Text(source.title)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                }
                .font(.caption)
                .foregroundColor(Theme.primaryColor)
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

// Enhanced History View Component
struct HistoryView: View {
    let searches: [SearchHistory]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searches.reversed()) { search in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(search.query)
                            .font(.headline)
                        
                        Text(search.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .hapticFeedback()
                }
            }
            .navigationTitle("Search History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .hapticFeedback()
                }
            }
        }
    }
}

// Settings View Component
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useHaptics") private var useHaptics = true
    @AppStorage("useAnimations") private var useAnimations = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Enable Haptics", isOn: $useHaptics)
                    Toggle("Enable Animations", isOn: $useAnimations)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .hapticFeedback()
                }
            }
        }
    }
}
