import Foundation

private protocol CancellableOperation {

    func cancelOperation()

}

extension Task: CancellableOperation {

    fileprivate func cancelOperation() {
        self.cancel()
    }

}

final class KeyedExecutor: @unchecked Sendable {

#if compiler(>=6.0)
    typealias ThrowingOperation<Success> = @isolated(any) @Sendable () async throws -> sending Success
    typealias Operation<Success> = @isolated(any) @Sendable () async -> sending Success
#else
    typealias ThrowingOperation<Success: Sendable> = @Sendable () async throws -> Success
    typealias Operation<Success: Sendable> = @Sendable () async -> Success
#endif

    private var tasks: [String: CancellableOperation] = [:]

    private let lock = NSLock()

    @discardableResult
    func executeOperation<Success>(for key: String,
                                   @_inheritActorContext operation: @escaping Operation<Success>) async -> Success {
        let task = self.lock.withLock {
            if let existingTask = self.tasks[key] as? Task<Success, Never> {
                return existingTask
            }

            let newTask = Task<Success, Never> {
                return await operation()
            }

            self.tasks[key] = newTask

            return newTask
        }

        defer {
            self.lock.withLock {
                self.tasks[key] = nil
            }
        }

        return await task.value
    }

    @discardableResult
    func executeOperation<Success>(for key: String,
                                   @_inheritActorContext operation: @escaping ThrowingOperation<Success>) async throws -> Success {
        let task = self.lock.withLock {
            if let existingTask = self.tasks[key] as? Task<Success, Error> {
                return existingTask
            }

            let newTask = Task<Success, Error> {
                return try await operation()
            }

            self.tasks[key] = newTask

            return newTask
        }

        defer {
            self.lock.withLock {
                self.tasks[key] = nil
            }
        }

        return try await task.value
    }

    func cancelOperation(with key: String) {
        self.lock.withLock {
            self.tasks[key]?.cancelOperation()
            self.tasks[key] = nil
        }
    }

}
