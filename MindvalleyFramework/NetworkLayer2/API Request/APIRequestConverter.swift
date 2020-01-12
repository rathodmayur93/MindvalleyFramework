//
//  APIRequestConverter.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/3/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Enum with accepted HTTP Methods
///
/// - get: Used to get data from server
/// - post: Used to post data to server
/// - put: Used to put data on server
/// - delete: Used to delete data from server
public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
}


public protocol APIRequestConvertible {
    var name: String? {get}
    var api: APIRequest {get set}
    var numberOfRetry: Int {get}
    var method: HTTPMethod {get}
    var path: String {get}
    var timeout: TimeInterval? {get}
    var body: Data? {get}
    var requestUniqueIdentifier: String {get set}
    func urlRequest() -> URLRequest
    func updateURLRequest(header: RequestHeader) throws -> URLRequest
}

/// A struct used to provide EndPoint information regarding API Call.
public struct APIRequestConverter: APIRequestConvertible {
    /// API Method required
    private(set) public var method: HTTPMethod
    /// API Call URL
    private(set) public var path: String
    /// API Timeout if custom. Default is set to 60.
    private(set) public var timeout: TimeInterval?
    /// API Call Body
    private(set) public var body: Data?
    /// API Call Name - used for Logging and identification purpose.
    private(set) public var name: String?
    /// API Request used to set headers and details for API.
    public var api: APIRequest
    /// To set number of retrys for any call if fails.
    private(set) public var numberOfRetry: Int
    /// Request unique identification for caching URL Request if same call arise.
    public var requestUniqueIdentifier: String
    
    /// Used for initializing API Request Converter object.
    ///
    /// - Parameters:
    ///   - api: Can set custom API Request Value. - Default is set to PublicAPI.
    ///   - method: API HTTP Method, required to process API Request.
    ///   - path: API Call URL.
    ///   - timeout: Optional value, required to set timeout for API Call.
    ///   - body: API Call request Body.
    ///   - name: API Call name.
    ///   - numberOfRetry: Number of retry for any API call, if call fails.
    ///   - requestUniqueIdentifier: Unique identifier, to identify the caller.
    public init(api: APIRequest = .PublicAPI,
                method: HTTPMethod,
                path: String,
                timeout: TimeInterval? = nil,
                body: Data? = nil,
                name: String,
                numberOfRetry: Int = 0,
                requestUniqueIdentifier: String = "") {
        
        self.api = api
        self.method = method
        self.path = path
        self.timeout = timeout
        self.body = body
        self.name = name
        self.numberOfRetry = numberOfRetry
        self.requestUniqueIdentifier = requestUniqueIdentifier
    }
    
    /// Returns URL created from Path provided by the user.
    private var url: URL {
        
        return URL(string: path)!
    }
    
    /// Used to set request Modifiers and headers to API URL.
    ///
    /// - Parameter header: headers set by user for APIRequest.
    /// - Returns: URL Request created from API URL, Request header and request Modifiers.
    /// - Throws: If url request creation fails.
    public func updateURLRequest(header: RequestHeader) throws -> URLRequest {
        let modifiedEndpoint = try api.requestModifiers.reduce(self) { try $1.modify(endpoint: $0, headers: header) }
        return modifiedEndpoint.urlRequest()
    }
    
    /// returns URLRequest based on the provided APIRequest and headers.
    ///
    /// - Returns: URLRequest object created from URL and headers
    public func urlRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        
        if let body = body {
            request.httpBody = body
        }
        
        if let timeout = timeout {
            request.timeoutInterval = timeout
        }
        
        return request
    }
    
}
