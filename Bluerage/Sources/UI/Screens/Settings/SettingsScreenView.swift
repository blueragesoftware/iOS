import SwiftUI
import NavigatorUI
import PostHog

struct SettingsScreenView: View {

    @State private var viewModel = SettingsScreenViewModel()

    var body: some View {
        ManagedNavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(self.viewModel.sections) { section in
                        Section {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(UIColor.systemGray6.swiftUI)
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)

                                VStack(alignment: .leading, spacing: 20) {
                                    ForEach(section.rows) { row in
                                        SettingCellView(row: row)
                                    }
                                }
                                .padding(20)
                            }
                        } header: {
                            HStack {
                                Text(section.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.leading, 24)

                                Spacer()
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .background(UIColor.systemGroupedBackground.swiftUI)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .postHogScreenView("SettingsScreenView")
    }

}
