[![swift-version](https://img.shields.io/badge/swift-5.1-brightgreen?logo=swift)](https://github.com/apple/swift)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)
[![build-status](https://github.com/backslash-f/simage/workflows/build/badge.svg?branch=master)](https://github.com/backslash-f/simage/actions)
[![license](https://img.shields.io/badge/license-mit-brightgreen.svg?logo=data:image/svg+xml;utf8;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8IS0tIEdlbmVyYXRvcjogQWRvYmUgSWxsdXN0cmF0b3IgMTkuMC4wLCBTVkcgRXhwb3J0IFBsdWctSW4gLiBTVkcgVmVyc2lvbjogNi4wMCBCdWlsZCAwKSAgLS0+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4PSIwcHgiIHk9IjBweCIgdmlld0JveD0iMCAwIDUxMi4wMDkgNTEyLjAwOSIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgNTEyLjAwOSA1MTIuMDA5OyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgd2lkdGg9IjUxMnB4IiBoZWlnaHQ9IjUxMnB4Ij4KPHBhdGggc3R5bGU9ImZpbGw6IzRDQUY1MDsiIGQ9Ik0yNTUuOTQ0LDE1LjkzQzExNC42MTgsMTUuOTAyLDAuMDI4LDEzMC40NDYsMCwyNzEuNzcyQy0wLjAxOCwzNjQuMDg5LDQ5LjY4OSw0NDkuMjYsMTMwLjA3Nyw0OTQuNjUgIGMyLjQ1NiwxLjQxNSw1LjM4LDEuNzc3LDguMTA3LDEuMDAzYzIuNzA4LTAuNzU2LDUuMDA4LTIuNTUsNi40LTQuOTkybDc4LjkzMy0xMzkuNDk5YzIuODk1LTUuMTI2LDEuMDkxLTExLjYyOC00LjAzMi0xNC41MjggIGMtMzUuOTU0LTIwLjE5NC00OC43My02NS43MTItMjguNTM1LTEwMS42NjZzNjUuNzEyLTQ4LjczLDEwMS42NjYtMjguNTM1czQ4LjczLDY1LjcxMiwyOC41MzUsMTAxLjY2NiAgYy02LjcxMiwxMS45NTEtMTYuNTg1LDIxLjgyMy0yOC41MzUsMjguNTM1Yy01LjEyMywyLjktNi45MjcsOS40MDItNC4wMzIsMTQuNTI4bDc4LjcyLDEzOS40OTljMS4zODgsMi40NSwzLjY4OSw0LjI1Myw2LjQsNS4wMTMgIGMwLjkyOSwwLjI2OSwxLjg5MSwwLjQwNiwyLjg1OSwwLjQwNWMxLjg0LTAuMDAyLDMuNjQ4LTAuNDgsNS4yNDgtMS4zODdjMTIzLjA4Ny02OS40NDQsMTY2LjU3My0yMjUuNTIyLDk3LjEyOS0zNDguNjEgIEM0MzMuNTQ4LDY1LjYyOSwzNDguMzE5LDE1Ljg4NCwyNTUuOTQ0LDE1LjkzeiIvPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8L3N2Zz4K)](https://en.wikipedia.org/wiki/MIT_License)

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

### Create Thumbnails
```swift
let imageURL = URL(string: "My huge image URL")

simage.createThumbnail(from: imageURL) { cgImage in
    if let thumbnail = cgImage {
        // Do whatever with the thumbnail.
    }
}
```

To create thumbnails with [a max pixel size](https://developer.apple.com/documentation/imageio/kcgimagesourcethumbnailmaxpixelsize)

```swift
let imageURL = URL(string: "My huge image URL")
let settings = SImageSettings(thumbsMaxPixelSize: "50")

simage.createThumbnail(from: imageURL, settings: settings) { cgImage in
    if let thumbnail = cgImage {
        // Do whatever with the thumbnail.
    }
}
```

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
`SImage.combineImages(source:settings:completion:)` | Combines the images in the given array of `URL` using given `SImageSettings`. **Fixes orientation**. Returns: `CGImage`. 
`SImage.combine(images:settings:completion:)` | Combines given images using given `SImageSettings`. **Does not** fix orientation. Returns: `CGImage`.
`SImage.createImage(from:)` | Creates a `CGImage` from given `URL`. Returns: `CGImage`.
`SImage.context(for:settings:)` | Creates `CGContext` using given `CGSize` and `SImageSettings`. Returns: `CGContext`.
`SImage.createThumbnail(from:settings:completion:)` | Creates a thumbnail from the image at the given `URL`. Returns: `CGImage`.

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
