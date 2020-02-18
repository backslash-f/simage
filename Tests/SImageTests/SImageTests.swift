import XCTest
import Worker

@testable import SImage

final class SImageTests: XCTestCase {

    // MARK: - Public Properties

    static var allTests = [
        ("testCreateCGImage", testCreateCGImage),
        ("testCreateCGImageFromMainThread", testCreateCGImageFromMainThread),
        ("testCombiningImagesProducesExpectedOutput", testCombiningImagesProducesExpectedOutput)
    ]

    // MARK: - Private Properties

    private var resourcesPath: URL {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL.deletingLastPathComponent().appendingPathComponent("Resources")
    }
    private var resultImageURL: URL {
        self.urlForImage(named: self.resultImagePrefix)
    }
    private var expectedImageURL: URL {
        self.urlForImage(named: self.resultImageExpectedPrefix)
    }
    private let simage = SImage()
    private let imagePrefix = "image_"
    private let resultImagePrefix = "result_image"
    private let resultImageExpectedPrefix = "result_image_expected"
    private static let jpgSuffix = ".jpg"
}

// MARK: - Tests

extension SImageTests {

    /// Tests that a `CGImage` can be created from a (valid) image `URL`.
    func testCreateCGImage() {
        let imageURL = randomImageURL()
        let imageCreationExpectation = expectation(description: "Image created successfully.")

        Worker.doBackgroundWork { [weak self] in
            guard let self = self else {
                XCTFail("Self is no more...")
                return
            }
            do {
                let cgImage = try self.simage.createImage(from: imageURL)
                guard cgImage.height > 0, cgImage.width > 0 else {
                    XCTFail("Invalid image dimensions. Height: \(cgImage.height)), Width: \(cgImage.width)).")
                    return
                }
                imageCreationExpectation.fulfill()
            } catch {
                XCTFail("Cannot create an image. Error: \(error)")
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    /// Tests that `SImage` throws an error if called from the main thread.
    func testCreateCGImageFromMainThread() {
        let imageURL = randomImageURL()
        let description = "SImage.createImage(from:) must fail on the main thread."
        let mainThreadErrorExpectation = expectation(description: description)

        Worker.doMainThreadWork {
            [weak self] in
            guard let self = self else {
                XCTFail("Self is no more...")
                return
            }
            do {
                _ = try self.simage.createImage(from: imageURL)
            } catch {
                guard case SImageError.cannotBeCalledFromMainThread = error else {
                    XCTFail("SImage.combineImages(source:settings:completion:) must fail on the main thread.")
                    return
                }
                mainThreadErrorExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    /// Tests that images are combined as expected using the default `SImageSettings` (e.g.: target orientation ==
    /// CGImagePropertyOrientation = .up).
    func testCombiningImagesProducesExpectedOutput() {
        let matchesOutputExpectation = expectation(description: "Combined images output matches expected one.")
        let sourceURLs = imageSourceURLs()

        simage.combineImages(source: sourceURLs) { [weak self] image, error in
            guard error == nil else {
                XCTFail("Couldn't combine images. Error: \(String(describing: error))")
                return
            }
            guard let combinedImages = image else {
                XCTFail("Couldn't combine images.")
                return
            }
            guard self?.persistResultImage(combinedImages) == true else {
                XCTFail("Couldn't persist the combined images.")
                return
            }

            Worker.doBackgroundWork { [weak self] in
                guard let self = self else {
                    XCTFail("Self is no more...")
                    return
                }
                guard let resultImageAndData = self.imageAndDataFrom(url: self.resultImageURL),
                    let expectedImageAndData = self.imageAndDataFrom(url: self.expectedImageURL) else {
                        XCTFail("Couldn't get images and data.")
                        return
                }
                let resultSize = CGSize(width: resultImageAndData.image.width, height: resultImageAndData.image.height)
                let expectedSize = CGSize(width: expectedImageAndData.image.width, height: expectedImageAndData.image.height)
                guard resultSize == expectedSize else {
                    XCTFail("The result image size is not equal to the expected image size.")
                    return
                }
                guard resultImageAndData.data == expectedImageAndData.data else {
                    XCTFail("The result image is not equal to the expected image.")
                    return
                }
                matchesOutputExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

// MARK: - Private

private extension SImageTests {

    /// Retrieves a random image URL as in, for example, the URL for "image_7". Return it as an `URL`.
    func randomImageURL() -> URL {
        let randomImageNumber = (0..<9).randomElement() ?? 0
        let imageName = "\(imagePrefix)\(randomImageNumber).jpg"
        return resourcesPath.appendingPathComponent(imageName, isDirectory: false)
    }

    /// Retrieves the URL for all test images, from "image_0" to "image_8". Returns it in an `[URL]`.
    func imageSourceURLs() -> [URL] {
        var sourceURLs = [URL]()
        for n in 0..<9 {
            let imageURL = resourcesPath.appendingPathComponent("\(imagePrefix)\(n).jpg", isDirectory: false)
            sourceURLs.append(imageURL)
        }
        return sourceURLs
    }

    /// Retrieves the URL for a specific image, e.g. "result_image". Suffix defaults to ".jpg".
    func urlForImage(named: String, prefix: String = jpgSuffix) -> URL {
        resourcesPath.appendingPathComponent(named + prefix, isDirectory: false)
    }

    func persistResultImage(_ cgImage: CGImage, suffix: String = jpgSuffix) -> Bool {
        let filename = resultImagePrefix + suffix
        let resultImageURL = self.resourcesPath.appendingPathComponent(filename, isDirectory: false)
        guard let destination = CGImageDestinationCreateWithURL(resultImageURL as CFURL, kUTTypeJPEG, 1, nil) else {
            return false
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        return CGImageDestinationFinalize(destination)
    }

    typealias ImageAndData = (image: CGImage, data: CFData)
    func imageAndDataFrom(url: URL) -> ImageAndData? {
        guard let cgImage = try? simage.createImage(from: url),
            let cfData = cgImage.dataProvider?.data else {
                return nil
        }
        return (cgImage, cfData)
    }
}
