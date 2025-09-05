import SwiftUI
import MarkdownUI

struct ExecutionLoadedContentView: View {

    let state: ExecutionTask.State

    var body: some View {
        Section {
            switch self.state {
            case .registered, .running:
                ProgressView()
            case .error(let error):
                Text(error)
            case .success(let result):
                Markdown(result)
            }
        } header: {
            Text("Result")
        }
    }
}
