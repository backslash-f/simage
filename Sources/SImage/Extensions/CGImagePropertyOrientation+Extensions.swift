import SwiftUI

public extension CGImagePropertyOrientation {

    /// Helper that allows the orientation to be printed. E.g.: `print(orientation.description)`.
    var description: String {
        switch rawValue {
        case 1:
            return "Up (\(rawValue))"
        case 2:
            return "UpMirrored (\(rawValue))"
        case 3:
            return "Down (\(rawValue))"
        case 4:
            return "DownMirrored (\(rawValue))"
        case 5:
            return "LeftMirrored (\(rawValue))"
        case 6:
            return "Right (\(rawValue))"
        case 7:
            return "RightMirrored (\(rawValue))"
        case 8:
            return "Left (\(rawValue))"
        default:
            return "Unknown (\(rawValue))"
        }
    }
}
