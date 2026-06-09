import Photos
import UIKit

enum PhotoSaverError: LocalizedError {
    case notAuthorized
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return L10n.text("未授权写入相册，请到「设置」开启相册权限。")
        case .underlying(let e):
            return e.localizedDescription
        }
    }
}

/// 把渲染好的 UIImage 保存到系统相册（仅写入权限即可，不读相册）。
enum PhotoSaver {

    static func save(_ image: UIImage) async throws {
        let status = await requestAuth()
        guard status == .authorized || status == .limited else {
            throw PhotoSaverError.notAuthorized
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch {
            throw PhotoSaverError.underlying(error)
        }
    }

    private static func requestAuth() async -> PHAuthorizationStatus {
        let current = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if current != .notDetermined { return current }
        return await withCheckedContinuation { cont in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                cont.resume(returning: status)
            }
        }
    }
}
