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
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? CGImageProperty else {
                throw SImageError.cannotGetImageProperties(from: url)
        }
        return properties
    }

    /// Returns the `CGImagePropertyOrientation` of an image from the given `URL`. Throws in case there is no image on
    /// the URL or the image doesn't have orientation information.
    ///
    /// - Parameter url: `URL` where an image (with its metadata) resides.
    /// - Throws: `SImageError.cannotGetImageOrientation`
    /// - Returns: `CGImagePropertyOrientation` for the given `URL`.
    func imageOrientation(from url: URL) throws -> CGImagePropertyOrientation {
        let properties = try imageProperties(from: url)
        guard let orientation = properties.orientation() else {
            throw SImageError.cannotGetImageOrientation(from: url)
        }
        return orientation
    }

    /// Returns the `CGSize` of an image from the given `URL`. Throws in case there is no image on the URL or the image
    /// doesn't have orientation information.
    ///
    /// - Parameter url: `URL` where an image (with its metadata) resides.
    /// - Throws: `SImageError.cannotGetImageSize`
    /// - Returns: `CGSize` for the given `URL`.
    func imageSize(from url: URL) throws -> CGSize {
        let properties = try imageProperties(from: url)
        guard let size = properties.size() else {
            throw SImageError.cannotGetImageSize(from: url)
        }
        return size
    }
}
