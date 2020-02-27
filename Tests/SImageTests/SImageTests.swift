import XCTest
import Worker

@testable import SImage

final class SImageTests: XCTestCase {

    // MARK: - Public Properties

    static var allTests = [
        ("testCombineImages", testCombineImages),
        ("testCombineImagesFromURL", testCombineImagesFromURL),
        ("testCombineImageNoOrientationInfoThrows", testCombineImageNoOrientationInfoThrows),
        ("testCreateCGImage", testCreateCGImage),
        ("testCreateCGImageFromMainThread", testCreateCGImageFromMainThread),
        ("testCreateThumbnail", testCreateThumbnail),
        ("testCreateThumbnailWithMaxPixelSize", testCreateThumbnailWithMaxPixelSize),
        ("testSaveImage", testSaveImage),
        ("testSaveImageInCustomFilenameAndDestinationURL", testSaveImageInCustomFilenameAndDestinationURL)
    ]

    // MARK: - Private Properties

    private var resourcesPath: URL {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL.deletingLastPathComponent().appendingPathComponent("Resources")
    }
    private let imagePrefix = "image_"
    private let resultImagePrefix = "result_image"
    private let resultImageExpectedPrefix = "result_image_expected"
    private static let jpgSuffix = ".jpg"
}

// MARK: - Tests

