import ImageIO

internal extension SImage {

    /// Creates thumbnail creation options to be used with `CGImageSourceCreateThumbnailAtIndex(_:_:_:)`, based on given
    /// `SImageSettings`.
    ///
    /// - Parameter settings: `SImageSettings` from where the thumbnail creation options will be based on.
    /// - Returns: Thumbnail creation options as `CFDictionary`.
    func createThumbnailOptions(with settings: SImageSettings) -> CFDictionary {
        log("Started creating thumbnail options with settings: \(settings)", category: .thumbnail)
        var thumbnailOptions: [CFString: Any] = [
            kCGImageSourceShouldAllowFloat: settings.thumbsShouldAllowFloat,
            kCGImageSourceShouldCache: settings.thumbsSourceShouldCache,
            kCGImageSourceCreateThumbnailWithTransform: settings.thumbsShouldRotateAndScale,
            kCGImageSourceCreateThumbnailFromImageAlways: settings.thumbsAlwaysFromImage
        ]
        if let thumbsMaxPixelSize = settings.thumbsMaxPixelSize {
            thumbnailOptions[kCGImageSourceThumbnailMaxPixelSize] = thumbsMaxPixelSize
        }
        log("Finished creating thumbnail options. Result: \(thumbnailOptions)", category: .thumbnail)
        return thumbnailOptions as CFDictionary
    }
}
