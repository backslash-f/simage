import XCTest

@testable import SImage

final class SImageTests: XCTestCase {

    // MARK: - Public Properties

    static var allTests = [
        ("testExample", testExample),
    ]
}

// MARK: - Tests

extension SImageTests {

    func testExample() {
        let imageURL = imageSourceURLs()
        let image = try! SImage().createImage(from: imageURL.first!)
        print(image)
    }
}

// MARK: - Private

private extension SImageTests {

    func imageSourceURLs() -> [URL] {
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        let resourcesPath = currentFileURL.deletingLastPathComponent().appendingPathComponent("Resources")
        let prefix = "Portrait_"
        var sourceURLs = [URL]()
        for n in 0..<9 {
            let imageURL = resourcesPath.appendingPathComponent("\(prefix)\(n).jpg", isDirectory: false)
            print(imageURL)
            sourceURLs.append(imageURL)
        }
        return sourceURLs
    }
}