extension SImageTests {

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
                let imageURL = self.resourcesPath.appendingPathComponent(
                    "\(self.imagePrefix)\(n).jpg",
                    isDirectory: false
                )
                if let imageFromURL = try? SImage().createImage(from: imageURL) {
                    sourceImages.append(imageFromURL)
                }
            }

            SImage().combine(images: sourceImages) { image, error in
                XCTAssertNil(error, "Could not save the image. 💥 Error: \(error ?? SImageError.unknownError(error)).")
                guard let image = image else {
                    XCTFail("Could not combine the images.")
                    return
                }
                XCTAssertTrue(image.height == 1800, "Invalid height: \(image.height).")
                XCTAssertTrue(image.width == 13200, "Invalid height: \(image.width).")
                combineExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Tests that images are combined via image `URL`s (`SImage.combineImages(source:settings:completion:)`).
    func testCombineImagesFromURL() {
        let combineExpectation = expectation(description: "Images combined successfully.")
        let imageURLs = imageSourceURLs()

        SImage().combineImages(source: imageURLs) { image, error in
            XCTAssertNil(error, "Could not save the image. 💥 Error: \(error ?? SImageError.unknownError(error)).")
            guard let image = image else {
                XCTFail("Could not combine the images.")
                return
            }
            XCTAssertTrue(image.height == 1800, "Invalid height: \(image.height).")
            XCTAssertTrue(image.width == 10800, "Invalid height: \(image.width).")
            combineExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Tests combining images when one of them doesn't have orientation info. In this scenario, an error is expected.
    func testCombineImageNoOrientationInfoThrows() {
        let cantCombineExpectation = expectation(description: "Can't combine images: no orientation info.")
        let imageURLs = [randomImageURL(), noOrientationImageURL()]

        Worker.doBackgroundWork {
            SImage().combineImages(source: imageURLs) { image, error in
                XCTAssertNil(image, "Expected the result image to be nil.")
                guard let simageError = error else {
                    XCTFail("Expected an error, got nil instead.")
                    return
                }
                guard case SImageError.cannotGetImageOrientation = simageError else {
                    XCTFail("Expected \"SImageError.cannotGetImageOrientation\" but \"\(simageError)\" was threw.")
                    return
                }
                cantCombineExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Tests that a `CGImage` can be created from a (valid) image `URL`.
    func testCreateCGImage() {
        let imageCreationExpectation = expectation(description: "Image created successfully.")
        let imageURL = randomImageURL()

        Worker.doBackgroundWork {
            do {
                let cgImage = try SImage().createImage(from: imageURL)
                XCTAssertTrue(cgImage.height > 0, "Invalid height: \(cgImage.height).")
                XCTAssertTrue(cgImage.width > 0, "Invalid height: \(cgImage.width).")
                imageCreationExpectation.fulfill()
            } catch {
                XCTFail("Cannot create an image. 💥 Error: \(error).")
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    /// Tests that `SImage` throws an error if called from the main thread.
    func testCreateCGImageFromMainThread() {
        let description = "SImage.createImage(from:) must fail on the main thread."
        let mainThreadErrorExpectation = expectation(description: description)
        let imageURL = randomImageURL()

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

    /// Tests that a thumbnail is created via `SImage.createThumbnail(from:settings:completion:)`.
    func testCreateThumbnail() {
        let thumbnailCreationExpectation = expectation(description: "A thumbnail was successfully created.")
        let imageURL = randomImageURL()

        SImage().createThumbnail(from: imageURL) { cgImage in
            guard let thumbnail = cgImage else {
                XCTFail("The thumbnail was not created.")
                return
            }
            XCTAssertTrue(thumbnail.height > 0, "Invalid height: \(thumbnail.height).")
            XCTAssertTrue(thumbnail.width > 0, "Invalid height: \(thumbnail.width).")
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

        SImage().createThumbnail(from: imageURL, settings: settings) { cgImage in
            guard let thumbnail = cgImage else {
                XCTFail("The thumbnail was not created.")
                return
            }
            let expectation = thumbnail.height == 50 || thumbnail.width == 50
            let message = "Invalid thumbnail size. Height: \(thumbnail.height), Width: \(thumbnail.width)."
            XCTAssertTrue(expectation, message)
            thumbnailCreationExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSaveImage() {
        let saveImageExpectation = expectation(description: "Image saved successfully.")
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let expectedImageFilename = SImageSettings.defaultImageFilename
        let expectedImageURL = temporaryDirectory.appendingPathComponent(expectedImageFilename)

        Worker.doBackgroundWork { [weak self] in
            guard let self = self else {
                XCTFail("Self is no more...")
                return
            }
            guard let image = self.randomImage() else {
                XCTFail("Could not retrieve a resource image.")
                return
            }

            SImage().save(image: image) { url, error in
                XCTAssertNil(error, "Could not save the image. 💥 Error: \(error ?? SImageError.unknownError(error)).")
                guard let savedImageURL = url else {
                    XCTFail("The saved image URL is nil.")
                    return
                }

                // Image file exists.
                let imageExistsExpression = FileManager.default.fileExists(atPath: savedImageURL.path)
                XCTAssertTrue(imageExistsExpression, "The image file could not be found at \(savedImageURL).")

                // Expected URLs match.
                let unexpectedURLMessage = """
                The image was not save in the expected temporary directory.
                Expected URL: \(expectedImageURL)
                Actual URL: \(savedImageURL)
                """
                XCTAssertEqual(savedImageURL, expectedImageURL, unexpectedURLMessage)

                saveImageExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSaveImageInCustomFilenameAndDestinationURL() {
        let saveImageExpectation = expectation(description: "Image saved successfully in custom destination URL.")
        let customFilename = "Custom_Filename.png"
        let customDestinationURL = self.resourcesPath
        let settings = SImageSettings(saveFilename: customFilename, saveDestinationURL: customDestinationURL)
        let expectedImageURL = settings.saveDestinationURL

        Worker.doBackgroundWork { [weak self] in
            guard let self = self else {
                XCTFail("Self is no more...")
                return
            }
            guard let image = self.randomImage() else {
                XCTFail("Could not retrieve a resource image.")
                return
            }

            SImage().save(image: image, settings: settings) { url, error in
                XCTAssertNil(error, "Could not save the image. 💥 Error: \(error ?? SImageError.unknownError(error)).")
                guard let savedImageURL = url else {
                    XCTFail("The saved image URL is nil.")
                    return
                }

                // Image file exists.
                let imageExistsExpression = FileManager.default.fileExists(atPath: savedImageURL.path)
                XCTAssertTrue(imageExistsExpression, "The image file could not be found at \(savedImageURL).")

                // Expected URLs match.
                let unexpectedURLMessage = """
                The image was not save in the expected temporary directory.
                Expected URL: \(settings)
                Actual URL: \(savedImageURL)
                """
                XCTAssertEqual(savedImageURL, expectedImageURL, unexpectedURLMessage)

                saveImageExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

// MARK: - Private

private extension SImageTests {

    /// Retrieves the URL for all test images, from "image_0" to "image_8". Returns it in an `[URL]`.
    func imageSourceURLs() -> [URL] {
        var sourceURLs = [URL]()
        for n in 0..<9 {
            let imageURL = resourcesPath.appendingPathComponent("\(imagePrefix)\(n).jpg", isDirectory: false)
            sourceURLs.append(imageURL)
        }
        return sourceURLs
    }

    /// Retrieves a `URL` of a `CGImage` that has no orientation information.
    func noOrientationImageURL() -> URL {
        return resourcesPath.appendingPathComponent("no_orientation.png", isDirectory: false)
    }

    /// Retrieves a random `CGImage`.
    func randomImage() -> CGImage? {
        return try? SImage().createImage(from: randomImageURL())
    }

    /// Retrieves a random image URL as in, for example, the URL for "image_7". Return it as an `URL`.
    func randomImageURL() -> URL {
        let randomImageNumber = (0..<9).randomElement() ?? 0
        let imageName = "\(imagePrefix)\(randomImageNumber).jpg"
        return resourcesPath.appendingPathComponent(imageName, isDirectory: false)
    }
}
