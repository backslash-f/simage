import SwiftUI

public extension SImage {

    /// Creates thumbnail creation options to be used with `CGImageSourceCreateThumbnailAtIndex(_:_:_:)`, based on given
    /// `SImageSettings`.
    ///
    /// - Parameter settings: `SImageSettings` from where the thumbnail creation options will be based on.
    /// - Returns: Thumbnail creation options as `CFDictionary`.
    func createThumbnailOptions(with settings: SImageSettings) -> CFDictionary {
        var thumbnailOptions: [CFString: Any] = [
            kCGImageSourceShouldAllowFloat: settings.thumbsShouldAllowFloat,
            kCGImageSourceCreateThumbnailWithTransform: settings.thumbsShouldRotateAndScale,
            kCGImageSourceCreateThumbnailFromImageAlways: settings.thumbsAlwaysFromImage
        ]
        if let thumbsMaxPixelSize = settings.thumbsMaxPixelSize {
            thumbnailOptions[kCGImageSourceThumbnailMaxPixelSize] = thumbsMaxPixelSize
        }
        return thumbnailOptions as CFDictionary
    }
}
