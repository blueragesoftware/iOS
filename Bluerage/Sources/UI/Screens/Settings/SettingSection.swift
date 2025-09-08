import Foundation

struct SettingSection: Identifiable, Hashable, Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    let id: String = UUID().uuidString

    let title: String

    let rows: [SettingRow]

}
