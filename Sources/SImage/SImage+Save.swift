import SwiftUI

internal extension SImage {

    /// Returns an opaque type that represents an image destination, required by APIs such as
    /// `CGImageDestinationFinalize(_:)`.
    ///
    /// - Parameters:
    ///   - settings: `SImageSettings` that holds the destination URL and UTI (uniform type identifier) of the image to
    ///   be saved.
    ///   E.g.: `kUTTypePNG`.
    func imageDestination(settings: SImageSettings) -> CGImageDestination? {
        return CGImageDestinationCreateWithURL(
            settings.saveDestinationURL as CFURL,
            settings.saveImageType,
            1, // The number of images (not including thumbnail images) that the image file will contain.
            nil // Options
        )
    }
}
