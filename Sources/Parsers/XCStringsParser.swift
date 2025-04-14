//
//  XCStringsParser.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 08.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation
import SwiftTypedResourcesModels

public struct XCStringsParser {

    public init() {}

    public func parse(
        _ data: Data,
        encoding: String.Encoding = .utf8
    ) throws -> LocalizableStrings {
        let data = try escapeValuesSpecialCharacters(in: data, encoding: encoding)

        guard let raw = try JSONSerialization.jsonObject(with: data) as? Raw else {
            throw ParserError.invalidFormat
        }

        return LocalizableStrings(
            sourceLanguage: try parseSourceLanguage(from: raw),
            strings: try parseStrings(from: raw)
        )
    }

    private func parseSourceLanguage(from raw: Raw) throws -> LanguageCode {
        guard let rawValue = raw["sourceLanguage"] as? String else {
            throw ParserError.missedRequiredField
        }

        return .init(rawValue: rawValue)
    }

    private func parseStrings(from raw: Raw) throws -> [String: LocalizableString] {
        guard let rawStrings = raw["strings"] as? Raw else {
            throw ParserError.missedRequiredField
        }

        return try rawStrings.mapValues { raw in
            guard let raw = raw as? Raw else {
                throw ParserError.invalidFormat
            }

            return try parseString(from: raw)
        }
    }

    private func parseString(from raw: Raw) throws -> LocalizableString {
        guard let rawLocalizations = raw["localizations"] as? Raw else {
            throw ParserError.missedRequiredField
        }

        let rawExtractionState = raw["extractionState"] as? String
        let extractionState = rawExtractionState.flatMap {
            ExtractionState(rawValue: $0) ?? .unsupported
        }

        return .init(
            extractionState: extractionState,
            localizations: try parseLocalizations(from: rawLocalizations)
        )
    }

    private func parseLocalizations(from raw: Raw) throws -> [LanguageCode: Localization] {
        var localizations: [LanguageCode: Localization] = [:]
        for rawLanguageCode in raw.keys {
            guard let rawLocalization = raw[rawLanguageCode] as? Raw else {
                throw ParserError.missedRequiredField
            }

            let languageCode = LanguageCode(rawValue: rawLanguageCode)
            let localization = try parseLocalization(from: rawLocalization)

            localizations[languageCode] = localization
        }

        return localizations
    }

    private func parseLocalization(from raw: Raw) throws -> Localization {
        if let rawVariations = raw["variations"] as? Raw {
            let variations = try parseVariations(from: rawVariations)
            return .variated(variations)
        } else {
            let unit = try parseUnit(from: raw)
            return .default(unit)
        }
    }

    private func parseVariations(from raw: Raw) throws -> Variations {
        if let rawPlural = raw["plural"] as? Raw {
            var variations: [Plural: Unit] = [:]
            for rawPluralValue in rawPlural.keys {
                guard let rawUnit = rawPlural[rawPluralValue] as? Raw else {
                    throw ParserError.missedRequiredField
                }

                guard let plural = Plural(rawValue: rawPluralValue) else {
                    throw ParserError.invalidFormat
                }

                let unit = try parseUnit(from: rawUnit)
                variations[plural] = unit
            }
            return .byPlural(variations)
        } else if let rawDevice = raw["device"] as? Raw {
            var variations: [Device: Unit] = [:]
            for rawDeviceValue in rawDevice.keys {
                guard let rawUnit = rawDevice[rawDeviceValue] as? Raw else {
                    throw ParserError.missedRequiredField
                }

                guard let device = Device(rawValue: rawDeviceValue) else {
                    throw ParserError.invalidFormat
                }

                let unit = try parseUnit(from: rawUnit)
                variations[device] = unit
            }
            return .byDevice(variations)
        } else {
            throw ParserError.unsupportedVariationType
        }
    }

    private func parseUnit(from raw: Raw) throws -> Unit {
        if let rawStringUnit = raw["stringUnit"] as? Raw {
            let stringUnit = try parseStringUnit(from: rawStringUnit)
            return .string(stringUnit)
        } else {
            throw ParserError.unsupportedLocalizationUnit
        }
    }

    private func parseStringUnit(from raw: Raw) throws -> StringUnit {
        guard
            let rawState = raw["state"] as? String,
            let value = raw["value"] as? String
        else {
            throw ParserError.missedRequiredField
        }

        let state = StringUnit.State(rawValue: rawState) ?? .unsupported

        return .init(
            state: state,
            value: value
        )
    }

    // MARK: Special symbols

    private enum SpecialSymbol: String, CaseIterable {
        case doubleQuote = "\""
        case newLine = "\n"
        case carriageReturn = "\r"
        case tab = "\t"

        var escaped: String {
            rawValue.unicodeScalars
                .map { $0.escaped(asASCII: false) }
                .joined()
        }
    }

    /// `.xcstrings` use unescaped special symbols (like '\n') in values unlike json. So it's needed to escape manually to parse as json
    private func escapeValuesSpecialCharacters(in data: Data, encoding: String.Encoding) throws -> Data {
        guard let string = String(data: data, encoding: .utf8) else {
            return data
        }

        let valuesPattern = "\"value\"\\s*:\\s*\"([^\"]*)\""
        let valuesRegex = try NSRegularExpression(pattern: valuesPattern, options: [])

        let valuePattern = ": \"([^\"]*)\""
        let valueRegex = try NSRegularExpression(pattern: valuePattern, options: [])

        func escapeSpecialCharacters(in value: String) -> String {
            var escapedValue = value
            let matches = valueRegex.matches(
                in: value,
                options: [],
                range: NSRange(location: 0, length: value.count)
            )

            for match in matches.reversed() where match.numberOfRanges > 1 {
                let matchRange = match.range(at: 1)
                if let range = Range(matchRange, in: value) {
                    var replacement = String(value[range])
                    for specialSymbol in SpecialSymbol.allCases {
                        replacement = replacement.replacingOccurrences(
                            of: specialSymbol.rawValue,
                            with: specialSymbol.escaped
                        )
                    }
                    escapedValue.replaceSubrange(range, with: replacement)
                }
            }

            return escapedValue
        }

        var escapedString = string
        let matches = valuesRegex.matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.count)
        )

        for match in matches.reversed() {
            let matchRange = match.range
            if let range = Range(matchRange, in: string) {
                let foundString = String(string[range])
                let replacement = escapeSpecialCharacters(in: foundString)
                escapedString.replaceSubrange(range, with: replacement)
            }
        }

        guard let escapedData = escapedString.data(using: encoding) else {
            return data
        }

        return escapedData
    }
}

extension XCStringsParser {

    public enum ParserError: Error {
        case invalidFormat
        case missedRequiredField
        case unsupportedVariationType
        case unsupportedLocalizationUnit
    }

    private typealias Raw = [String: Any]
    private typealias LanguageCode = LocalizableStrings.LanguageCode
    private typealias LocalizableString = LocalizableStrings.LocalizableString
    private typealias ExtractionState = LocalizableString.ExtractionState
    private typealias Localization = LocalizableString.Localization
    private typealias Variations = Localization.Variations
    private typealias Plural = Localization.Plural
    private typealias Device = Localization.Device
    private typealias Unit = Localization.Unit
    private typealias StringUnit = Localization.StringUnit
}
