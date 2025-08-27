import SwiftUI

public struct BorderGradientProminentButtonStyle: ButtonStyle {

    private let scaleAmount: CGFloat

    private let animation: Animation

    public init(scaleAmount: CGFloat = 0.95, animation: Animation = .spring(response: CATransaction.animationDuration(), dampingFraction: 1, blendDuration: 0)) {
        self.scaleAmount = scaleAmount
        self.animation = animation
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(UIColor.systemBackground.swiftUI)
            .background {
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                UIColor.white.swiftUI.opacity(0.64),
                                UIColor.white.swiftUI.opacity(0.24)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ).opacity(0.24),
                        lineWidth: 1
                    )
                    .fill(UIColor.secondarySystemFill.swiftUI)
            }
            .scaleEffect(configuration.isPressed ? self.scaleAmount : 1.0)
            .animation(self.animation, value: configuration.isPressed)
    }

}

@available(iOS 17.0, *)
public extension ButtonStyle where Self == BorderGradientProminentButtonStyle {

    static var borderGradientProminentButtonStyle: BorderGradientProminentButtonStyle {
        return BorderGradientProminentButtonStyle()
    }

    static func borderGradientProminentButtonStyle(scaleAmount: CGFloat = 0.95, animation: Animation = .spring(response: CATransaction.animationDuration(), dampingFraction: 1, blendDuration: 0)) -> BorderGradientProminentButtonStyle {
        return BorderGradientProminentButtonStyle(scaleAmount: scaleAmount, animation: animation)
    }

}
