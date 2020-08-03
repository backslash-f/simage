import ImageIO
import Worker

internal extension SImage {

    /// Creates a `CGContext` to "draw" and "make" a `CGImage` using the given `RotatedImage`s. Distributes the images
    /// horizontally.
    ///
    /// - Parameters:
    ///   - rotatedImages: The `RotatedImage`s to be distributed horizontally.
    ///   - completion: Code to be executed after the distribute / draw / make operations finish. Returns an optional
    /// `CGImage` that represents the result of those operations and an optional `SImageError`.
    func distributeRotatedImagesHorizontally(rotatedImages: [RotatedImage],
                                             completion: @escaping (CGImage?, SImageError?) -> Void) {
        let images = rotatedImages.compactMap { $0.image }
        distributeImagesHorizontally(images: images) { image, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let image = image else {
                completion(nil, SImageError.cannotDistributeImagesHorizontally)
                return
            }
            completion(image, nil)
        }
    }

    /// Creates a `CGContext` to "draw" and "make" a `CGImage` using the given `CGImage`s. Distributes the images
    /// horizontally.
    ///
    /// - Parameters:
    ///   - images: The `CGImage`s to be distributed horizontally.
    ///   - completion: Code to be executed after the distribute / draw / make operations finish. Returns an optional
    /// `CGImage` that represents the result of those operations and an optional `SImageError`.
    func distributeImagesHorizontally(images: [CGImage], completion: @escaping (CGImage?, SImageError?) -> Void) {
        guard images.count > 1 else {
            completion(nil, SImageError.invalidNumberOfImages)
            return
        }
        Worker.doBackgroundWork {
            do {
                let size = try self.horizontalSize(for: images)
                let context = try self.context(for: size)
                var xPosition = 0
                var lastWidth = 0
                images.enumerated().forEach { index, cgImage in
                    if index > 0 {
                        xPosition += lastWidth
                    }
                    let rect = CGRect(x: xPosition, y: 0, width: cgImage.width, height: cgImage.height)
                    context.draw(cgImage, in: rect, byTiling: false)
                    lastWidth = cgImage.width
                }
                guard let createdImage = context.makeImage() else {
                    completion(nil, SImageError.cannotDistributeImagesHorizontally)
                    return
                }
                completion(createdImage, nil)
            } catch {
                completion(nil, error as? SImageError)
            }
        }
    }
}
