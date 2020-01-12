//
//  APIRequest.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/3/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Struct Containing information regarding API Call.
public struct APIRequest {
    let path: String
    let headers: [String: String?]
    let requestModifiers: [RequestModifier]
    var additionalHeaders: [String: String?]
    
    /// Initializer for creating API Request.
    ///
    /// - Parameters:
    ///   - path: The url for api call (e.g "https://google.com")
    ///   - headers: Used to provide headers required for API call.
    ///   - requestModifiers: Used to provide request information regarding content-type, accept etc.
    ///   - additionalHeaders: Used to set additional headers if any.
    public init(path: String = "", headers: [String: String?] = [:], requestModifiers: [RequestModifier] = [], additionalHeaders: [String: String?] = [:]) {
        self.path = path
        self.headers = headers
        self.requestModifiers = requestModifiers
        self.additionalHeaders = additionalHeaders
    }
}


public extension APIRequest {
    /// Short hand method used to create public API with generic Request Modifiers.
    static var PublicAPI: APIRequest {
        return APIRequest(requestModifiers: [GenericRequestModifier()])
    }
}
