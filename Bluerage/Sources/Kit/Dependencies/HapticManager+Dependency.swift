import FactoryKit

extension Container {

    var hapticManager: Factory<HapticsManager> {
        self {
            HapticsManager()
        }.singleton
    }

}
