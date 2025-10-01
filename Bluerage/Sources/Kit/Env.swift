import Foundation

final class Env {

    private enum Error: Swift.Error {
        case missingKey(String)
        case invalidValue(Any, key: String)
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.module.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey(key)
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue(object, key: key)
        }
    }

    private(set) lazy var POSTHOG_API_KEY: String = {
        do {
            return try Self.value(for: "POSTHOG_API_KEY")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    private(set) lazy var POSTHOG_HOST: String = {
        do {
            return try Self.value(for: "POSTHOG_HOST")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    private(set) lazy var SENTRY_DSN: String = {
        do {
            return try Self.value(for: "SENTRY_DSN")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    private(set) lazy var CONVEX_DEPLOYMENT_URL: String = {
        do {
            return try Self.value(for: "CONVEX_DEPLOYMENT_URL")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    private(set) lazy var CLERK_PUBLISHABLE_KEY: String = {
        do {
            return try Self.value(for: "CLERK_PUBLISHABLE_KEY")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    private(set) lazy var KNOCK_PUBLISHABLE_KEY: String = {
        do {
            return try Self.value(for: "KNOCK_PUBLISHABLE_KEY")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    private(set) lazy var KNOCK_CHANNEL_ID: String = {
        do {
            return try Self.value(for: "KNOCK_CHANNEL_ID")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
}
