import SwiftUI

/// Stores a variety of settings to be used during image operations such as combination, rotation, etc.
public struct SImageSettings {

    // MARK: - Properties

    private(set) var targetOrientation: CGImagePropertyOrientation
    private(set) var contextBitsPerComponent: Int
    private(set) var contextBytesPerRow: Int
    private(set) var contextColorSpace: CGColorSpace
    private(set) var contextBitmapInfo: UInt32

    // MARK: - Lifecycle

    /// Initializes a `SImageSettings` instance, which stores a variety of settings that can be used during the image
    /// operations provided by the `SImage` package.
    ///
    /// For an example of how to specify the `contextColorSpace`, `contextBytesPerRow`, `contextBitsPerComponent`, and
    /// `contextBitmapInfo`, see [Graphics Contexts](https://apple.co/34YaDZJ).
    ///
    /// - Parameters:
    ///   - targetOrientation: In a rotation operation, defines the desired orientation for an image. Default is `.up`.
    ///   - contextBitsPerComponent: The number of bits to use for each component of a pixel in memory when creating a
    ///   new `CGContext`. Default is `8`.
    ///   - contextBytesPerRow: The number of bytes of memory to use per row of the bitmap when creating a new
    ///   `CGContext`. The default is `0`, which causes the value to be calculated automatically.
    ///   - contextColorSpace: The color space to use when creating a new `CGContext`. Default is
    ///   `CGColorSpaceCreateDeviceRGB()`.
    ///   - contextBitmapInfo: Constants that specify whether the bitmap should contain an alpha channel when creating
    ///   a new `CGContext`, the alpha channel’s relative location in a pixel, and information about whether the pixel
    ///   components are floating-point or integer values. Default is `CGImageAlphaInfo.premultipliedLast.rawValue`.
    public init(targetOrientation: CGImagePropertyOrientation = .up,
                contextBitsPerComponent: Int = 8,
                contextBytesPerRow: Int = 0,
                contextColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB(),
                contextBitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue) {
        self.targetOrientation = targetOrientation
        self.contextBitsPerComponent = contextBitsPerComponent
        self.contextBytesPerRow = contextBytesPerRow
        self.contextColorSpace = contextColorSpace
        self.contextBitmapInfo = contextBitmapInfo
    }
}
