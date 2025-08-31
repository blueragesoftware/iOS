import UIKit

public final class HapticsManager {

    static let shared = HapticsManager()

    public init() { }

    private lazy var selectionFeedbackGenerator: UISelectionFeedbackGenerator = {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        return generator
    }()

    private lazy var notificationFeedbackGenerator: UINotificationFeedbackGenerator = {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        return generator
    }()

    public func triggerSelectionFeedback() {
        self.selectionFeedbackGenerator.selectionChanged()
        self.selectionFeedbackGenerator.prepare()
    }

    public func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    public func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        self.notificationFeedbackGenerator.notificationOccurred(type)
        self.notificationFeedbackGenerator.prepare()
    }

}
