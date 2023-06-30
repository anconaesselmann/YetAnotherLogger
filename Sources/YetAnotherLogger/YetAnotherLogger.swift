//  Created by Axel Ancona Esselmann on 6/30/23.
//

import Foundation

public enum LoggingPriority: CustomStringConvertible {
    case log(message: String)
    case debug(message: String)
    case critical(message: String)
    case temp(message: String)

    public var description: String {
        switch self {
        case .critical(message: let message), .debug(message: let message), .temp(message: let message), .log(message: let message):
            return message
        }
    }

    public var priority: String {
        switch self {
        case .log: return "LOG"
        case .debug: return "DEBUG"
        case .critical: return "CRITICAL"
        case .temp: return "TEMP"
        }
    }

    public var emoji: String {
        switch self {
        case .log: return "📜"
        case .debug: return "🪲"
        case .critical: return "‼️"
        case .temp: return "🤚"
        }
    }
}

public protocol Logging {
    var name: String { get }
    func log(_ message: String)
    func debug(_ message: String)
    func critical(_ message: String)
    func temp(_ message: String)
}

public extension Logging {
    var name: String {
        "\(type(of: self))"
    }

    func log(_ message: String) {
        Logger.shared.log(.log(message: message), sender: self)
    }

    func debug(_ message: String) {
        Logger.shared.log(.debug(message: message), sender: self)
    }

    func critical(_ message: String) {
        Logger.shared.log(.critical(message: message), sender: self)
    }

    func critical(_ error: Error) {
        Logger.shared.log(.critical(message: error.localizedDescription), sender: self)
    }

    func temp(_ message: String) {
        Logger.shared.log(.temp(message: message), sender: self)
    }
}

public class Logger {

    public var showEmoji = true
    public var assert = false

    public enum Priorities {
        case log, debug, critical, temp
    }

    public var suppressed: Set<Priorities> = []

    public static let shared = Logger()

    public func log(_ event: LoggingPriority, sender: Logging? = nil) {
        guard !suppressed.contains(event.loggerPriority) else {
            return
        }
        let sender = sender?.name ?? "Unknown"
        let emoji = showEmoji ? "\(event.emoji) - " : ""
        let message = ("\(emoji)\(event.priority) - \(sender): \(event.description)")
        if assert, case .critical = event {
            assertionFailure(message)
        } else {
            print(message)
        }
    }
}

public extension LoggingPriority {
    var loggerPriority: Logger.Priorities {
        switch self {
        case .log: return .log
        case .critical: return .critical
        case .debug: return .debug
        case .temp: return .temp
        }
    }
}

public protocol Loggable {
    var logDescription: String { get }
}

public extension Logging {
    func debug(_ loggable: Loggable) {
        self.debug(loggable.logDescription)
    }

    func debug(_ loggables: Loggable...) {
        self.debug(loggables.map{ $0.logDescription }.joined(separator: ", "))
    }
}
