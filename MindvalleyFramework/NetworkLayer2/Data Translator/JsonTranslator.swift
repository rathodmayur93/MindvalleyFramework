//
//  JsonTranslator.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// A protocol defines available methods to translate data from Json to Response Type.
public protocol JsonTranslatable {
    func convertDataResponseModel<T>(with response: APIResponseResult<Data>) -> APIResponseResult<T> where T: Decodable
}

/// Used to convert data Received from server in JSON format to `Generic Response type` provided in request.
/// Provided Response DataType must confirm Codable.
public class JsonTranslator: JsonTranslatable {
    
    public init() {}
    
    /// Convert the Data reterives from server in json format to Codable Confirmed Response DataType
    ///
    /// - Parameter response: The response Data received from network call.
    /// - Returns: APIResponseResult contains:
    ///   Success If Decoder successfully converts json data to Response DataType.
    ///   Failture with decoding error, If conversion failed or received error from Network request.
    public func convertDataResponseModel<T>(with response: APIResponseResult<Data>) -> APIResponseResult<T> where T: Decodable {
        switch response {
        case .success(let data):
            do {
                return .success(try JSONDecoder().decode(T.self, from: data))
            }
            catch {
                return  .failure(APIResponseNetworkError.decoding(data, error))
            }
            
        case .failure(let error):
            return .failure(APIResponseNetworkError.server(error))
        }
    }
}
