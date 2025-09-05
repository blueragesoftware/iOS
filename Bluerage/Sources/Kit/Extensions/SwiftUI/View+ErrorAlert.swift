import SwiftUI

private struct LocalizedErrorProxy: LocalizedError {

    var errorDescription: String? {
        self.underlyingError.errorDescription
    }

    var recoverySuggestion: String? {
        self.underlyingError.recoverySuggestion
    }

    let underlyingError: LocalizedError

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else {
            return nil
        }

        self.underlyingError = localizedError
    }
}

extension View {

    func errorAlert(error: Binding<Error?>,
                    buttonTitle: String = "common_ok".localized) -> some View {
        return errorAlert(error: error.wrappedValue, buttonTitle: buttonTitle) {
            error.wrappedValue = nil
        }
    }

    @ViewBuilder
    func errorAlert(error: Error?,
                    buttonTitle: String = "common_ok".localized,
                    action: @escaping () -> Void) -> some View {
        let localizedError = LocalizedErrorProxy(error: error)

        if let localizedError {
            alert(isPresented: .constant(true),
                  error: localizedError) { _ in
                Button(buttonTitle) {
                    action()
                }
            } message: { error in
                Text(error.recoverySuggestion ?? error.localizedDescription)
            }
        } else {
            alert("common_error".localized,
                  isPresented: .constant(error != nil),
                  presenting: error) { _ in
                Button(buttonTitle) {
                    action()
                }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }

}
