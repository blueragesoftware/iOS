import Foundation
import OSLog

extension Logger {

    static let subsystem = ProcessInfo.processInfo.processName

    static let agentsList = Logger(subsystem: Self.subsystem, category: "agentsList")
    
    static let agent = Logger(subsystem: Self.subsystem, category: "agent")

}
