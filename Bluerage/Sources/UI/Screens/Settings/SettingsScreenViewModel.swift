import Foundation
import FactoryKit
import SwiftUI
import Clerk

@MainActor
@Observable
final class SettingsScreenViewModel {

    private(set) var sections: [SettingSection]

    @ObservationIgnored
    @Injected(\.clerk) private var clerk

    @ObservationIgnored
    @Injected(\.authSession) private var authSession

    init() {
        weak var weakSelf: SettingsScreenViewModel?

        self.sections = [
            SettingSection(title: "App", rows: [
                SettingRow(title: "Custom Models",
                           icon: .system(named: "brain.fill",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           type: .navigation(destination: .customModels),
                           actionType: .inApp)
            ]),
            SettingSection(title: "Community", rows: [
                SettingRow(title: "X",
                           icon: .image(named: BluerageAsset.Assets.xIcon.name,
                                        size: CGSize(width: 13, height: 16)),
                           type: .default(action: {
                               let url = URL(string: "https://x.com/blueragehq")!
                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect),
                SettingRow(title: "Threads",
                           icon: .image(named: BluerageAsset.Assets.threadsIcon.name,
                                        size: CGSize(width: 16, height: 16)),
                           type: .default(action: {
                               let url = URL(string: "https://threads.com/blueragehq")!
                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect),
                SettingRow(title: "Discord",
                           icon: .image(named: BluerageAsset.Assets.discordIcon.name,
                                        size: CGSize(width: 20, height: 16)),
                           type: .default(action: {
                               let url = URL(string: "https://discord.gg/sCutZ3zd")!
                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect),
                SettingRow(title: "Contact Support",
                           icon: .system(named: "envelope.fill",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           type: .default(action: {
                               let url = URL(string: "mailto:support@bluerage.software")!
                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect)
            ]),
            SettingSection(title: "Danger Zone", rows: [
                SettingRow(title: "Sign Out",
                           icon: .system(named: "figure.walk",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           type: .destructive(action: {
                               await weakSelf?.authSession.signOut()
                           }),
                           actionType: .inApp),
                SettingRow(title: "Delete Account",
                           icon: .system(named: "trash.fill",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           type: .destructive(action: {
                               try await weakSelf?.clerk.user?.delete()
                           }),
                           actionType: .inApp)
            ])
        ]

        weakSelf = self
    }

}
