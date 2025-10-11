import UIKit
import OSLog

@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate

    func sceneDidDisconnect(_ scene: UIScene) {
        Logger.default.info(#function)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Logger.default.info(#function)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Logger.default.info(#function)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Logger.default.info(#function)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        Logger.default.info(#function)
    }

}
