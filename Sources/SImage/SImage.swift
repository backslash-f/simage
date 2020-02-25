import SwiftUI
import Worker

/// Wrapper around `Core Graphics` that can provide functionalities such as image combination, image rotation, etc.
/// Because it relies on Core Graphics, it's multi-platform. It can run in macOS, iOS, iPadOS, tvOS, watchOS.
public struct SImage {
    public init() {}
}

// MARK: - Interface

public extension SImage {

    /// Combines the given images using settings from the given `SImageSettings`.
    ///
    /// This function does not take the image orientation into consideration. That is: it won't fix images that
    /// have rotation different than `SImageSettings.getter:targetOrientation`. Reason is: the rotation algorithm
    /// relies on the image metadata, which may not be present in a `CGImage` instance.
    ///
    /// - Parameters:
    ///   - urls: array of `CGImage` representing the images to be combined.
    ///   - settings: `SImageSettings` that stores combination / `CGContext` creation settings.
    ///   - completion: Code to be executed after the operations finished. Returns optionals `CGImage` and
    ///   `SImageError`.
    func combine(images: [CGImage],
                 settings: SImageSettings = SImageSettings(),
                 completion: @escaping (CGImage?, SImageError?) -> Void) {
        guard images.count > 1 else {
            completion(nil, SImageError.invalidNumberOfImages)
            return
        }
        distributeImagesHorizontally(images: images) { result, error in
            guard let finalImage = result else {
                completion(nil, error ?? SImageError.unknownError)
                return
            }
            completion(finalImage, nil)
        }
    }
    
    /// Combines the images in the given array of `URL` using settings from the given `SImageSettings`.
    ///
    /// Images are rotated via `SImage.rotateImages`, if necessary. Then the images are horizontally combined.
    /// Expensive operations runs on `DispatchQueue.global(qos: .userInitiated).async`.
    ///
    /// - Parameters:
    ///   - urls: array of `URL` where the images to be combined can be extracted.
    ///   - settings: `SImageSettings` that stores combination / `CGContext` creation settings.
    ///   - completion: Code to be executed after the operations finished. Returns optionals `CGImage` and
    ///   `SImageError`.
    func combineImages(source urls: [URL],
                       settings: SImageSettings = SImageSettings(),
                       completion: @escaping (CGImage?, SImageError?) -> Void) {
        rotateImages(in: urls, targetOrientation: settings.targetOrientation) { result, error in
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

    /// Creates a thumbnail from the image at the given `URL` via `CGImageSourceCreateThumbnailAtIndex(_:_:_:)`.
    ///
    /// Notice: the thumbnail creation happens in a background thread (via `Worker.doBackgroundWork(_:)`).
    ///
    /// - Parameters:
    ///   - url: `URL` from where the source image is coming from.
    ///   - settings: `SImageSettings` that stores thumbnail creation settings.
    ///   - completion: Block to be executed after the thumbnail creation finishes. Returns an optional `CGImage`.
    func createThumbnail(from url: URL,
                         settings: SImageSettings = SImageSettings(),
                         completion: @escaping (CGImage?) -> Void) {
        let options = createThumbnailOptions(with: settings)
        Worker.doBackgroundWork {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, options),
                let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
                    completion(nil)
                    return
            }
            completion(cgImage)
        }
    }

    /// Saves the given `CGImage` in the `userDirectory` as `SImage.png` (by default). These default options can be
    /// overridden by passing in a custom `SImageSettings` instance or by passing a `URL` as arguments.
    ///
    /// - Parameters:
    ///   - image: `CGImage` to be saved.
    ///   - destinationURL: Optional `URL` in which the given image should be saved.
    ///   - settings: `SImageSettings` that stores thumbnail creation settings.
    ///   - completion: Block to be executed after the image is saved creation finishes. Returns optionals `URL` (where
    ///   the image was saved) and `SImageError`.
    func save(image: CGImage,
              destinationURL: URL? = nil,
              settings: SImageSettings = SImageSettings(),
              completion: @escaping (URL?, SImageError?) -> Void) {

        do {
            // Image destination URL.
            let imgDestinationURL: URL
            if let givenURL = destinationURL {
                imgDestinationURL = givenURL.appendingPathComponent(settings.saveFilename)
            } else {
                imgDestinationURL = try imageDestinationURL()
            }

            // Image destination.
            guard let imgDestination = imageDestination(url: imgDestinationURL) else {
                completion(nil, .cannotSaveImage)
                return
            }

            // Persistence.
            CGImageDestinationAddImage(imgDestination, image, nil)
            guard CGImageDestinationFinalize(imgDestination) else {
                completion(nil, .cannotSaveImage)
                return
            }

            // Happy path.
            completion(imgDestinationURL, nil)

        } catch {
            completion(nil, .cannotSaveImage)
        }
    }
}
