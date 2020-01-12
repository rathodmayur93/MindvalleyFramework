//
//  CacheElement.swift
//  MindValleyCache
//
//  Created by ds-mayur on 1/5/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// CacheElement is a structure contain data to be cached.
protocol CacheElement {
    
    var totalRequestCount: Int {get}
    var lastAccessTimeStamp: Date {get}
    mutating func getItem() -> Data
}

struct CacheElementImpl: CacheElement {
    
    /// Key against which data is stored.
    private let key: String
    /// Item which is cached.
    private let item: Data
    /// Date when it was stored/updated.
    private let createdTimeStamp: Date
    /// It stored when was last time data was reterived, used for cache clear purpose
    private(set) var lastAccessTimeStamp: Date
    /// Total number of times cache item was requested.
    private(set) var totalRequestCount: Int = 0
    
    init(key: String, item: Data) {
        self.key = key
        self.item = item
        self.lastAccessTimeStamp = Date()
        self.createdTimeStamp = Date()
    }
    
    /// It returns the cache item stored and update `Last access timestamp` and `Total request count`
    ///
    /// - Returns: Data cached.
    mutating func getItem() -> Data {
        totalRequestCount += 1
        self.lastAccessTimeStamp = Date()
        return item
    }
    
}
