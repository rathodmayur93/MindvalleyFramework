//
//  CacheCleanupConfiguration.swift
//  MindValleyCache
//
//  Created by ds-mayur on 1/5/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//
import Foundation

/// Required to define Cache Item removal policy.
///
/// - all: Should remove all items from Cache
/// - allCacheElementUsedLess: Should remove all items used less than `Count`
/// - allCacheElementLastUsed: Should remove all item used before `TimeInterval`
/// - leastUsedCacheElement: Should remove single item used least number of times.
/// - leastRecentlyElement: Should remove single item used least recently.

public enum CacheCleanupType: Equatable {
    case all
    case allCacheElementUsedLess (thanCount: Int)
    case allCacheElementLastUsed (before: TimeInterval)
    case leastUsedCacheElement
    case leastRecentlyElement
    
    /// Used to equate 2 CacheCleanupType Values.
    ///
    /// - Parameters:
    ///   - lhs: Comparision Value 1 - LeftHand Side value
    ///   - rhs: Comparision Value 2 - RightHand Side value
    /// - Returns: Should return true if both are same.
    public static func == (lhs: CacheCleanupType, rhs: CacheCleanupType) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all):
            return true
        case (.leastUsedCacheElement, .leastUsedCacheElement):
            return true
        case (.leastRecentlyElement, .leastRecentlyElement):
            return true
        case (.allCacheElementUsedLess(let lhsCount), .allCacheElementUsedLess(let rhsCount)):
            return lhsCount == rhsCount
        case (.allCacheElementLastUsed(let lhsTimeInterval), .allCacheElementLastUsed(let rhsTimeInterval)):
            return lhsTimeInterval == rhsTimeInterval
        default:
            return false
        }
    }
}

public protocol CacheCleanupConfiguration {
    var cleanupType: CacheCleanupType {get set}
    var cleanUpPeriod: TimeInterval {get set}
}

public extension CacheCleanupConfiguration {
    /// It provides default implementation for cache Cleanup Configuration.
    ///
    /// - Returns: Object of CacheCleanup Configuration with default values.
    static func `default`() -> CacheCleanupConfiguration {
        return CacheCleanupConfigurationImpl()
    }
}

public struct CacheCleanupConfigurationImpl: CacheCleanupConfiguration {
    /// Used to define default type for cacheCleanup
    /// Default value is leastRecentlyUsed 
    public var cleanupType: CacheCleanupType = .leastRecentlyElement
    /// Used to define value if cache need to be cleared automatically, else set to 0.
    /// Default value is 0
    public var cleanUpPeriod: TimeInterval = CacheConfigurationConstants.defaultCleanupPeriod
}
