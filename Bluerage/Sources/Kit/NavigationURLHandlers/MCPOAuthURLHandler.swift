import Foundation
import FactoryKit
import NavigatorUI
import RegexBuilder

@MainActor
struct MCPOAuthURLHandler: NavigationURLHandler {

    struct OAuthResult: Hashable {
        let code: String?
        let error: String?
    }

    @Injected(\.env) private var env

    // MARK: - NavigationURLHandler

    func handles(_ url: URL, with navigator: Navigator) -> Bool {
        guard url.scheme == self.env.URL_SCHEME else {
            return false
        }

        let serverIdRef = Reference<String>()
        let codeRef = Reference<String?>()
        let errorRef = Reference<String?>()

        let regex = Regex {
            Regex {
                "\(self.env.URL_SCHEME)://oauth/callback/"

                Capture(as: serverIdRef) {
                    OneOrMore(CharacterClass.anyOf("/?").inverted)
                } transform: { captured in
                    String(captured)
                }

                Optionally {
                    Regex {
                        "?code="
                        Capture(as: codeRef) {
                            OneOrMore(CharacterClass.anyOf("&").inverted)
                        } transform: { captured in
                            String(captured).removingPercentEncoding
                        }
                    }
                }

                Optionally {
                    Regex {
                        "&error="
                        Capture(as: errorRef) {
                            OneOrMore(CharacterClass.anyOf("&").inverted)
                        } transform: { captured in
                            String(captured).removingPercentEncoding
                        }
                    }
                }
            }
        }
            .anchorsMatchLineEndings()

        guard let match = url.absoluteString.wholeMatch(of: regex) else {
            return false
        }

        let serverId = match[serverIdRef]
        let code = match[codeRef]
        let error = match[errorRef]

        navigator.perform(.send(AgentListDestinations.settings),
                          .send(SettingsDestinations.mcpServers),
                          .send(MCPServersListDestinations.mcpServer(id: serverId)),
                          .send(OAuthResult(code: code, error: error)))

//        navigator.send(AgentListDestinations.settings,
//                       SettingsDestinations.mcpServers,
//                       MCPServersListDestinations.mcpServer(id: serverId),
//                       OAuthResult(code: code, error: error))

        return true
    }

}
