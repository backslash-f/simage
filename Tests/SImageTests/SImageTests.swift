import XCTest
import Worker

@testable import SImage

final class SImageTests: XCTestCase {

    // MARK: - Public Properties

    static var allTests = [
        ("testCreateCGImage", testCreateCGImage),
        ("testCreateCGImageFromMainThread", testCreateCGImageFromMainThread),
        ("testCombineImagesFromURL", testCombineImagesFromURL),
        ("testCombineImages", testCombineImages),
        ("testCreateThumbnail", testCreateThumbnail),
        ("testCreateThumbnailWithMaxPixelSize", testCreateThumbnailWithMaxPixelSize)
    ]

    // MARK: - Private Properties

    private var resourcesPath: URL {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL.deletingLastPathComponent().appendingPathComponent("Resources")
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
                XCTAssertTrue(cgImage.height > 0, "Invalid height: \(cgImage.height)")
                XCTAssertTrue(cgImage.width > 0, "Invalid height: \(cgImage.width)")
                imageCreationExpectation.fulfill()
            } catch {
                XCTFail("Cannot create an image.💥 Error: \(error)")
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

    /// Tests that images are combined via image `URL`s (`SImage.combineImages(source:settings:completion:)`).
    func testCombineImagesFromURL() {
        let imageURLs = imageSourceURLs()
        let combineExpectation = expectation(description: "Images combined successfully.")

        simage.combineImages(source: imageURLs) { image, error in
            if let error = error {
                XCTFail("Could not combine the images.💥 Error: \(error).")
            } else if let image = image {
                XCTAssertTrue(image.height == 1800, "Invalid height: \(image.height)")
                XCTAssertTrue(image.width == 10800, "Invalid height: \(image.width)")
                combineExpectation.fulfill()
            } else {
                XCTFail("Could not combine the images")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Tests that an array of `CGImage` are combined via `SImage.combine(images:settings:completion:)`.
    func testCombineImages() {
        let combineExpectation = expectation(description: "Images combined successfully.")
        var sourceImages = [CGImage]()

        Worker.doBackgroundWork { [weak self] in
            guard let self = self else {
                XCTFail("Self is no more...")
                return
            }
            for n in 0..<9 {
                let imageURL = self.resourcesPath.appendingPathComponent("\(self.imagePrefix)\(n).jpg", isDirectory: false)
                if let imageFromURL = try? self.simage.createImage(from: imageURL) {
                    sourceImages.append(imageFromURL)
                }
            }

            self.simage.combine(images: sourceImages) { image, error in
                if let error = error {
                    XCTFail("Could not combine the images.💥 Error: \(error).")
                } else if let image = image {
                    XCTAssertTrue(image.height == 1800, "Invalid height: \(image.height)")
                    XCTAssertTrue(image.width == 13200, "Invalid height: \(image.width)")
                    combineExpectation.fulfill()
                } else {
                    XCTFail("Could not combine the images")
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Tests that a thumbnail is created via `SImage.createThumbnail(from:settings:completion:)`.
    func testCreateThumbnail() {
        let thumbnailCreationExpectation = expectation(description: "A thumbnail was successfully created.")
        let imageURL = randomImageURL()

        simage.createThumbnail(from: imageURL) { cgImage in
            guard let thumbnail = cgImage else {
                XCTFail("The thumbnail was not created.")
                return
            }
            XCTAssertTrue(thumbnail.height > 0, "Invalid height: \(thumbnail.height)")
            XCTAssertTrue(thumbnail.width > 0, "Invalid height: \(thumbnail.width)")
            thumbnailCreationExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Tests that a thumbnail is correctly created via `SImage.createThumbnail(from:settings:completion:)` after
    /// specifying the `maxPixelSize` (`SImageSettings.getter:thumbsMaxPixelSize`).
    func testCreateThumbnailWithMaxPixelSize() {
        let thumbnailCreationExpectation = expectation(description: """
            A thumbnail with maxPixelSize == 50 was successfully created.
        """)
        let imageURL = randomImageURL()
        let settings = SImageSettings(thumbsMaxPixelSize: "50")

        simage.createThumbnail(from: imageURL, settings: settings) { cgImage in
            guard let thumbnail = cgImage else {
                XCTFail("The thumbnail was not created.")
                return
            }
            XCTAssertTrue(thumbnail.height == 50 || thumbnail.width == 50)
            thumbnailCreationExpectation.fulfill()
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
}
