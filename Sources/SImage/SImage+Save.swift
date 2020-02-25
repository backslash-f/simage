import SwiftUI

public extension SImage {

    /// Returns the `URL` where the image is going to be saved. Appends the filename from `SImageSettings` to it (e.g.:
    /// "SImage.png").
    ///
    /// - Parameter settings: `SImageSettings` that holds the default filename.
    func imageDestinationURL(settings: SImageSettings = SImageSettings()) throws -> URL {
        let destinationURL = try FileManager.default.url(
            for: settings.saveSearchPathDirectory,
            in: settings.saveSearchPathDomainMask,
            appropriateFor: nil,
            create: false
        )
        return destinationURL.appendingPathComponent(settings.saveFilename)
    }

    /// Returns an opaque type that represents an image destination, required by APIs such as
    /// `CGImageDestinationFinalize(_:)`.
    ///
    /// - Parameters:
    ///   - url: `URL` where the image is going to be saved.
    ///   - settings: `SImageSettings` that holds the UTI (uniform type identifier) of the resulting image file.
    ///   E.g.: `kUTTypePNG`.
    func imageDestination(url: URL, settings: SImageSettings = SImageSettings()) -> CGImageDestination? {
        return CGImageDestinationCreateWithURL(
            url as CFURL,
            settings.saveImageType,
            1, // The number of images (not including thumbnail images) that the image file will contain.
            nil // Options
        )
    }
}
