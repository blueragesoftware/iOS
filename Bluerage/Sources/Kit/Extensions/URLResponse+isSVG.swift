import Foundation

extension URLResponse {

    var isSVG: Bool {
        return self.mimeType == "image/svg+xml"
    }

}
