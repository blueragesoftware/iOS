import SwiftUI

struct LoadingView: View {

    @State private var isPulsing = true

    var body: some View {
        Image("bluerage_loading_icon_164")
            .resizable()
            .frame(width: 164, height: 164)
            .opacity(self.isPulsing ? 0.5 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    self.isPulsing.toggle()
                }
            }
    }

}
