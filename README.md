[![swift-version](https://img.shields.io/badge/swift-5.1-brightgreen)](https://github.com/apple/swift)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![build-status](https://travis-ci.org/backslash-f/simage.svg?branch=master)](https://travis-ci.org/backslash-f/simage)
[![license](https://img.shields.io/badge/license-mit-brightgreen.svg)](https://en.wikipedia.org/wiki/MIT_License)

# SImage
A wrapper around [`Core Graphics (CG)`](https://developer.apple.com/documentation/coregraphics) that provides functionalities such as combining images while adjusting their orientation. See an example below.

Because it relies on CG, it's already multi-platform. It supports iOS (+ iPadOS), macOS, Mac Catalyst, tvOS and watchOS. The results are returned as `CGImage`, which can be easily displayed (for example) in a `NSImage` (AppKit), `UIImage` (UIKit) or `Image` (SwiftUI).

## Usage
### Combine Images
#### Input
Suppose you would like to combine the following images:

<img src="https://i.imgur.com/FhaKe4D.jpg" width="65">  <img src="https://i.imgur.com/3lknfpX.jpg" width="65">  <img src="https://i.imgur.com/BYt1ijq.jpg" width="65">  <img src="https://i.imgur.com/A9HS8ur.jpg" width="65">  <img src="https://i.imgur.com/G79ViDr.jpg" width="65">  <img src="https://i.imgur.com/Ehzp9yE.jpg" width="100">  <img src="https://i.imgur.com/RPPR4SM.jpg" width="100">  <img src="https://i.imgur.com/JuDklw2.jpg" width="100">  <img src="https://i.imgur.com/FctNAtX.jpg" width="100">

(Notice the different orientations. Kudos [to this repo](https://github.com/recurser/exif-orientation-examples).)

#### Code
```swift
let imageURLs = [URL] // Suppose this URL array points to the above images.

SImage().combineImages(source: imageURLs) { cgImage, error in
    if let resultImage = cgImage {
        // Do whatever with the result image.
    }
}
```

#### Output
<img src="https://i.imgur.com/iS1Jhsj.jpg">

(Notice that in this example the orientation is normalized to "`.up`".)

### Optional Settings
To overwrite the default settings, it's possible to pass a custom `SImageSettings` instance as argument to the combine function:
```
SImage.combineImages(source:👉🏻settings:👈🏻completion:)
```

 An example of a default setting would be:
```
targetOrientation: In a rotation operation, defines the desired orientation for the result image.
Default is ".up"
```
⚠️ (Currently only `.up` is supported.)

## Available APIs
API | Description
--- | -----------
`SImage.combineImages(source:settings:completion:)` | Combines the images in the given array of `URL` using given `SImageSettings`. Fixes orientation. Returns: `CGImage`. 
`SImage.combine(images:settings:completion:)` | Combines given images using given `SImageSettings`. **Does not** fix orientation. Returns: `CGImage`.
`SImage.createImage(from:)` | Creates a `CGImage` from given `URL`. Returns: `CGImage`.
`SImage.context(for:settings:)` | Creates `CGContext` using given `CGSize` and `SImageSettings`. Returns: `CGContext`.

## Integration
### Xcode
Use Xcode's [built-in support for SPM](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) (`File / Swift Packages / Add Package Dependency`).

### Package.swift
In your `Package.swift`, add `SImage` as a dependency:
```swift
dependencies: [
  .package(url: "https://github.com/backslash-f/simage", from: "1.0.0")
],
```

Associate the dependency with your target:
```swift
targets: [
  .target(name: "App", dependencies: ["SImage"])
]
```

Run: `swift build`
