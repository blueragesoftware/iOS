import Foundation
import CryptoKit

struct EncryptionManager {

    private static let environmentKey = "ENCRYPTION_KEY"

    static func encryptApiKey(_ apiKey: String) -> String? {
        guard let keyString = ProcessInfo.processInfo.environment[environmentKey],
              let keyData = keyString.data(using: .utf8) else {
            return nil
        }

        guard let apiKeyData = apiKey.data(using: .utf8) else {
            return nil
        }

        do {
            let key = SHA256.hash(data: keyData)
            let symmetricKey = SymmetricKey(data: key)

            let sealedBox = try AES.GCM.seal(apiKeyData, using: symmetricKey)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            return nil
        }
    }

    static func decryptApiKey(_ encryptedApiKey: String) -> String? {
        guard let keyString = ProcessInfo.processInfo.environment[environmentKey],
              let keyData = keyString.data(using: .utf8) else {
            return nil
        }

        guard let encryptedData = Data(base64Encoded: encryptedApiKey) else {
            return nil
        }

        do {
            let key = SHA256.hash(data: keyData)
            let symmetricKey = SymmetricKey(data: key)

            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)

            return String(data: decryptedData, encoding: .utf8)
        } catch {
            return nil
        }
    }

}
