import Foundation

enum EditableItem<Content: Identifiable>: Identifiable, Equatable where Content: Equatable, Content.ID == String {
    case content(Content)
    case empty(id: String)

    var id: String {
        switch self {
        case .content(let item):
            return item.id
        case .empty(let id):
            return id
        }
    }
}

typealias EditableToolItem = EditableItem<Tool>

typealias EditableStepItem = EditableItem<Agent.Step>
