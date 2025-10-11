import AsyncAlgorithms
import Foundation

protocol UpdateRequest: Equatable {

    static var empty: Self { get }

    var hasUpdates: Bool { get }

    mutating func merge(with other: Self)

}

@MainActor
final class QueuedUpdater<Request: UpdateRequest> {

    private struct ChannelState {

        let channel: AsyncChannel<Request>

        let task: Task<Void, Never>

    }

    private let performUpdate: (Request) async -> Bool

    private let debounceDuration: Duration

    private var channelState: ChannelState?

    init(debounceInterval: TimeInterval = 2,
         performUpdate: @MainActor @escaping (Request) async -> Bool) {
        self.performUpdate = performUpdate
        self.debounceDuration = .nanoseconds(Int64(max(debounceInterval, 0) * 1_000_000_000))
        self.channelState = self.makeChannelState()
    }

    func enqueue(_ request: Request) {
        self.ensureChannelState()

        guard let channel = self.channelState?.channel else {
            return
        }

        Task {
            await channel.send(request)
        }
    }

    func flush() {
        Task {
            await self.flushAsync()
        }
    }

    func flushAsync() async {
        guard let state = self.channelState else {
            self.channelState = self.makeChannelState()

            return
        }

        let task = state.task
        state.channel.finish()
        await task.value

        self.channelState = self.makeChannelState()
    }

    private func ensureChannelState() {
        if self.channelState == nil {
            self.channelState = self.makeChannelState()
        }
    }

    private func makeChannelState() -> ChannelState {
        let channel = AsyncChannel<Request>()
        let performUpdate = self.performUpdate
        let debounceDuration = self.debounceDuration

        let task = Task {
            var pending = Request.empty
            let clock = ContinuousClock()

            let debouncedStream = channel
                .map { request in
                    pending.merge(with: request)

                    return pending
                }
                .debounce(for: debounceDuration, clock: clock)

            for await aggregated in debouncedStream {
                let request = aggregated

                let didConsume = await performUpdate(request)

                if didConsume {
                    pending = .empty
                } else {
                    pending.merge(with: request)

                    await channel.send(Request.empty)
                }
            }

            if pending.hasUpdates {
                _ = await performUpdate(pending)
            }
        }

        return ChannelState(channel: channel, task: task)
    }

}
