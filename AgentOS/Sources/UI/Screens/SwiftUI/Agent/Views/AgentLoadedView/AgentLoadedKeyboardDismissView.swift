import SwiftUI

struct AgentLoadedKeyboardDismissView: View {
    
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        if self.isFocused {
            VStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    Button {
                        self.isFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down.fill")
                            .foregroundStyle(.white)
                            .padding()
                    }
                    .buttonStyle(.borderGradientProminentButtonStyle)
                    .padding()
                }
            }
        }
    }
    
}
