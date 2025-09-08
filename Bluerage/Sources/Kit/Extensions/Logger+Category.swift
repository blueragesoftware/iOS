import Foundation
import OSLog

extension Logger {

    private static let subsystem = ProcessInfo.processInfo.processName

    static let `default` = Logger(subsystem: Self.subsystem, category: "default")

    static let agentsList = Logger(subsystem: Self.subsystem, category: "agentsList")

    static let agent = Logger(subsystem: Self.subsystem, category: "agent")

    static let login = Logger(subsystem: Self.subsystem, category: "login")

    static let tools = Logger(subsystem: Self.subsystem, category: "tools")

    static let settings = Logger(subsystem: Self.subsystem, category: "settings")

}
