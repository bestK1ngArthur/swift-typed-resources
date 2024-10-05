//
//  Strings+Utils.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import SwiftUI

public extension String {

    static func resource(_ typedString: TypedString) -> String {
        let config = TypedStrings.shared[keyPath: typedString]
        return NSLocalizedString(
            config.key,
            tableName: config.table,
            bundle: config.bundle,
            comment: ""
        )
    }

    static func resource(_ typedString: TypedStringWithArguments, _ arguments: CVarArg...) -> String {
        let config = TypedStringsWithArguments.shared[keyPath: typedString]
        return .localizedStringWithFormat(
            NSLocalizedString(
                config.key,
                tableName: config.table,
                bundle: config.bundle,
                comment: ""
            ),
            arguments
        )
    }
}

public extension Text {

    init(_ typedString: TypedString) {
        let value = String.resource(typedString)
        self.init(value)
    }

    init(_ typedString: TypedStringWithArguments, _ arguments: CVarArg...) {
        let value = String.resource(typedString, arguments)
        self.init(value)
    }
}
