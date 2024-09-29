//
//  Strings+Utils.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import SwiftUI

public extension String {

    // FIXME: Use file name from config
    static let stringsFileName = "Strings"

    static func resource(_ typedString: TypedString) -> String {
        let key = TypedStrings.shared[keyPath: typedString]
        return NSLocalizedString(
            key,
            tableName: Self.stringsFileName,
            bundle: .main,
            comment: ""
        )
    }

    static func resource(_ typedString: TypedStringWithArguments, _ arguments: CVarArg...) -> String {
        let key = TypedStringsWithArguments.shared[keyPath: typedString]
        return .localizedStringWithFormat(
            NSLocalizedString(
                key,
                tableName: Self.stringsFileName,
                bundle: .main,
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
