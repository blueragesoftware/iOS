import SwiftUI

@available(iOS 17.0, *)
public struct PlaceholderView<ButtonLabel>: View where ButtonLabel: View {

    public typealias ButtonConfiguration = (action: () -> Void, buttonLabel: () -> ButtonLabel)

    let imageSystemName: String

    let title: LocalizedStringKey

    let description: LocalizedStringKey

    let buttonConfiguration: ButtonConfiguration?

    public init(imageSystemName: String,
                title: LocalizedStringKey,
                description: LocalizedStringKey,
                action: @escaping () -> Void,
                @ViewBuilder buttonLabel: @escaping () -> ButtonLabel) {
        self.imageSystemName = imageSystemName
        self.title = title
        self.description = description
        self.buttonConfiguration = ButtonConfiguration(action, buttonLabel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image(systemName: self.imageSystemName)
                .resizable()
                .foregroundStyle(UIColor.label.swiftUI)
                .frame(width: 100, height: 100)

            Text(self.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(UIColor.label.swiftUI)
                .padding(.top, 16)

            Text(self.description)
                .font(.system(size: 17, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundStyle(UIColor.tertiaryLabel.swiftUI)
                .padding(.top, 8)

            if let buttonConfiguration {
                Button {
                    buttonConfiguration.action()
                } label: {
                    buttonConfiguration.buttonLabel()
                }
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: 305)
    }

}

@available(iOS 17.0, *)
extension PlaceholderView where ButtonLabel == Never {

    public init(imageSystemName: String,
                title: LocalizedStringKey,
                description: LocalizedStringKey,
                buttonConfiguration: ButtonConfiguration? = nil) {
        self.imageSystemName = imageSystemName
        self.title = title
        self.description = description
        self.buttonConfiguration = buttonConfiguration
    }

}
