import Foundation
import ImageIO
import Worker

/// Represents an image that was processed by the `SImage.rotateImages` function. Stores the image itself (`CGImage`)
/// along with its size (`CGSize`) after the rotation.
public struct RotatedImage {
    let image: CGImage
    let size: CGSize
}

// MARK: - Interface

public extension SImage {

    /// For each `URL` in the given array of `URL`s, this function:
    ///  1. Tries to create a `CGImage` from it
    ///  2. Extracts its metadata such as current orientation and size
    ///  3. Compares the above orientation with the given `targetOrientation`
    ///  4. Rotates the image if orientations do not match
    ///
    ///  In case an image doesn't need to be rotated, it will be returned "untouched" via the `RotatedImage` array in
    ///  the completion block.
    ///
    ///  Due to the memory pressure of related methods (i.e.: `CGImage` creation, context
    ///  `CGContext.draw(_:in:byTiling:)` and `CGContext.makeImage()`, etc), this function does **not** run on the
    ///  main thread but `DispatchQueue.global(qos: .userInitiated).async`.
    ///
    /// - Parameters:
    ///   - urls: An array of `URL`s from which the images to be rotated (and its metadata) can be extracted.
    ///   - settings: `SImageSettings` instance that stores rotation settings.
    ///   - completion: Block to be executed when the operation finishes. Carries the optional arguments
    ///   `[RotatedImage]`and `SImageError`.
    func rotateImages(from urls: [URL],
                      settings: SImageSettings,
                      completion: @escaping ([RotatedImage]?, SImageError?) -> Void) {
        guard urls.count > 1 else {
            completion(nil, SImageError.invalidNumberOfImages)
            return
        }
        var rotatedImages = [RotatedImage]()
        Worker.doBackgroundWork {
            do {
                for url in urls {
                    // Create image.
                    let image = try self.createImage(from: url)

                    /// Extract its metadata.
                    let imageSize = try self.imageSize(from: url)
                    let imageOrientation = settings.rotationIgnoreMissingMetadata ?
                        try? self.imageOrientation(from: url) : // Orientation may be nil.
                        try self.imageOrientation(from: url)    // Function may throw.

                    // Determine if the image needs to be rotated.
                    guard let currentOrientation = imageOrientation,
                        (currentOrientation.rawValue != 0)
                            && (currentOrientation != settings.rotationTargetOrientation) else {
                        // If rotation is not needed, store the image to be returned "untouched".
                        rotatedImages.append(RotatedImage(image: image, size: imageSize))
                        continue
                    }

                    // Define the rotation parameters.
                    let parameters = self.rotationParameters(from: currentOrientation,
                                                             to: settings.rotationTargetOrientation)
                    let rotationAngle = parameters.rotationAngle
                    let transformation = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))

                    // Rotate the context.
                    let newSize = self.size(for: transformation, on: imageSize)
                    var newContext = try self.context(for: newSize)
                    self.rotate(context: &newContext, size: newSize, rotationAngle: rotationAngle)

                    // Handle mirrored images.
                    self.handleMirroredImages(with: parameters, context: &newContext)

                    // Create and store the rotated image to be returned.
                    let rotatedImage = try self.drawAndMake(rotatedImage: image, context: newContext, size: imageSize)
                    rotatedImages.append(RotatedImage(image: rotatedImage, size: newSize))
                }
                completion(rotatedImages, nil)
            } catch {
                let simageError = (error as? SImageError) ?? SImageError.unknownError(error)
                completion(nil, simageError)
            }
        }
    }
}

// MARK: - Private

private extension SImage {

    /// Defines the required rotation angle and if an image needs to be horizontally or vertically flipped.
    ///
    /// On rotation angle: `.pi == 180`; `.pi/2 == 90`, `.pi/4 == 45`, `.pi/180 == 1`
    /// https://stackoverflow.com/a/47402811/584548 (comments)
    typealias RotationParameters = (rotationAngle: Float, flipHorizontally: Bool, flipVertically: Bool)

