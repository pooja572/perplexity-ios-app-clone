import SwiftUI
import CoreHaptics

class HapticManager {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    
    private init() {
        setupEngine()
    }
    
    private func setupEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine creation error: \(error.localizedDescription)")
        }
    }
    
    func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func playError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    func playCustom() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}

// SwiftUI View extension for haptics
extension View {
    func hapticFeedback(_ type: HapticType = .selection) -> some View {
        self.simultaneousGesture(TapGesture().onEnded { _ in
            switch type {
            case .success:
                HapticManager.shared.playSuccess()
            case .error:
                HapticManager.shared.playError()
            case .selection:
                HapticManager.shared.playSelection()
            case .custom:
                HapticManager.shared.playCustom()
            }
        })
    }
}

enum HapticType {
    case success
    case error
    case selection
    case custom
}
