//
//  CacheConfiguration.swift
//  MindValleyCache
//
//  Created by ds-mayur on 1/5/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Used to define Cache Configuration required by cache manager to create cache store.
public protocol CacheConfiguration {
    var maxStoreSize: Int { get set }
    var cleanupConfiguration: CacheCleanupConfiguration {get set}
}

public extension CacheConfiguration {
    /// It provides default implementation for cache Configuration.
    ///
    /// - Returns: Object of CacheConfiguration with default values.
    static func `default`() -> CacheConfiguration {
        return CacheConfigurationImpl()
    }
}

public struct CacheConfigurationImpl: CacheConfiguration {
    /// Contains Cache cleanup Policies.
    public var cleanupConfiguration: CacheCleanupConfiguration = CacheCleanupConfigurationImpl.default()
    /// Contains Cache Store Capacity.
    public var maxStoreSize: Int = CacheConfigurationConstants.defaultStoreSize
}
