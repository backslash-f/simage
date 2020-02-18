import XCTest
import Worker

@testable import SImage

final class SImageTests: XCTestCase {

    // MARK: - Public Properties

    static var allTests = [
        ("testExample", testCreateCGImage),
    ]

    // MARK: - Private Properties

    private var resourcesPath: URL {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL.deletingLastPathComponent().appendingPathComponent("Resources")
    }

    private var imagePrefix: String {
        "image_"
    }
}

// MARK: - Tests

extension SImageTests {

    func testCreateCGImageFromMainThread() {
        let imageURL = randomImageURL()
        let description = "SImage.createImage(from:) must fail on the main thread."
        let mainThreadErrorExpectation = expectation(description: description)

        Worker.doMainThreadWork {
            do {
                _ = try SImage().createImage(from: imageURL)
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

    func testCreateCGImage() {
        let imageURL = randomImageURL()
        let imageCreationExpectation = expectation(description: "Image created successfully.")

        Worker.doBackgroundWork {
            do {
                let cgImage = try SImage().createImage(from: imageURL)
                guard cgImage.height > 0, cgImage.width > 0 else {
                    XCTFail("Invalid image dimensions. Height: \(cgImage.height)), Width: \(cgImage.width)).")
                    return
                }
                imageCreationExpectation.fulfill()
            } catch {
                XCTFail("Cannot create an image. Error: \(error).")
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCombineImages() {
        let imageURLs = imageSourceURLs()
        let combineExpectation = expectation(description: "Images combined successfully.")

        SImage().combineImages(source: imageURLs) { image, error in
            if let error = error {
                handleError(error)
            } else if let image = image {
                guard image.height == 1800, image.width == 10800 else {
                    XCTFail("Invalid image dimensions. Height: \(image.height)), Width: \(image.width)).")
                    return
                }
                combineExpectation.fulfill()

            } else {
                handleError()
            }
        }

        func handleError(_ error: Error? = nil) {
            XCTFail("Could not combine the images. Error: \(String(describing: error)).")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testCombiningImagesProducesExpectedOutput() {
        let equalImagesExpectation = expectation(description: "Images are equal.")
        let sourceURLs = imageSourceURLs()
        let simage = SImage()

        simage.combineImages(source: sourceURLs) { image, error in
            guard error == nil else {
                XCTFail("Couldn't combine images. Error: \(String(describing: error)).")
                return
            }
            guard let combinedImages = image else {
                XCTFail("Couldn't combine images.")
                return
            }
            guard let combinedImagesData = combinedImages.dataProvider?.data else {
                XCTFail("Couldn't get combined image data.")
                return
            }

            Worker.doBackgroundWork { [weak self] in
                guard let self = self else {
                    XCTFail("Self is no more...")
                    return
                }
                let expectedImageURL = self.urlForImage(named: "result_image")
                guard let expectedImage = try? simage.createImage(from: expectedImageURL) else {
                    XCTFail("Couldn't create the expected image from URL: \(expectedImageURL).")
                    return
                }
                guard let expectedImageData = expectedImage.dataProvider?.data else {
                    XCTFail("Couldn't get expected image data.")
                    return
                }
                guard combinedImagesData == expectedImageData else {
                    XCTFail("The result image is not equal to the expected image.")
                    return
                }
                equalImagesExpectation.fulfill()
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
    func urlForImage(named: String, prefix: String = ".jpg") -> URL {
        resourcesPath.appendingPathComponent(named, isDirectory: false)
    }
}
