import Foundation
import ImageIO

// MARK: - Interface

public extension SImage {

    /// Returns a `CGImageProperty` (`[AnyHashable: Any]` dictionary) from the given `URL`. Throws in case there is no
    /// image on the URL or the image doesn't have metadata.
    ///
    /// - Parameters:
    ///   - url: `URL` where an image (with its metadata) resides.
    ///   - settings: `SImageSettings` instance that stores rotation settings.
    /// - Throws: `SImageError.cannotGetImageProperties`
    /// - Returns: `CGImageProperty` for the given `URL`.
    func imageProperties(from url: URL, with settings: SImageSettings) throws -> CGImageProperty {
        log("Started fetching CGImageProperty", category: .metadataFetching)
        log("URL \(url)", category: .metadataFetching)
        let source = try createImageSource(from: url, with: settings)
        let options = createImageSourceOptions(with: settings)
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, options) as? CGImageProperty else {
            let error = SImageError.cannotGetImageProperties(from: url)
            log(error)
            throw error
        }
        log("Finished fetching CGImageProperty: \(properties)", category: .metadataFetching)
        return properties
    }

    /// Returns the `CGImagePropertyOrientation` of an image from the given `URL`. Throws in case there is no image on
    /// the URL or the image doesn't have orientation information.
    ///
    /// - Parameters:
    ///   - url: `URL` where an image (with its metadata) resides.
    ///   - settings: `SImageSettings` instance that stores rotation settings.
    /// - Throws: `SImageError.cannotGetImageOrientation`
    /// - Returns: `CGImagePropertyOrientation` for the given `URL`.
    func imageOrientation(from url: URL, with settings: SImageSettings) throws -> CGImagePropertyOrientation {
        log("Started fetching CGImagePropertyOrientation", category: .metadataFetching)
        log("URL \(url)", category: .metadataFetching)
        let properties = try imageProperties(from: url, with: settings)
        guard let orientation = properties.orientation() else {
            let error = SImageError.cannotGetImageOrientation(from: url)
            log(error)
            throw error
        }
        log("Finished fetching CGImagePropertyOrientation: \(orientation)", category: .combining)
        return orientation
    }

    /// Returns the `CGSize` of an image from the given `URL`. Throws in case there is no image on the URL or the image
    /// doesn't have orientation information.
    ///
    /// - Parameters:
    ///   - url: `URL` where an image (with its metadata) resides.
    ///   - settings: `SImageSettings` instance that stores rotation settings.
    /// - Throws: `SImageError.cannotGetImageSize`
    /// - Returns: `CGSize` for the given `URL`.
    func imageSize(from url: URL, with settings: SImageSettings) throws -> CGSize {
        log("Started fetching image size", category: .metadataFetching)
        log("URL \(url)", category: .metadataFetching)
        let properties = try imageProperties(from: url, with: settings)
        guard let size = properties.size() else {
            let error = SImageError.cannotGetImageSize(from: url)
            log(error)
            throw error
        }
        log("Finished fetching image size: \(size)", category: .metadataFetching)
        return size
    }
}
