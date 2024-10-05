//
//  Images+Utils.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import SwiftUI
import UIKit

public extension UIImage {

    static func resource(_ typedImage: TypedImage) -> UIImage {
        let imageConfig = TypedImages.shared[keyPath: typedImage]
        guard let image = UIImage(named: imageConfig.name, in: imageConfig.bundle, with: nil) else {
            fatalError("Can't find image \"(\(imageConfig.name))\" in assets")
        }

        return image
    }
}

public extension Image {

    init(_ typedImage: TypedImage) {
        let imageConfig = TypedImages.shared[keyPath: typedImage]
        self.init(imageConfig.name, bundle: imageConfig.bundle)
    }
}

public extension URL {

    static func resource(_ typedImage: TypedImage) -> URL {
        let imageConfig = TypedImages.shared[keyPath: typedImage]
        guard let url = imageConfig.bundle.url(forResource: imageConfig.name, withExtension: nil) else {
            return Bundle.main.bundleURL
        }

        return url
    }
}
