//
//  StringsResource.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 08.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

public typealias StringsResources = [StringsResource]

public struct StringsResource: Equatable {

    public let table: String
    public let strings: LocalizableStrings

    public init(table: String, strings: LocalizableStrings) {
        self.table = table
        self.strings = strings
    }
}

public struct LocalizableStrings: Equatable {

    public struct LanguageCode: Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public struct LocalizableString: Equatable {
        public let extractionState: ExtractionState
        public let localizations: [LanguageCode: Localization]

        public init(extractionState: ExtractionState, localizations: [LanguageCode: Localization]) {
            self.extractionState = extractionState
            self.localizations = localizations
        }
    }

    public let sourceLanguage: LanguageCode
    public let strings: [String: LocalizableString]

    public init(sourceLanguage: LanguageCode, strings: [String: LocalizableString]) {
        self.sourceLanguage = sourceLanguage
        self.strings = strings
    }
}

extension LocalizableStrings.LocalizableString {

    public enum ExtractionState: String {
        case manual
        case migrated
        case unsupported
    }

    public enum Localization: Equatable {
        case `default`(Unit)
        case variated(Variations)
    }
}

extension LocalizableStrings.LocalizableString.Localization {

    public enum Variations: Equatable {
        case byDevice([Device: Unit])
        case byPlural([Plural: Unit])
    }

    public enum Device: String {
        case appleTV = "appletv"
        case appleVision = "applevision"
        case appleWatch = "applewatch"
        case iPad = "ipad"
        case iPhone = "iphone"
        case iPod = "ipod"
        case mac
        case other
    }

    public enum Plural: String {
        case few
        case many
        case one
        case other
        case two
        case zero
    }

    public enum Unit: Equatable {
        case string(StringUnit)
    }

    public struct StringUnit: Equatable {

        public enum State: String {
            case needsReview = "needs_review"
            case new
            case unsupported
            case translated
        }

        public let state: State
        public let value: String

        public init(state: State, value: String) {
            self.state = state
            self.value = value
        }
    }
}
