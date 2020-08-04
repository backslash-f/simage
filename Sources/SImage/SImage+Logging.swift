import Foundation
import AppLogger

/// `SImage` logging categories to further distinguish the running parts of the package.
///
/// Refer to: https://developer.apple.com/documentation/os/logging
public enum SImageLoggingCategory: String {
    case creating = "Creating"
    case combining = "Combining"
    case error = "Error"
    case horizontalDistribution = "HorizontalDistribution"
    case horizontalDistributionRotated = "HorizontalDistributionRotated"
    case metadataFetching = "MetadataFetching"
    case rotating = "Rotating"
    case saving = "Saving"
    case thumbnail = "Thumbnail"
    case transforming = "Transforming"
}

extension SImage {

    /// Logs the given `String` information via `AppLogger`.
    ///
    /// - Parameters:
    ///   - information: The `String` to be logged.
    ///   - category: A member of the `SImageLoggingCategory` enum.
    func log(_ information: String, category: SImageLoggingCategory) {
        guard isLoggingEnabled else { return }
        let simageSubsystem = "com.backslash-f.SImage"
        let logger = AppLogger(subsystem: simageSubsystem, category: category.rawValue)
        logger.log(information)
    }

    /// Logs the given `SImageError` information via `AppLogger`.
    ///
    /// - Parameter error: A member of the `SImageError` enum.
    func log(_ error: SImageError) {
        log("SImage's error: \(error)", category: .error)
    }
}
