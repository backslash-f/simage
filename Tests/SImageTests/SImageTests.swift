import XCTest

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

    func testCreateCGImage() {
        let imageURL = randomImageURL()
        do {
            let cgImage = try SImage().createImage(from: imageURL)
            XCTAssert(cgImage.height > 0, "Invalid height.")
            XCTAssert(cgImage.width > 0, "Invalid width.")
        } catch {
            XCTFail("Cannot create an image. Error: \(error)")
        }
    }
}

// MARK: - Private

private extension SImageTests {

    func randomImageURL() -> URL {
        let randomImageNumber = (0..<9).randomElement() ?? 0
        let imageName = "\(imagePrefix)\(randomImageNumber).jpg"
        return resourcesPath.appendingPathComponent(imageName, isDirectory: false)
    }

    func imageSourceURLs() -> [URL] {
        var sourceURLs = [URL]()
        for n in 0..<9 {
            let imageURL = resourcesPath.appendingPathComponent("\(imagePrefix)\(n).jpg", isDirectory: false)
            print(imageURL)
            sourceURLs.append(imageURL)
        }
        return sourceURLs
    }
}
