import ImageIO

/// Dictionary that stores `CGImageProperty`s and can be used in conjunction with `CGImagePropertyKey`.
/// For example: `[CGImagePropertyKey.width: 200]`.
public typealias CGImageProperty = [AnyHashable: Any]

/// Wrapper around [`CGImageProperties` keys](https://developer.apple.com/documentation/imageio/cgimageproperties).
public struct CGImagePropertyKey {
    
    static let height = kCGImagePropertyPixelHeight
    static let width = kCGImagePropertyPixelWidth
    
    // https://developer.apple.com/documentation/imageio/cgimageproperties/individual_image_properties
    static let orientation = kCGImagePropertyOrientation
    
    // https://developer.apple.com/documentation/imageio/cgimageproperties/format-specific_dictionaries
    // https://developer.apple.com/documentation/imageio/cgimageproperties/tiff_dictionary_keys
    // https://developer.apple.com/documentation/imageio/cgimageproperties/iptc_dictionary_keys
    static let TIFFProperties = kCGImagePropertyTIFFDictionary
    static let IPTCProperties = kCGImagePropertyIPTCDictionary
}

public extension CGImageProperty {
    
    /// Returns the value for `kCGImagePropertyPixelWidth` key.
    func width() -> CGFloat? {
        return propertyByKey(key: CGImagePropertyKey.width) as? CGFloat
    }
    
    /// Returns the value for `kCGImagePropertyPixelHeight` key.
    func height() -> CGFloat? {
        return propertyByKey(key: CGImagePropertyKey.height) as? CGFloat
    }
    
    /// Returns a `CGSize` based on the `kCGImagePropertyPixelWidth` and `kCGImagePropertyPixelHeight` keys.
    func size() -> CGSize? {
        if let width = width(),
            let height = height() {
            return CGSize(width: width, height: height)
        }
        return nil
    }
    
    /// Returns the value for the `kCGImagePropertyOrientation` key.
    ///
    /// It first tries to get the orientation information from the "root" of the properties dictionary. In case it is
    /// missing, the function tries to extract the orientation information from `TIFF` properties. In case that is also
    /// missing, the function tries to extract the orientation information from `IPTC` properties. In case that is
    /// missing too, then the function returns `nil`.
    func orientation() -> CGImagePropertyOrientation? {
        if let orientationRawValue = propertyByKey(key: CGImagePropertyKey.orientation) as? UInt32 {
            return CGImagePropertyOrientation(rawValue: orientationRawValue)
        }
        if let TIFFProperties = getTIFFProperties(),
            let orientationRawValue = TIFFProperties[CGImagePropertyKey.orientation] as? UInt32 {
            return CGImagePropertyOrientation(rawValue: orientationRawValue)
        }
        if let IPTCPProperties = getIPTCProperties(),
            let orientationRawValue = IPTCPProperties[CGImagePropertyKey.orientation] as? UInt32 {
            return CGImagePropertyOrientation(rawValue: orientationRawValue)
        }
        return nil
    }
}

public extension CGImageProperty {
    
    /// Returns the properties dictionary for the `kCGImagePropertyTIFFDictionary` key.
    func getTIFFProperties() -> Dictionary? {
        return propertiesByKey(key: CGImagePropertyKey.TIFFProperties)
    }
    
    /// Returns the properties dictionary for the `kCGImagePropertyIPTCDictionary` key.
    func getIPTCProperties() -> Dictionary? {
        return propertiesByKey(key: CGImagePropertyKey.IPTCProperties)
    }
    
    /// Returns the property (`Any`) for the given `CFString` key.
    func propertyByKey(key: CFString) -> Any? {
        if let property = self[key] {
            return property
        }
        return nil
    }
    
    /// Returns a `Dictionary` or properties for the given `CFString` key.
    func propertiesByKey(key: CFString) -> Dictionary? {
        if let properties = self[key] as? Dictionary {
            return properties
        }
        return nil
    }
}
