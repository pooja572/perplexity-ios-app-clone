import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case decodingFailed(Error)
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.example.com" // Replace with actual API endpoint
    private let session = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    
    private init() {
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    func fetchAIResponse(for query: String) -> AnyPublisher<AIResponse, NetworkError> {
        guard let url = URL(string: "\(baseURL)/search") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = SearchRequest(query: query)
        request.httpBody = try? JSONEncoder().encode(body)
        
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.requestFailed($0) }
            .flatMap { data, response -> AnyPublisher<AIResponse, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: AIResponse.self, decoder: self.jsonDecoder)
                    .mapError { NetworkError.decodingFailed($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// Request/Response Models
struct SearchRequest: Codable {
    let query: String
}

struct AIResponse: Codable {
    let response: String
    let sources: [APISource]
    let confidence: Double
}

struct APISource: Codable {
    let title: String
    let url: String
    let relevance: Double
    
    func toSource() -> Source {
        Source(
            title: title,
            url: URL(string: url) ?? URL(string: "https://example.com")!
        )
    }
}

// ViewModel Extension
extension SearchViewModel {
    func performAPISearch(query: String) {
        isLoading = true
        
        // Add user message immediately
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
        
        // Make API request
        NetworkManager.shared.fetchAIResponse(for: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        // Handle error - add error message to chat
                        let errorMessage = Message(
                            content: "Sorry, there was an error processing your request: \(error.localizedDescription)",
                            isUser: false,
                            sources: [],
                            timestamp: Date()
                        )
                        self?.messages.append(errorMessage)
                        HapticManager.shared.playError()
                    }
                },
                receiveValue: { [weak self] response in
                    let aiMessage = Message(
                        content: response.response,
                        isUser: false,
                        sources: response.sources.map { $0.toSource() },
                        timestamp: Date()
                    )
                    self?.messages.append(aiMessage)
                    HapticManager.shared.playSuccess()
                }
            )
            .store(in: &cancellables)
    }
}
