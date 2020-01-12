//
//  Logger.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/6/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

struct Logger {
    
    /// Log Network request Data to console.
    ///
    /// - Parameters:
    ///   - request: URL Request used to log Request data.
    ///   - requestBody: Used to Log API Request body
    ///   - response: Used to log Response Status code and description
    ///   - responseString: Log response Json/xml
    ///   - error: To Log Error Value if any.
    /// - Returns: Returns Completed Log String to Requested method.
    private static func createNetworkLogString(_ request: URLRequest? = nil, requestBody: Any? = nil, and response: HTTPURLResponse? = nil, responseString: String? = "", error: Error? = nil) -> String {
        
        var requestStr = ""
        if let request = request {
            requestStr = """
            ========== Request Started With Url \(request.url?.description ?? "Empty") \n
            ########  Request Payload \n
            Method:                \(String(describing: request.httpMethod ?? "Empty") )
            Route:                 \(request.url?.description ?? "Empty")
            Body:                  \(requestBody ?? String(describing: request.httpBody))
            TimeOut:               \(request.timeoutInterval.description)
            Headers:               \(request.allHTTPHeaderFields?.description ?? "Empty")
            """
        }
        
        var responseStr = ""
        if let response = response {
            responseStr = """
            ########  Response \n
            Response:              \(responseString ?? "")
            StatusCode:             \(response.statusCode.description) \n
            ========== Request Ended With Url \(request?.url?.description ?? "Empty")
            """
        }
        
        var errorStr = ""
        if let error = error {
            errorStr = """
            ########  Error \n
            error:                        \(error)
            errorDescription:             \(error.localizedDescription) \n
            ========== Request Ended With Url \(request?.url?.description ?? "Empty")
            """
        }
        
        return requestStr + responseStr + errorStr
    }
    
    /// Log API Request when requested
    ///
    /// - Parameter request: Used URL Request to log body, URL and other Request details.
    static func log(request: URLRequest) {
        
        var requestBody: Any?
        
        if let body = request.httpBody, let json = try? JSONSerialization.jsonObject(with: body, options: []) {
            
            requestBody = json
        }
        
        if let body = request.httpBody, let xml = String(data: body, encoding: String.Encoding.utf8) {
            
            requestBody = xml
        }
        
        let logStr = createNetworkLogString(request, requestBody: requestBody)
        print(logStr)
        
    }
    
    /// Log API Request when response received.
    ///
    /// - Parameters:
    ///   - response: Use Response for Loggin the API response received from server.
    ///   - error: Use to Log Error if received any.
    ///   - data: Use for logging response data and convert to XML/JSON for logging.
    static func log(response: URLResponse?, error: Error?, data: Data?) {
        
        var responseString: String = ""
        
        if let body = data, let json = try? JSONSerialization.jsonObject(with: body, options: []), let jsonStr = json as? String {
            
            responseString = jsonStr
        }
        
        if let body = data, let xml = String(data: body, encoding: String.Encoding.utf8) {
            
            responseString = xml
        }
        
        let logStr = createNetworkLogString(and: response as? HTTPURLResponse, responseString: responseString, error: error)
        
        print(logStr)
        
    }
}
