import Nuke
import Foundation

extension AssetType {

    static var svg: AssetType {
        "public.svg-image"
    }

}

extension ImageDecoders {

    private struct SVG: ImageDecoding, Sendable {

        private let assetType: AssetType = .svg

        public var isAsynchronous: Bool { false }

        public func decode(_ data: Data) throws -> ImageContainer {
            ImageContainer(image: PlatformImage(), type: self.assetType, data: data, userInfo: [:])
        }

    }

    static func registerSVGDecoder() {
        ImageDecoderRegistry.shared.register { context in
            let isSVG = context.urlResponse?.isSVG ?? false
            return isSVG ? ImageDecoders.SVG() : nil
        }
    }

}
