import Foundation
import PostHog
import Factory

extension Container {

    var postHog: Factory<PostHogSDK> {
        self {
            PostHogSDK.shared
        }.shared
    }

}
