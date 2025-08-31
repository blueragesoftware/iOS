import SwiftUI

@MainActor
@Observable
final class ToolsSelectionScreenViewModel {
    
    enum State {
        case loading
        case loaded([Tool])
        case empty
        case error(Error)
    }
    
    private(set) var state: State = .loading
    
    init() {
        // Initialize with loading state
    }
    
    func loadTools() async {
        self.state = .loading
        
        do {
            // Simulate API call delay
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Mock data for now - replace with actual API call
            let mockTools = [
                Tool(id: "web_search", name: "Web Search"),
                Tool(id: "file_manager", name: "File Manager"),
                Tool(id: "calendar", name: "Calendar"),
                Tool(id: "email", name: "Email"),
                Tool(id: "calculator", name: "Calculator"),
                Tool(id: "weather", name: "Weather"),
                Tool(id: "translator", name: "Translator"),
                Tool(id: "image_generator", name: "Image Generator"),
                Tool(id: "code_executor", name: "Code Executor"),
                Tool(id: "database", name: "Database"),
            ]
            
            if mockTools.isEmpty {
                self.state = .empty
            } else {
                self.state = .loaded(mockTools)
            }
        } catch {
            self.state = .error(error)
        }
    }
}