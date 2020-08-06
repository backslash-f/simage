import Foundation
import ImageIO

internal extension SImage {

    /// Creates a `CGImageSource` via `CGImageSourceCreateWithURL` using the given parameters.
    ///
    /// - Parameters:
    ///   - url: `URL` where an image resides.
    ///   - settings: `SImageSettings` from where the `CGImageSource` creation options will be based on.
    /// - Throws: `SImageError.cannotCreateImage(from:)` in case the creation fails.
    /// - Returns: `CGImageSource`.
    func createImageSource(from url: URL, with settings: SImageSettings) throws -> CGImageSource {
        log("Started creating image source", category: .creating)
        let options = createImageSourceOptions(with: settings)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, options) else {
            log("Could not create the CGImageSource. CGImageSourceCreateWithURL returned nil", category: .creating)
            let error = SImageError.cannotCreateImage(from: url)
            log(error)
            throw error
        }
        log("Finished creating image source. Result: \(source)", category: .creating)
        return source
    }

    /// Creates a `CGImage` via `CGImageSourceCreateImageAtIndex` using the given parameters.
    ///
    /// - Parameters:
    ///   - url: `URL` where an image resides.
    ///   - settings: `SImageSettings` from where the `CGImageSource` creation options will be based on.
    /// - Throws: `SImageError.cannotCreateImage(from:)` in case the creation fails.
    /// - Returns: `CGImage`.
    func createImage(from url: URL, imageSource: CGImageSource, with settings: SImageSettings) throws -> CGImage {
        log("Started creating image from source: \(imageSource)", category: .creating)
        let options = createImageSourceOptions(with: settings)
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, options) else {
            log("Could not create the CGImage. CGImageSourceCreateImageAtIndex returned nil", category: .creating)
            let error = SImageError.cannotCreateImage(from: url)
            log(error)
            throw error
        }
        log("Finished creating image from source. Result: \(image)", category: .creating)
        return image
    }
}

// MARK: - Private

private extension SImage {

    /// Creates a `CGImageSource` creation options to be used with `SImage.createImageSource(from:with:)`,
    /// based on the given `SImageSettings`.
    ///
    /// - Parameter settings: `SImageSettings` from where the `CGImageSource` creation options will be based on.
    /// - Returns: `CGImageSource` creation  options as `CFDictionary`.
    func createImageSourceOptions(with settings: SImageSettings) -> CFDictionary {
        log("Started creating CGImageSource options with settings: \(settings)", category: .creating)
        let imageSourceOptions: [CFString: Any] = [
            kCGImageSourceShouldAllowFloat: settings.imgSourceShouldAllowFloat,
            kCGImageSourceShouldCache: settings.imgSourceShouldCache,
        ]
        log("Finished creating CGImageSource options. Result: \(imageSourceOptions)", category: .creating)
        return imageSourceOptions as CFDictionary
    }
}
