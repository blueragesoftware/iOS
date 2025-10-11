import Foundation
import PostHog
import FactoryKit

extension Container {

    var postHog: Factory<PostHogSDK> {
        self {
            PostHogSDK.shared
        }.singleton
    }

}
