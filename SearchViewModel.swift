import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var searchHistory: [SearchHistory] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func performSearch(query: String) {
        isLoading = true
        
        // Add user message
        let userMessage = Message(
            content: query,
            isUser: true,
            sources: [],
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Add to search history
        let historyItem = SearchHistory(query: query, timestamp: Date())
        searchHistory.append(historyItem)
        
        // Simulate AI response (replace with actual API call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiMessage = Message(
                content: "This is a simulated AI response to your query: \(query)",
                isUser: false,
                sources: [
                    Source(
                        title: "Example Source",
                        url: URL(string: "https://example.com")!
                    )
                ],
                timestamp: Date()
            )
            
            self.messages.append(aiMessage)
            self.isLoading = false
        }
    }
}
