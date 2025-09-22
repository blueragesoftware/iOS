import Foundation
import FactoryKit
import SwiftUI
import Clerk
import OSLog

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
            SettingSection(title: BluerageStrings.settingsAppSectionTitle, rows: [
                SettingRow(title: BluerageStrings.settingsCustomModelsTitle,
                           icon: .system(named: "brain.fill",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           fillColor: .gray,
                           type: .navigation(destination: .customModels),
                           actionType: .inApp)
            ]),
            SettingSection(title: BluerageStrings.settingsCommunitySectionTitle, rows: [
                SettingRow(title: BluerageStrings.settingsXTitle,
                           icon: .image(named: BluerageAsset.Assets.xIcon.name,
                                        size: CGSize(width: 13, height: 16)),
                           fillColor: .black,
                           type: .default(action: {
                               guard let url = URL(string: "https://x.com/blueragehq") else {
                                   Logger.settings.error("Unable to construct X url")

                                   return
                               }

                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect),
                SettingRow(title: BluerageStrings.settingsThreadsTitle,
                           icon: .image(named: BluerageAsset.Assets.threadsIcon.name,
                                        size: CGSize(width: 16, height: 16)),
                           fillColor: .black,
                           type: .default(action: {
                               guard let url = URL(string: "https://threads.com/blueragehq") else {
                                   Logger.settings.error("Unable to construct threads url")

                                   return
                               }

                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect),
                SettingRow(title: BluerageStrings.settingsDiscordTitle,
                           icon: .image(named: BluerageAsset.Assets.discordIcon.name,
                                        size: CGSize(width: 20, height: 16)),
                           fillColor: BluerageAsset.Assets.discordColor.swiftUIColor,
                           type: .default(action: {
                               guard let url = URL(string: "https://discord.gg/sCutZ3zd") else {
                                   Logger.settings.error("Unable to construct discord url")

                                   return
                               }

                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect),
                SettingRow(title: BluerageStrings.settingsContactSupportTitle,
                           icon: .system(named: "envelope.fill",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           fillColor: .blue,
                           type: .default(action: {
                               guard let url = URL(string: "mailto:support@bluerage.software") else {
                                   Logger.settings.error("Unable to construct support url")

                                   return
                               }

                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect)
            ]),
            SettingSection(title: BluerageStrings.settingsAdditionalSectionTitle, rows: [
                SettingRow(title: BluerageStrings.settingsAcknowledgementsTitle,
                           icon: .system(named: "book.pages.fill",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           fillColor: .yellow,
                           type: .default(action: {
                               guard let url = URL(string: UIApplication.openSettingsURLString) else {
                                   Logger.settings.error("Unable to construct settings url")

                                   return
                               }

                               await UIApplication.shared.open(url)
                           }),
                           actionType: .redirect)
            ]),
            SettingSection(title: BluerageStrings.settingsDangerZoneSectionTitle, rows: [
                SettingRow(title: BluerageStrings.settingsSignOutTitle,
                           icon: .system(named: "figure.walk",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           fillColor: .red,
                           type: .destructive(action: {
                               guard let self = weakSelf else {
                                   Logger.settings.error("Sign out failure due to self deallocation")

                                   return
                               }

                               await self.authSession.signOut()
                           }),
                           actionType: .inApp),
                SettingRow(title: BluerageStrings.settingsDeleteAccountTitle,
                           icon: .system(named: "trash.fill",
                                         fontSize: 15,
                                         fontWeight: .semibold),
                           fillColor: .red,
                           type: .destructive(action: {
                               guard let self = weakSelf else {
                                   Logger.settings.error("Delete account failure due to self deallocation")

                                   return
                               }

                               guard let user = self.clerk.user else {
                                   Logger.settings.error("Delete account failure due to missing user session")

                                   return
                               }

                               try await user.delete()
                           }),
                           actionType: .inApp)
            ])
        ]

        weakSelf = self
    }

}
