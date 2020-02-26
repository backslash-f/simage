import SwiftUI

internal extension SImage {

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
