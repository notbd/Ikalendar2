//
//  StringExtensionTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI
import Testing
@testable import IkalendarKit

// MARK: - StringExtensionTests

@Suite("String Extensions")
struct StringExtensionTests {
  // MARK: - LocalizedStringKey Tests

  @Suite("LocalizedStringKey Property")
  struct LocalizedStringKeyTests {
    @Test("LocalizedStringKey property returns correct type")
    func localizedStringKeyPropertyReturnsCorrectType() {
      let testString = "test_key"
      let result = testString.localizedStringKey

      // Verify it's a LocalizedStringKey by creating Text with it (behavioral test)
      _ = Text(result)

      #expect(type(of: result) == LocalizedStringKey.self, "Result should be LocalizedStringKey type")
    }

    @Test("LocalizedStringKey works with empty string")
    func localizedStringKeyWorksWithEmptyString() {
      let emptyString = ""
      let result = emptyString.localizedStringKey

      // Test that we can create Text with empty LocalizedStringKey
      _ = Text(result)

      #expect(type(of: result) == LocalizedStringKey.self, "Should handle empty strings gracefully")
    }

    @Test("LocalizedStringKey works with special characters")
    func localizedStringKeyWorksWithSpecialCharacters() {
      let specialString = "test_key_with_特殊文字_and_émojis_🎮"
      let result = specialString.localizedStringKey

      // Test that we can create Text with special character LocalizedStringKey
      _ = Text(result)

      #expect(type(of: result) == LocalizedStringKey.self, "Should handle special characters and emojis")
    }
  }

  // MARK: - Shortened URL Tests

  @Suite("Shortened URL")
  struct ShortenedURLTests {
    @Test("Shortened URL without base URL returns host and path")
    func shortenedURLWithoutBaseURLReturnsHostAndPath() throws {
      let urlString = "https://www.example.com/page/1/"
      let result = try #require(urlString.shortenedURL(), "Should be able to shorten valid URL")

      #expect(result == "www.example.com/page/1", "Should return host + path without trailing slash")
    }

    @Test("Shortened URL with base URL removes base correctly")
    func shortenedURLWithBaseURLRemovesBaseCorrectly() throws {
      let urlString = "https://www.example.com/page/1/"
      let baseURL = "https://www.example.com/"
      let result = try #require(urlString.shortenedURL(base: baseURL), "Should be able to shorten URL with base")

      #expect(result == "page/1", "Should remove base URL and trailing slash")
    }

    @Test("Shortened URL with base URL and prefix adds prefix correctly")
    func shortenedURLWithBaseURLAndPrefixAddsPrefixCorrectly() throws {
      let urlString = "https://www.example.com/page/1/"
      let baseURL = "https://www.example.com/"
      let prefix = "Page:"
      let result = try #require(
        urlString.shortenedURL(base: baseURL, newPrefix: prefix),
        "Should be able to shorten URL with base and prefix")

      #expect(result == "Page:page/1", "Should remove base URL and add prefix")
    }

    @Test("Shortened URL with invalid URL returns nil")
    func shortenedURLWithInvalidURLReturnsNil() {
      let invalidURL = "not-a-valid-url"
      let result = invalidURL.shortenedURL()

      #expect(result == nil, "Should return nil for invalid URLs")
    }

    @Test("Shortened URL with invalid base URL returns nil")
    func shortenedURLWithInvalidBaseURLReturnsNil() {
      let urlString = "https://www.example.com/page/1/"
      let invalidBaseURL = "not-a-valid-base-url"
      let result = urlString.shortenedURL(base: invalidBaseURL)

      #expect(result == nil, "Should return nil for invalid base URLs")
    }

    @Test("Shortened URL when URL doesn't start with base returns nil")
    func shortenedURLWhenURLDoesntStartWithBaseReturnsNil() {
      let urlString = "https://www.example.com/page/1/"
      let differentBaseURL = "https://www.different.com/"
      let result = urlString.shortenedURL(base: differentBaseURL)

      #expect(result == nil, "Should return nil when URL doesn't start with base")
    }

    @Test("Shortened URL handles URLs without trailing slash")
    func shortenedURLHandlesURLsWithoutTrailingSlash() throws {
      let urlString = "https://www.example.com/page/1"
      let result = try #require(urlString.shortenedURL(), "Should handle URLs without trailing slash")

      #expect(result == "www.example.com/page/1", "Should handle URLs without trailing slash")
    }

    @Test("Shortened URL handles base URLs without trailing slash")
    func shortenedURLHandlesBaseURLsWithoutTrailingSlash() throws {
      let urlString = "https://www.example.com/page/1/"
      let baseURL = "https://www.example.com"
      let result = try #require(urlString.shortenedURL(base: baseURL), "Should handle base URLs without trailing slash")

      #expect(result == "page/1", "Should remove leading slash from result")
    }

    @Test("Shortened URL handles empty path")
    func shortenedURLHandlesEmptyPath() throws {
      let urlString = "https://www.example.com/"
      let result = try #require(urlString.shortenedURL(), "Should handle URLs with empty path")

      #expect(result == "www.example.com", "Should handle URLs with empty path")
    }

    @Test("Shortened URL handles empty path with base URL")
    func shortenedURLHandlesEmptyPathWithBaseURL() throws {
      let urlString = "https://www.example.com/"
      let baseURL = "https://www.example.com/"
      let result = try #require(urlString.shortenedURL(base: baseURL), "Should handle empty path with base URL")

      #expect(result == "", "Should return empty string when base URL matches entire URL")
    }

    @Test("Shortened URL with empty prefix works correctly")
    func shortenedURLWithEmptyPrefixWorksCorrectly() throws {
      let urlString = "https://www.example.com/page/1/"
      let baseURL = "https://www.example.com/"
      let emptyPrefix = ""
      let result = try #require(
        urlString.shortenedURL(base: baseURL, newPrefix: emptyPrefix),
        "Should work with empty prefix")

      #expect(result == "page/1", "Should work correctly with empty prefix")
    }

    @Test("Shortened URL with nil prefix works correctly")
    func shortenedURLWithNilPrefixWorksCorrectly() throws {
      let urlString = "https://www.example.com/page/1/"
      let baseURL = "https://www.example.com/"
      let result = try #require(urlString.shortenedURL(base: baseURL, newPrefix: nil), "Should work with nil prefix")

      #expect(result == "page/1", "Should work correctly with nil prefix")
    }

    @Test("Shortened URL handles complex paths correctly")
    func shortenedURLHandlesComplexPathsCorrectly() throws {
      let urlString = "https://api.example.com/v1/users/123/posts/456/"
      let baseURL = "https://api.example.com/v1/"
      let prefix = "API:"
      let result = try #require(urlString.shortenedURL(base: baseURL, newPrefix: prefix), "Should handle complex paths")

      #expect(result == "API:users/123/posts/456", "Should handle complex paths correctly")
    }

    @Test("Shortened URL handles URLs with query parameters")
    func shortenedURLHandlesURLsWithQueryParameters() throws {
      let urlString = "https://www.example.com/search?q=test&lang=en"
      let result = try #require(urlString.shortenedURL(), "Should handle URLs with query parameters")

      // Note: query parameters are typically not included in path
      #expect(result == "www.example.com/search", "Should handle URLs with query parameters")
    }

    @Test("Shortened URL handles URLs with fragments")
    func shortenedURLHandlesURLsWithFragments() throws {
      let urlString = "https://www.example.com/page#section1"
      let result = try #require(urlString.shortenedURL(), "Should handle URLs with fragments")

      #expect(result == "www.example.com/page", "Should handle URLs with fragments")
    }
  }
}
