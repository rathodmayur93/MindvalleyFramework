//
//  APIResponseResult.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/3/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//
import Foundation
//import XMLMapper

/// Enum returned as result for API Network call Response in completionHandler
///
/// - success: Return generic type value If Success.
/// - failure: Return APIResponseNetworkError If Failture.
public enum APIResponseResult<V> {
    case success(V)
    case failure(APIResponseNetworkError)
}
