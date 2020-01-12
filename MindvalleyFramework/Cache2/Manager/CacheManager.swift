//
//  CacheManager.swift
//  MindValleyCache
//
//  Created by ds-mayur on 1/5/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

public class CacheManager {
    
    public static let shared = CacheManager(configuration: CacheConfigurationImpl.default())
    fileprivate let queue = DispatchQueue(label: "SynchronizedDictionary", attributes: .concurrent)
    
    public var configuration: CacheConfiguration
    private var cached: [String: CacheElement] = [:]
    private var timer: Timer?
    
    /// Returns boolean value depends on data stored in cache - either full based on Configuration assgined for Cache.
    public var isCacheStoreFull: Bool {
        var isFull: Bool = false
        queue.sync {
            isFull = cached.count >= configuration.maxStoreSize
        }
        return isFull
    }
    
    /// Return Int value represents current cache size.
    public var storeOccupiedSpace: Int {
        var spaceOccupied: Int = 0
        queue.sync {
            spaceOccupied = cached.count
        }
        return spaceOccupied
    }
    
    /// Initializer for creating CacheManager
    ///
    /// - Parameter configuration: Contains configuration required for setting up Cache size and removal of element policy from cache.
    private init(configuration: CacheConfiguration) {
        
        self.configuration = configuration
        setupAutomaticCacheClear()
    }
    
    /// This is a private method responsible for cleaning up cache based on timer, The Cache configuration decides weather to clear cache automatically after duration or not.
    private func setupAutomaticCacheClear() {
        if configuration.cleanupConfiguration.cleanUpPeriod != 0 {
            timer = Timer.scheduledTimer(withTimeInterval: configuration.cleanupConfiguration.cleanUpPeriod, repeats: true) {[weak self] (_) in
                
                guard let self = self else { return }
                self.removeCacheItems()
            }
        }
    }
    
    /// After creating Cache Manager instance `Cache Configuration` can be updated From this method.
    ///
    /// - Parameter configuration: Updated `Cache configuration`.
    public func updateCacheManager(_ configuration: CacheConfiguration) {
        self.configuration = configuration
        timer?.invalidate()
        setupAutomaticCacheClear()
    }
    
    /// Set item in Cache.
    /// If Cache is full before storing item in it, Apply removal of item policy first - Based on Cache Cleanup configuration provided.
    ///
    /// - Parameters:
    ///   - key: Key against which data will be stored
    ///   - item: The item needed to be cached.
    public func set(key: String, item: Data) {
        var cachedItem = cached[key]
        
        if cachedItem == nil, isCacheStoreFull {
            removeCacheItems()
        }
        
        queue.sync {
            cachedItem = CacheElementImpl(key: key, item: item)
            cached[key] = cachedItem
        }
    }
    
    /// Returns Data stored against url.
    ///
    /// - Parameter url: It's the Key against which data is cached.
    /// - Returns: Cached Data If exist.
    public func getItem(url: String) -> Data? {
        
        var data: Data?
        queue.sync {
            data = cached[url]?.getItem()
        }
        return data
    }
    
    /// It removes item from cache If cache is full.
    /// Removal of item is based on policy described in Cleanup Cache Configuration.
    public func removeCacheItems() {
        queue.sync {
            if isCacheStoreFull {
                switch configuration.cleanupConfiguration.cleanupType {
                case .all:
                    clearAllCacheElements()
                case .allCacheElementLastUsed(let before):
                    clearCacheElement(usedBefore: before)
                case .allCacheElementUsedLess(thanCount: let count):
                    clearCacheElement(usedLessThan: count)
                case .leastRecentlyElement:
                    removeLeastRecentlyElement()
                case .leastUsedCacheElement:
                    removeLeastUsedElement()
                }
            }
        }
    }
    
    /// It clears all data Cached, If Cache is full.
    private func clearAllCacheElements() {
        
        cached.removeAll()
    }
    
    /// It removes all cached value stored before TimeInterval
    ///
    /// - Parameter timeInterval: TimeInterval before which all cached object must be removed.
    private func clearCacheElement(usedBefore timeInterval: TimeInterval) {
        
        let seedDate = Date().addingTimeInterval(-1 * timeInterval)
        
        for itemKey in cached.keys {
            if let cacheditem = cached[itemKey] ,
                cacheditem.lastAccessTimeStamp < seedDate {
                
                cached.removeValue(forKey: itemKey)
            }
        }
    }
    
    /// It removes all cahced values which are used less than `provided Count` times.
    ///
    /// - Parameter count: Removes Cache used less than provided count.
    private func clearCacheElement(usedLessThan count: Int) {
        
        for itemKey in cached.keys {
            if let cacheditem = cached[itemKey],
                cacheditem.totalRequestCount < count {
                
                cached.removeValue(forKey: itemKey)
            }
        }
    }
    
    /// It removes most least used element from cache.
    private func removeLeastUsedElement() {
        
        var leastElementKey: String?
        var frequencyTime = Int.max
        for itemKey in cached.keys {
            if let cacheditem = cached[itemKey] ,
                cacheditem.totalRequestCount < frequencyTime {
                
                leastElementKey = itemKey
                frequencyTime = cacheditem.totalRequestCount
            }
        }
        if let leastElementKey = leastElementKey {
            cached.removeValue(forKey: leastElementKey)
        }
    }
    
    /// It removes least recently used element from cache.
    private func removeLeastRecentlyElement() {
        
        var leastRequestedKey: String?
        var smallestTime: Date?
        for itemKey in cached.keys {
            if let cacheditem = cached[itemKey] {
                
                if let leastRequestedTime = smallestTime {
                    if cacheditem.lastAccessTimeStamp < leastRequestedTime {
                        leastRequestedKey = itemKey
                        smallestTime = cacheditem.lastAccessTimeStamp
                    }
                } else {
                    smallestTime = cacheditem.lastAccessTimeStamp
                }
            }
        }
        
        if let leastRequestedKey = leastRequestedKey {
            cached.removeValue(forKey: leastRequestedKey)
        }
    }
}
