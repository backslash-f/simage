import SwiftUI
import Worker

public extension SImage {

    /// Creates a `CGContext` to "draw" and "make" a `CGImage` using the given `RotatedImage`s. Distributes the images
    /// horizontally.
    ///
    /// - Parameters:
    ///   - rotatedImages: The `RotateImage`s to be distributed horizontally.
    ///   - completion: Code to be executed after the distribute / draw / make operations finish. Returns an optional
    /// `CGImage` that represents the result of those operations and an optional `Error`
    /// (`SImageError.cannotCreateImage`).
    func distributeRotatedImagesHorizontally(rotatedImages: [RotatedImage],
                                             completion: @escaping (CGImage?, Error?) -> Void) {
        Worker.doBackgroundWork {
            do {
                let size = try self.horizontalSize(for: rotatedImages)
                let context = try self.context(for: size)
                var xPosition = 0
                var lastWidth = 0
                rotatedImages.enumerated().forEach { index, rotatedImage in
                    let image = rotatedImage.image
                    if index > 0 {
                        xPosition += lastWidth
                    }
                    let rect = CGRect(x: xPosition, y: 0, width: image.width, height: image.height)
                    context.draw(image, in: rect, byTiling: false)
                    lastWidth = image.width
                }
                guard let image = context.makeImage() else {
                    completion(nil, SImageError.cannotCreateImage(from: nil))
                    return
                }
                completion(image, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
