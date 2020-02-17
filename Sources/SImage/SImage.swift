import SwiftUI

/// Wrapper around `Core Graphics` that can provide functionalities such as image combination, image rotation, etc.
/// Because it relies on Core Graphics, it's multi-platform. It can run in macOS, iOS, iPadOS, tvOS, watchOS.
public struct SImage {
    public init() {}
}

// MARK: - Interface

public extension SImage {

    /// Combines the images in the given array of `URL` using settings from the given `SImageSettings`.
    ///
    /// Images are rotated via `SImage.rotateImages`, if necessary. Then the images are horizontally combined.
    /// Expensive operations runs on `DispatchQueue.global(qos: .userInitiated).async`.
    ///
    /// - Parameters:
    ///   - urls: array of `URL` where the images to be combined can be extracted.
    ///   - settings: `SImageSettings` that stores combination / `CGContext` creation settings.
    ///   - completion: Code to be executed after the operations finished. Returns optionals `CGImage` and `Error`.
    /// - Throws: `SImageError` in case the images couldn't be rotated or created (drawn / made via `CoreGraphics`).
    func combineImages(source urls: [URL],
                       settings: SImageSettings = SImageSettings(),
                       completion: @escaping (CGImage?, Error?) -> Void) {
        self.rotateImages(in: urls, targetOrientation: settings.targetOrientation) { result, error in
            guard let rotatedImages = result else {
                completion(nil, SImageError.cannotRotateImage)
                return
            }
            self.distributeRotatedImagesHorizontally(rotatedImages: rotatedImages) { result, error in
                guard let finalImage = result else {
                    completion(nil, error ?? SImageError.unknownError)
                    return
                }
                completion(finalImage, nil)
            }
        }
    }

    /// Creates a `CGImage` from the given `URL`.
    ///
    /// This function must be called from the main thread (to avoid possible performance issues).
    ///
    /// - Parameter url: `URL` where an image resided.
    /// - Throws: `SImageError.cannotCreateImage` in case `CGImageSourceCreateImageAtIndex` returns `nil`.
    /// `SImageError.cannotBeCalledFromMainThread` in case this function is running in the main thread.
    /// - Returns: `CGImage` created from the given `URL`.
    func createImage(from url: URL) throws -> CGImage {
        guard !Thread.isMainThread else {
            throw SImageError.cannotBeCalledFromMainThread
        }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                throw SImageError.cannotCreateImage(from: url)
        }
        return image
    }

    /// Creates `CGContext` using the given `CGSize` and `SImageSettings`.
    ///
    /// - Parameters:
    ///   - size: `CGSize` from which the `width` and `height` will be extracted.
    ///   - settings: `SImageSettings` from which `CGContext` parameters will be extracted (e.g.: `bitmapInfo`,
    ///   `bitsPerComponent`, `colorSpace`, etc).
    /// - Throws: `SImageError.cannotCreateContext` if the `CGContext` couldn't be created.
    /// - Returns: `CGContext` based on the given `CGSize` and `SImageSettings`.
    func context(for size: CGSize, settings: SImageSettings = SImageSettings()) throws -> CGContext {
        guard let newContext = CGContext(
            data: nil,
            width: Int(size.width.magnitude),
            height: Int(size.height.magnitude),
            bitsPerComponent: settings.contextBitsPerComponent,
            bytesPerRow: settings.contextBytesPerRow,
            space: settings.contextColorSpace,
            bitmapInfo: settings.contextBitmapInfo
            ) else {
                throw SImageError.cannotCreateContext
        }
        return newContext
    }
}
