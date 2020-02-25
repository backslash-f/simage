import SwiftUI

/// Holds `Error`s that can be thrown by `SImage` operations.
public enum SImageError: Error {
    case cannotBeCalledFromMainThread
    case cannotCreateContext
    case cannotCreateImage(from: URL?)
    case cannotDistributeImagesHorizontally
    case cannotGetImageOrientation(from: URL)
    case cannotGetImageProperties(from: URL)
    case cannotGetImageSize(from: URL)
    case cannotRotateImage
    case cannotSaveImage
    case invalidHeight
    case invalidNumberOfImages
    case unknownError
}
