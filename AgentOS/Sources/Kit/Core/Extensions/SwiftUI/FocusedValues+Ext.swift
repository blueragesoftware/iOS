import SwiftUI

struct AgentLoadedStepsSectionViewFocusedStepIndexKey: FocusedValueKey {
    typealias Value = Int
}

extension FocusedValues {
    var agentLoadedStepsSectionViewFocusedStepIndex: AgentLoadedStepsSectionViewFocusedStepIndexKey.Value? {
        get { self[AgentLoadedStepsSectionViewFocusedStepIndexKey.self] }
        set { self[AgentLoadedStepsSectionViewFocusedStepIndexKey.self] = newValue }
    }
}
