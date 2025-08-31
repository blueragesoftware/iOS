import SwiftUI

struct ToolsSelectionScreenView: View {
    
    @State private var viewModel = ToolsSelectionScreenViewModel()

    @Environment(\.dismiss) private var dismiss
    
    private let onToolSelected: (Tool) -> Void

    init(onToolSelected: @escaping (Tool) -> Void) {
        self.onToolSelected = onToolSelected
    }
    
    var body: some View {
        NavigationView {
            self.content
                .navigationTitle("Select a Tool")
                .navigationBarTitleDisplayMode(.inline)
                .onFirstAppear {
                    Task {
                        await self.viewModel.loadTools()
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            ToolsSelectionLoadingView()
        case .loaded(let tools):
            ToolsSelectionLoadedView(
                tools: tools,
                onToolSelected: { tool in
                    self.onToolSelected(tool)
                    self.dismiss()
                }
            )
        case .empty:
            ToolsSelectionEmptyView()
        case .error:
            ToolsSelectionErrorView {
                Task {
                    await self.viewModel.loadTools()
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct ToolsSelectionLoadingView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()

            Text("Loading tools...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

struct ToolsSelectionLoadedView: View {
    
    let tools: [Tool]

    let onToolSelected: (Tool) -> Void
    
    var body: some View {
        List(self.tools) { tool in
            Button {
                self.onToolSelected(tool)
            } label: {
                HStack {
                    Text(tool.name)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.blue)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

struct ToolsSelectionEmptyView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Tools Available")
                .font(.headline)
            
            Text("There are currently no tools available to add to your agent.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

struct ToolsSelectionErrorView: View {
    
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text("Failed to Load Tools")
                .font(.headline)
            
            Text("An error occurred while loading the available tools.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                self.onRetry()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

#Preview {
    ToolsSelectionScreenView { tool in
        print("Selected tool: \(tool.name)")
    }
}
