import Foundation
import ImageIO
import Worker

/// Wrapper around `Core Graphics` that can provide functionalities such as image combination, image rotation, etc.
/// Because it relies on Core Graphics, it's multi-platform. It can run in macOS, iOS, iPadOS, tvOS, watchOS.
public struct SImage {

    // MARK: - Properties

    /// Set it to `true` in order to see  logging information in Xcode's Console or
    /// in the macOS Console app.
    ///
    /// In the Console app, you can filter SImage's output by `SUBSYSTEM`:
    /// `com.backslash-f.SImage`.
    public var isLoggingEnabled = false

    // MARK: - Lifecycle

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
    ///   - images: array of `CGImage` representing the images to be combined.
    ///   - settings: `SImageSettings` that stores combination / `CGContext` creation settings.
    ///   - completion: Code to be executed after the operations finished. Returns optionals `CGImage` and
    ///   `SImageError`.
    func combine(images: [CGImage],
                 settings: SImageSettings = SImageSettings(),
                 completion: @escaping (CGImage?, SImageError?) -> Void) {
        log("Started combining images", category: .combining)
        log("Number of images: \(images.count)", category: .combining)
        guard images.count > 1 else {
            let error = SImageError.invalidNumberOfImages
            log(error)
            completion(nil, error)
            return
        }
        distributeImagesHorizontally(images: images) { result, error in
            guard let finalImage = result else {
                completion(nil, error ?? SImageError.unknownError(error))
                return
            }
            log("Finished combining images", category: .combining)
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
    func combineImages(from urls: [URL],
                       settings: SImageSettings = SImageSettings(),
                       completion: @escaping (CGImage?, SImageError?) -> Void) {
        log("Started combining images from URLs", category: .combining)
        log("Number of URLs: \(urls.count)", category: .combining)
        rotateImages(from: urls, settings: settings) { result, error in
            guard let rotatedImages = result else {
                completion(nil, error ?? SImageError.unknownError(error))
                return
            }
            self.distributeRotatedImagesHorizontally(rotatedImages: rotatedImages) { result, error in
                guard let finalImage = result else {
                    completion(nil, error ?? SImageError.unknownError(error))
                    return
                }
                log("Finished combining images from URLs", category: .combining)
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
        log("Started creating a CGContext", category: .creating)
        guard let newContext = CGContext(
            data: nil,
            width: Int(size.width.magnitude),
            height: Int(size.height.magnitude),
            bitsPerComponent: settings.contextBitsPerComponent,
            bytesPerRow: settings.contextBytesPerRow,
            space: settings.contextColorSpace,
            bitmapInfo: settings.contextBitmapInfo
        ) else {
            let error = SImageError.cannotCreateContext
            log(error)
            throw error
        }
        log("Finished creating a CGContext. Result: \(newContext)", category: .creating)
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
        log("Started creating CGImage", category: .creating)
        guard !Thread.isMainThread else {
            let error = SImageError.cannotBeCalledFromMainThread
            log(error)
            throw error
        }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            log("Could not create the CGImage. CGImageSourceCreateWithURL returned nil",
                category: .creating)
            let error = SImageError.cannotCreateImage(from: url)
            log(error)
            throw error
        }
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            log("Could not create the CGImage. CGImageSourceCreateImageAtIndex returned nil",
                category: .creating)
            let error = SImageError.cannotCreateImage(from: url)
            log(error)
            throw error
        }
        log("Finished creating CGImage. Result: \(image)", category: .creating)
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
        log("Started creating thumbnail", category: .thumbnail)
        log("Source URL: \(url)", category: .thumbnail)
        let options = createThumbnailOptions(with: settings)
        log("Settings: \(settings)", category: .thumbnail)
        Worker.doBackgroundWork {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, options) else {
                log("Could not create the thumbnail. CGImageSourceCreateWithURL returned nil",
                    category: .thumbnail)
                completion(nil)
                return
            }
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
                log("Could not create the thumbnail. CGImageSourceCreateThumbnailAtIndex returnd nil",
                    category: .thumbnail)
                completion(nil)
                return
            }
            log("Finished creating thumbnail", category: .thumbnail)
            completion(cgImage)
        }
    }

    /// Saves the given `CGImage` as `SImage.png` in the `userDirectory` (by default).
    ///
    /// The default options can be overridden by passing in a custom `SImageSettings` instance.
    ///
    /// - Parameters:
    ///   - image: `CGImage` to be saved.
    ///   - settings: `SImageSettings` that stores saving settings, such as filename and destination `URL`.
    ///   - completion: Block to be executed after the image is saved creation finishes. Returns optionals `URL` (where
    ///   the image was saved) and `SImageError`.
    func save(image: CGImage,
              settings: SImageSettings = SImageSettings(),
              completion: @escaping (URL?, SImageError?) -> Void) {
        log("Started saving image", category: .saving)
        log("Settings: \(settings)", category: .saving)
        guard let imgDestination = imageDestination(settings: settings) else {
            let error = SImageError.cannotSaveImage
            log(error)
            completion(nil, error)
            return
        }
        CGImageDestinationAddImage(imgDestination, image, nil)
        guard CGImageDestinationFinalize(imgDestination) else {
            let error = SImageError.cannotSaveImage
            log(error)
            completion(nil, error)
            return
        }
        log("Finished saving image", category: .saving)
        completion(settings.saveDestinationURL, nil)
    }
}
