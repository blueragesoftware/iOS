import SwiftUI

struct IdentifiableItem: Identifiable, Equatable {

    let id: String

    var value: String

}

struct DynamicSection<CellContent: View>: View {

    @Binding var items: [IdentifiableItem]

    private let title: String

    private let cellContent: (Binding<String>, Bool) -> CellContent

    private let reorderEnabled: Bool

    init(title: String,
         items: Binding<[IdentifiableItem]>,
         reorderEnabled: Bool = false,
         @ViewBuilder cellContent: @escaping (Binding<String>, Bool) -> CellContent) {
        self.title = title
        self._items = items
        self.reorderEnabled = reorderEnabled
        self.cellContent = cellContent
    }

    var body: some View {
        Section {
            ForEach(Array(zip(self.items.indices, self.$items)), id: \.1.id) { index, $item in
                self.cellContent($item.value, self.isLastItem(index: index))
                    .onChange(of: item) { _, newValue in
                        self.handleItemChange(at: index, newValue: newValue)
                    }
                    .deleteDisabled(self.isEditable(index: index))
                    .moveDisabled(self.isEditable(index: index))
            }
            .onDelete { indexSet in
                self.items.remove(atOffsets: indexSet)
            }
            .onMove { from, to in
                self.items.move(fromOffsets: from, toOffset: to)
            }
        } header: {
            Text(self.title)
        } footer: {
            Text("Swipe left to delete")
        }
    }

    private func isEditable(index: Int) -> Bool {
        return self.items.count == 1 || self.isLastItem(index: index)
    }

    private func isLastItem(index: Int) -> Bool {
        return index == self.items.count - 1
    }

    private func handleItemChange(at index: Int, newValue: IdentifiableItem) {
        if self.isLastItem(index: index) && !newValue.value.isEmpty {
            self.items.append(IdentifiableItem(id: UUID().uuidString, value: ""))
        } else if self.items.count > 1,
                  index == self.items.count - 2,
                  newValue.value.isEmpty,
                  let lastItem = self.items.last,
                  lastItem.value.isEmpty {
            self.items.removeLast()
        } else if index > 0 &&
                    index < self.items.count - 1 &&
                    newValue.value.isEmpty {
            self.items.remove(at: index)
        }
    }
}
