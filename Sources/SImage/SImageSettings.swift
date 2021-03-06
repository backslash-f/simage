import Foundation
import ImageIO

#if !os(macOS)
import MobileCoreServices
#endif

/// Stores a variety of settings to be used during image operations such as combination, rotation, thumbnail creation,
/// etc.
public struct SImageSettings {

    // MARK: - Public Properties

    /// Default value of the image saved by `SImage.save(image:settings:completion:)`.
    public static let defaultImageFilename = "SImage.png"

    // MARK: - Private Properties

    // MARK: - Rotation

    private(set) var rotationTargetOrientation: CGImagePropertyOrientation
    private(set) var rotationIgnoreMissingMetadata: Bool

    // MARK: - Context

    private(set) var contextBitsPerComponent: Int
    private(set) var contextBytesPerRow: Int
    private(set) var contextColorSpace: CGColorSpace
    private(set) var contextBitmapInfo: UInt32

    // MARK: Thumbnail Creation

    private(set) var thumbsShouldAllowFloat: Bool
    private(set) var thumbsShouldRotateAndScale: Bool
    private(set) var thumbsAlwaysFromImage: Bool
    private(set) var thumbsMaxPixelSize: String?

    // MARK: - Save Image

    private(set) var saveFilename: String
    private(set) var saveDestinationURL: URL
    private(set) var saveImageType: CFString

    // MARK: - Lifecycle

    /// Initializes a `SImageSettings` instance, which stores a variety of settings that can be used during the image
    /// operations provided by the `SImage` package.
    ///
    /// For an example of how to specify the `contextColorSpace`, `contextBytesPerRow`, `contextBitsPerComponent`, and
    /// `contextBitmapInfo`, see [Graphics Contexts](https://apple.co/34YaDZJ).
    ///
    /// - Parameters:
    ///   - rotationTargetOrientation: In a rotation operation, defines the desired orientation for an image. Default is
    ///   `.up`.
    ///   - rotationIgnoreMissingMetadata: Some images may not have rotation information in its metadata. When
    ///   `SImage.rotateImages(in:settings:completion:)` encounters those type of images, it may throw (`SImageError.cannotGetImageOrientation(from:)`). If you want to ignore missing rotation information and just
    ///   proceed to the next image, set this property to `true`. If you want to stop the rotation operation when there
    ///   is no rotation information available, set it to `false`. The default is `true` (missing rotation information
    ///   is ignored. **Notice that the image itself won't be skipped -- it will be included in the result image, but
    ///   "untouched" (not rotated)**).
    ///
    ///   - contextBitsPerComponent: The number of bits to use for each component of a pixel in memory when creating a
    ///   new `CGContext`. Default is `8`.
    ///   - contextBytesPerRow: The number of bytes of memory to use per row of the bitmap when creating a new
    ///   `CGContext`. The default is `0`, which causes the value to be calculated automatically.
    ///   - contextColorSpace: The color space to use when creating a new `CGContext`. Default is
    ///   `CGColorSpaceCreateDeviceRGB()`.
    ///   - contextBitmapInfo: Constants that specify whether the bitmap should contain an alpha channel when creating
    ///   a new `CGContext`, the alpha channel’s relative location in a pixel, and information about whether the pixel
    ///   components are floating-point or integer values. Default is `CGImageAlphaInfo.premultipliedLast.rawValue`.
    ///
    ///   - thumbsShouldAllowFloat: Whether the thumbnail image should be returned as a `CGImage` object that uses
    ///   floating-point values, if supported by the file format. `CGImage` objects that use extended-range
    ///   floating-point values may require additional processing to render in a pleasing manner. The default is `true`.
    ///   - thumbsShouldRotateAndScale: Whether the thumbnail should be rotated and scaled according to the orientation
    ///   and pixel aspect ratio of the full image. The default is `true`.
    ///   - thumbsAlwaysFromImage: Whether a thumbnail should be created from the full image even if a thumbnail is
    ///   present in the image source file. The thumbnail is created from the full image, subject to the limit specified
    ///   by `maxPixelSize`. The default is `true`.
    ///   - thumbsMaxPixelSize: An optional maximum width or height in pixels of a thumbnail. The default is `nil`.
    ///
    ///   - saveFilename: The image filename. The default is `SImageSettings.defaultImageFilename`. If overridden,
    ///   the **file type** must be also provided. For example: "*MyDesiredName.png*".
    ///   - saveDestinationURL: Optional `URL` in which the given image should be saved. It already appends the
    ///   `saveFilename`. The default points to the temporary directory for the current user.
    ///   - saveImageType: The UTI (uniform type identifier) of the resulting image file. Used by
    ///   `CGImageDestinationCreateWithURL(_:_:_:_:)` during image saving. The default is `.kUTTypePNG`.
    public init(rotationTargetOrientation: CGImagePropertyOrientation = .up,
                rotationIgnoreMissingMetadata: Bool = true,
                contextBitsPerComponent: Int = 8,
                contextBytesPerRow: Int = 0,
                contextColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB(),
                contextBitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue,
                thumbsShouldAllowFloat: Bool = true,
                thumbsShouldRotateAndScale: Bool = true,
                thumbsAlwaysFromImage: Bool = true,
                thumbsMaxPixelSize: String? = nil,
                saveFilename: String = SImageSettings.defaultImageFilename,
                saveDestinationURL: URL = FileManager.default.temporaryDirectory,
                saveImageType: CFString = kUTTypePNG) {

        self.rotationTargetOrientation = rotationTargetOrientation
        self.rotationIgnoreMissingMetadata = rotationIgnoreMissingMetadata

        self.contextBitsPerComponent = contextBitsPerComponent
        self.contextBytesPerRow = contextBytesPerRow
        self.contextColorSpace = contextColorSpace
        self.contextBitmapInfo = contextBitmapInfo

        self.thumbsShouldAllowFloat = thumbsShouldAllowFloat
        self.thumbsShouldRotateAndScale = thumbsShouldRotateAndScale
        self.thumbsAlwaysFromImage = thumbsAlwaysFromImage
        self.thumbsMaxPixelSize = thumbsMaxPixelSize

        self.saveFilename = saveFilename
        self.saveDestinationURL = saveDestinationURL.appendingPathComponent(saveFilename)
        self.saveImageType = saveImageType
    }
}
