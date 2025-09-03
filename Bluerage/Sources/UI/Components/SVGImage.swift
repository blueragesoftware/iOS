import SwiftUI
import SVGKit

struct SVGImage: UIViewRepresentable {

    let data: Data

    let size: CGSize

    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(data: self.data)

        return SVGKFastImageView(svgkImage: svgImage ?? SVGKImage())
    }

    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        uiView.image = SVGKImage(data: self.data)

        uiView.image.size = self.size
    }

}
