import Foundation

extension String {

    var localized: String {
        return String(localized: LocalizedStringResource(stringLiteral: self))
    }

}
