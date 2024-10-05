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
        let imageName = TypedImages.shared[keyPath: typedImage]

        guard let image = UIImage(named: imageName, in: .main, with: nil) else {
            fatalError("Can't find image in assets")
        }

        return image
    }
}

public extension Image {

    init(_ typedImage: TypedImage) {
        let imageName = TypedImages.shared[keyPath: typedImage]
        self.init(imageName, bundle: .main)
    }
}

public extension URL {

    static func resource(_ typedImage: TypedImage) -> URL {
        let imageName = TypedImages.shared[keyPath: typedImage]
        if let url = Bundle.main.url(forResource: imageName, withExtension: nil) {
            return url
        } else {
            return Bundle.main.bundleURL
        }
    }
}
