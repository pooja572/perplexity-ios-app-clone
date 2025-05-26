import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let sources: [Source]
    let timestamp: Date
}

struct Source: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}

struct SearchHistory: Identifiable {
    let id = UUID()
    let query: String
    let timestamp: Date
}