    /// Returns `RotationParameters` based on the given orientations.
    ///
    /// - Parameters:
    ///   - currentOrientation: `CGImagePropertyOrientation`, the current image orientation.
    ///   - targetOrientation: `CGImagePropertyOrientation`, the desired image orientation.
    /// - Returns: `RotationParameters` for the given orientations.
    func rotationParameters(from currentOrientation: CGImagePropertyOrientation,
                            to targetOrientation: CGImagePropertyOrientation) -> RotationParameters {
        switch targetOrientation {
        case .up:
            return rotationParametersTargetOrientationUp(currentOrientation: currentOrientation)
        case .upMirrored:
            return placeholder(currentOrientation: currentOrientation)
        case .down:
            return placeholder(currentOrientation: currentOrientation)
        case .downMirrored:
            return placeholder(currentOrientation: currentOrientation)
        case .leftMirrored:
            return placeholder(currentOrientation: currentOrientation)
        case .right:
            return placeholder(currentOrientation: currentOrientation)
        case .rightMirrored:
            return placeholder(currentOrientation: currentOrientation)
        case .left:
            return placeholder(currentOrientation: currentOrientation)
        }
    }

    /// Returns the `RotationParameters` for an `.up` `CGImagePropertyOrientation`, based on the given orientation.
    ///
    /// - Parameter currentOrientation: the current `CGImagePropertyOrientation` of the image.
    /// - Returns: `RotationParameters` for an `.up` `CGImagePropertyOrientation`, based on the given orientation.
    func rotationParametersTargetOrientationUp(currentOrientation: CGImagePropertyOrientation) -> RotationParameters {
        switch currentOrientation {
        case .up:
            return (0, false, false)
        case .upMirrored:
            return (0, true, false)
        case .down:
            return (.pi, false, false)
        case .downMirrored:
            return (.pi, true, false)
        case .leftMirrored:
            return (-(.pi/2), false, true)
        case .right:
            return (-(.pi/2), false, false)
        case .rightMirrored:
            return (.pi/2, false, true)
        case .left:
            return (.pi/2, false, false)
        }
    }

    /// To be defined later on.
    func placeholder(currentOrientation: CGImagePropertyOrientation) -> RotationParameters {
        return (0, false, false)
    }

    /// Rotates the given `CGContext` by the `rotationAngle`. Uses the given `CGSize` to move the origin to middle and
    /// rotate around it.
    ///
    /// - Parameters:
    ///   - context: `CGContext` to be rotated.
    ///   - size: `CGSize` that serves as input to `CGAffineTransform.translatedBy(x:y:)` (to move the origin to
    ///   middle).
    ///   - rotationAngle: `Float` representing the rotation angle e.g.: 90, 180, etc.
    func rotate(context: inout CGContext, size: CGSize, rotationAngle: Float) {
        context.translateBy(x: size.width/2, y: size.height/2)
        context.rotate(by: CGFloat(rotationAngle))
    }

    /// Draws (and makes) the given rotated `CGImage` in the given `CGContext` using the given `CGSize`. Returns a
    /// `CGImage` as result.
    ///
    /// - Parameters:
    ///   - image: `CGImage` that represents a rotated image.
    ///   - context: `CGContext` where the image is going to be draw and from where it will be made.
    ///   - size: `CGSize` used to create the `CGRect` where the image is drew.
    /// - Throws: `SImageError.cannotRotateImage` in case `CGContext.makeImage()` fails.
    /// - Returns: `CGImage` as a result of the above operations.
    func drawAndMake(rotatedImage image: CGImage, context: CGContext, size: CGSize) throws -> CGImage {
        let rect = CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        context.draw(image, in: rect)
        guard let resultImage = context.makeImage() else {
            throw SImageError.cannotRotateImage
        }
        return resultImage
    }

    /// Applies transformations (`CGAffineTransform`) into the given `CGContext` according to the `flipHorizontally` and
    /// `flipHorizontally` properties of the `RotationParameters`.
    ///
    /// - Parameters:
    ///   - parameters: `RotationParameters` that defines if an image should be horizontally or vertically flipped.
    ///   - context: `CGContext` in which a `CGAffineTransform` may be applied.
    func handleMirroredImages(with parameters: RotationParameters, context: inout CGContext) {
        if parameters.flipHorizontally {
            let flipHorizontal = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
            context.concatenate(flipHorizontal)
        }
        if parameters.flipVertically {
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
            context.concatenate(flipVertical)
        }
    }
}
