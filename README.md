[![swift-version](https://img.shields.io/badge/swift-5.1-brightgreen)](https://github.com/apple/swift)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![build-status](https://travis-ci.org/backslash-f/simage.svg?branch=master)](https://travis-ci.org/backslash-f/simage)
[![license](https://img.shields.io/badge/license-mit-brightgreen.svg)](https://en.wikipedia.org/wiki/MIT_License)

# SImage
A wrapper around [`Core Graphics (CG)`](https://developer.apple.com/documentation/coregraphics) that provides functionalities such as combining images while adjusting their orientation. See the example below.

Because it relies on CG, it's already multi-platform. It supports iOS (+ iPadOS), macOS, Mac Catalyst, tvOS and watchOS. The results are returned as `CGImage`, which can be easily displayed (for example) in a `NSImage` (AppKit), `UIImage` (UIKit) or `Image` (SwiftUI).

## Usage
### Combine Images
#### Input
Suppose you would like to combine the following images:

<img src="https://github.com/backslash-f/simage/blob/master/Resources/image_0.jpg" width="65">  <img src="https://github.com/backslash-f/simage/blob/master/Resources/image_1.jpg" width="65">  <img src="https://github.com/backslash-f/simage/blob/master/Resources/image_2.jpg" width="65">  <img src="https://github.com/backslash-f/simage/blob/master/Resources/image_3.jpg" width="65">  <img src="https://github.com/backslash-f/simage/blob/master/Resources/image_4.jpg" width="65">  <img src="https://github.com/backslash-f/simage/blob/master/Resources/image_5.jpg" width="100">  <img src="https://github.com/backslash-f/simage/blob/master/Resources/image_6.jpg" width="100">  <img src="https://github.com/backslash-f/simage/blob/master/Resources/image_7.jpg" width="100">  <img src="https://github.com/backslash-f/simage/blob/master/Resources/image_8.jpg" width="100">

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
<img src="https://github.com/backslash-f/simage/blob/master/Resources/result_image.jpg">

(Notice that in this example the orientation is normalized to "`.up`".)

### Optional Settings
To overwrite the default settings, it's possible to pass a custom `SImageSettings` instance as argument to the combine function:
```
SImage.combineImages(source:settings:completion:)
```

 An example of a default setting would be:
```
targetOrientation: In a rotation operation, defines the desired orientation for the result image.
Default is ".up"
```
⚠️ (Currently only `.up` is supported.)

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
