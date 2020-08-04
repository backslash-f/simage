import Foundation
import ImageIO

// MARK: - Interface

public extension SImage {

    /// Returns a `CGImageProperty` (`[AnyHashable: Any]` dictionary) from the given `URL`. Throws in case there is no
    /// image on the URL or the image doesn't have metadata.
    ///
    /// - Parameter url: `URL` where an image (with its metadata) resides.
    /// - Throws: `SImageError.cannotGetImageProperties`
    /// - Returns: `CGImageProperty` for the given `URL`.
    func imageProperties(from url: URL) throws -> CGImageProperty {
        log("Started fetching CGImageProperty", category: .metadataFetching)
        log("URL \(url)", category: .metadataFetching)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? CGImageProperty else {
            let error = SImageError.cannotGetImageProperties(from: url)
            log(error)
            throw error
        }
        log("Finished fetching CGImageProperty", category: .metadataFetching)
        return properties
    }

    /// Returns the `CGImagePropertyOrientation` of an image from the given `URL`. Throws in case there is no image on
    /// the URL or the image doesn't have orientation information.
    ///
    /// - Parameter url: `URL` where an image (with its metadata) resides.
    /// - Throws: `SImageError.cannotGetImageOrientation`
    /// - Returns: `CGImagePropertyOrientation` for the given `URL`.
    func imageOrientation(from url: URL) throws -> CGImagePropertyOrientation {
        log("Started fetching CGImagePropertyOrientation", category: .metadataFetching)
        log("URL \(url)", category: .metadataFetching)
        let properties = try imageProperties(from: url)
        guard let orientation = properties.orientation() else {
            let error = SImageError.cannotGetImageOrientation(from: url)
            log(error)
            throw error
        }
        log("Finished fetching CGImagePropertyOrientation", category: .combining)
        return orientation
    }

    /// Returns the `CGSize` of an image from the given `URL`. Throws in case there is no image on the URL or the image
    /// doesn't have orientation information.
    ///
    /// - Parameter url: `URL` where an image (with its metadata) resides.
    /// - Throws: `SImageError.cannotGetImageSize`
    /// - Returns: `CGSize` for the given `URL`.
    func imageSize(from url: URL) throws -> CGSize {
        log("Started fetching image size", category: .metadataFetching)
        log("URL \(url)", category: .metadataFetching)
        let properties = try imageProperties(from: url)
        guard let size = properties.size() else {
            let error = SImageError.cannotGetImageSize(from: url)
            log(error)
            throw error
        }
        log("Finished fetching image size", category: .metadataFetching)
        return size
    }
}
