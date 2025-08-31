import SwiftUI

struct PlaceholderView<ButtonLabel>: View where ButtonLabel: View {

    typealias ButtonConfiguration = (action: () -> Void, buttonLabel: () -> ButtonLabel)

    private enum ImageType {
        case systemName(String)
        case named(String)
    }

    private let imageType: ImageType

    private let title: LocalizedStringKey

    private let description: LocalizedStringKey

    private let buttonConfiguration: ButtonConfiguration?

    init(imageSystemName: String,
         title: LocalizedStringKey,
         description: LocalizedStringKey,
         action: @escaping () -> Void,
         @ViewBuilder buttonLabel: @escaping () -> ButtonLabel) {
        self.imageType = .systemName(imageSystemName)
        self.title = title
        self.description = description
        self.buttonConfiguration = ButtonConfiguration(action, buttonLabel)
    }

    init(imageName: String,
         title: LocalizedStringKey,
         description: LocalizedStringKey,
         action: @escaping () -> Void,
         @ViewBuilder buttonLabel: @escaping () -> ButtonLabel) {
        self.imageType = .named(imageName)
        self.title = title
        self.description = description
        self.buttonConfiguration = ButtonConfiguration(action, buttonLabel)
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch self.imageType {
                case .systemName(let name):
                    Image(systemName: name)
                        .resizable()
                        .foregroundStyle(UIColor.label.swiftUI)
                case .named(let name):
                    Image(name)
                        .resizable()
                }
            }
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

extension PlaceholderView where ButtonLabel == Never {

    init(imageSystemName: String,
         title: LocalizedStringKey,
         description: LocalizedStringKey,
         buttonConfiguration: ButtonConfiguration? = nil) {
        self.imageType = .systemName(imageSystemName)
        self.title = title
        self.description = description
        self.buttonConfiguration = buttonConfiguration
    }

    init(imageName: String,
         title: LocalizedStringKey,
         description: LocalizedStringKey,
         buttonConfiguration: ButtonConfiguration? = nil) {
        self.imageType = .named(imageName)
        self.title = title
        self.description = description
        self.buttonConfiguration = buttonConfiguration
    }

}

extension PlaceholderView where ButtonLabel == AnyView {

    static func error(action: @escaping () -> Void) -> some View {
        PlaceholderView(imageName: "issue_placeholder_icon_100",
                        title: "common_issue_happened",
                        description: "common_resolve_issue_suggest") {
            action()
        } buttonLabel: {
            AnyView(Text("common_refresh")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(UIColor.label.swiftUI)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .fixedSize())
        }
        .buttonStyle(.borderGradientProminentButtonStyle)
    }

}
