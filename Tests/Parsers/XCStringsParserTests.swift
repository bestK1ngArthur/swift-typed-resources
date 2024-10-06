//
//  XCStringsParserTests.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 08.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

@testable import SwiftTypedResourcesParsers

import SwiftTypedResourcesModels
import Testing

@Suite("`.xcstrings` Parser Tests")
struct XCStringsParserTests {

    @Test
    func parseDefault() throws {
        let parser = XCStringsParser()
        let data = """
        {
            "sourceLanguage" : "en",
            "strings" : {
                "testKey" : {
                    "extractionState" : "manual",
                    "localizations" : {
                        "en" : {
                            "stringUnit" : {
                                "state" : "translated",
                                "value" : "Test \nString"
                            }
                        }
                    }
                }
            }
        }
        """.data(using: .utf8)!
        let expected = LocalizableStrings(
            sourceLanguage: .init(rawValue: "en"),
            strings: ["testKey": .init(
                extractionState: .manual,
                localizations: [.init(rawValue: "en"): .default(
                    .string(
                        .init(
                            state: .translated,
                            value: "Test \nString"
                        )
                    )
                )]
            )]
        )
        let real = try parser.parse(data)
        #expect(expected == real)
    }

    @Test
    func parseVariatedByPlural() throws {
        let parser = XCStringsParser()
        let data = """
        {
            "sourceLanguage" : "en",
            "strings" : {
                "testKey" : {
                    "extractionState" : "migrated",
                    "localizations" : {
                        "en" : {
                            "variations" : {
                                "plural" : {
                                    "few" : {
                                        "stringUnit" : {
                                            "state" : "needs_review",
                                            "value" : "Few %d"
                                        }
                                    },
                                    "many" : {
                                        "stringUnit" : {
                                            "state" : "new",
                                            "value" : "Many %d"
                                        }
                                    },
                                    "one" : {
                                        "stringUnit" : {
                                            "state" : "translated",
                                            "value" : "One %d"
                                        }
                                      },
                                    "other" : {
                                        "stringUnit" : {
                                            "state" : "translated",
                                            "value" : "Other %d"
                                        }
                                      },
                                    "zero" : {
                                        "stringUnit" : {
                                            "state" : "translated",
                                            "value" : "Zero %d"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        """.data(using: .utf8)!
        let expected = LocalizableStrings(
            sourceLanguage: .init(rawValue: "en"),
            strings: ["testKey": .init(
                extractionState: .migrated,
                localizations: [.init(rawValue: "en"): .variated(
                    .byPlural([
                        .few: .string(.init(state: .needsReview, value: "Few %d")),
                        .many: .string(.init(state: .new, value: "Many %d")),
                        .one: .string(.init(state: .translated, value: "One %d")),
                        .other: .string(.init(state: .translated, value: "Other %d")),
                        .zero: .string(.init(state: .translated, value: "Zero %d"))
                    ])
                )]
            )]
        )
        let real = try parser.parse(data)
        #expect(expected == real)
    }
}
