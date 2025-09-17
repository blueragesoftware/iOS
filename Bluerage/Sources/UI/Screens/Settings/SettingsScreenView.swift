import SwiftUI
import NavigatorUI
import PostHog

struct SettingsScreenView: View {

    private struct ConfirmationDialogConfig: Identifiable {

        let id = UUID()

        let title: String

        let destructiveText: String

        let continuation: CheckedContinuation<Bool, Never>

    }

    @State private var viewModel = SettingsScreenViewModel()

    @State private var confirmationConfig: ConfirmationDialogConfig?

    var body: some View {
        ManagedNavigationStack { navigator in
            List {
                ForEach(self.viewModel.sections) { section in
                    Section {
                        ForEach(section.rows) { row in
                            SettingCellView(row: row) { actionTitle in
                                return await self.showConfirmationDialog(for: actionTitle)
                            }
                            .environment(\.navigator, navigator)
                        }
                    } header: {
                        Text(section.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationDestination(SettingsDestinations.self)
            .scrollIndicators(.hidden)
            .background(UIColor.systemGroupedBackground.swiftUI)
            .navigationTitle(BluerageStrings.settingsNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .postHogScreenView("SettingsScreenView")
        .confirmationDialog(
            self.confirmationConfig?.title ?? "",
            isPresented: Binding(
                get: {
                    self.confirmationConfig != nil
                },
                set: {
                    if !$0 {
                        self.confirmationConfig?.continuation.resume(returning: false)
                        self.confirmationConfig = nil
                    }
                }
            ),
            titleVisibility: .visible,
            presenting: self.confirmationConfig
        ) { config in
            Button(config.destructiveText, role: .destructive) {
                config.continuation.resume(returning: true)
                self.confirmationConfig = nil
            }

            Button(BluerageStrings.commonCancel, role: .cancel) {
                config.continuation.resume(returning: false)
                self.confirmationConfig = nil
            }
        }

    }

    private func showConfirmationDialog(for actionTitle: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            self.confirmationConfig = ConfirmationDialogConfig(
                title: BluerageStrings.settingsConfirmationTitle(actionTitle),
                destructiveText: actionTitle,
                continuation: continuation
            )
        }
    }

}
