import Nuke

extension ImageDecoders {

    static func registerSVGDecoder() {
        ImageDecoderRegistry.shared.register { context in
            let isSVG = context.urlResponse?.url?.absoluteString.hasSuffix(".svg") ?? false
            return isSVG ? ImageDecoders.Empty() : nil
        }
    }

}
