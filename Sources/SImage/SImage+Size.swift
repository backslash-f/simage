import SwiftUI

internal extension SImage {

    /// Applies the given `CGAffineTransform` to the gizen `CGSize` and returns a new `CGSize` as result.
    ///
    /// - Parameters:
    ///   - transformation: `CGAffineTransform` to be applied to the given `CGSize`.
    ///   - currentSize: `CGSize` representing the result of the transformation applied to the given size.
    /// - Returns: `CGSize` that is the result of applying the given `CGAffineTransform` to the gizen `CGSize`.
    func size(for transformation: CGAffineTransform, on currentSize: CGSize) -> CGSize {
        var size = CGRect(origin: CGPoint.zero, size: currentSize).applying(transformation).size
        // Trim off the extremely small Float values to prevent CoreGraphics from rounding it up.
        size.width = floor(size.width)
        size.height = floor(size.height)
        return size
    }

    /// Creates and returns a `CGSize` based on the given array of `RotatedImage`.
    ///
    /// The size will have **the sum of the rotated images width** as its own width and the height of the highest image.
    ///
    /// - Parameter rotatedImages: `RotatedImage` array, from which the `width` and `height` will be extracted.
    /// - Throws: `SImageError.invalidHeight` in case no image has height > 0.
    /// - Returns: `CGSize` from the `width` and `height` of the given array of `RotatedImage`.
    func horizontalSize(for rotatedImages: [RotatedImage]) throws -> CGSize {
        return try horizontalSize(for: rotatedImages.map { $0.image })
    }

    /// Creates and returns a `CGSize` based on the given array of `CGImage`.
    ///
    /// The size will have **the sum of the images width** as its own width and the height of the highest image.
    ///
    /// - Parameter images: `CGImage` array, from which the `width` and `height` will be extracted.
    /// - Throws: `SImageError.invalidHeight` in case no image has height > 0.
    /// - Returns: `CGSize` from the `width` and `height` of the given array of `CGImage`.
    func horizontalSize(for images: [CGImage]) throws -> CGSize {
        let width = images.map { $0.width }.reduce(0, +)
        guard let height = images.map({ $0.height }).max(),
            height > 0 else {
                throw SImageError.invalidHeight
        }
        return CGSize(width: width, height: height)
    }
}
