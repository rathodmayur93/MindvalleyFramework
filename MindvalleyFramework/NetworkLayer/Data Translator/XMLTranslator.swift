//
//  XMLTranslator.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// A protocol defines available methods to translate data from XML to Response Type.
public protocol XMLTranslatable {
    func convertDataResponseModel<T>(with response: APIResponseResult<Data>) -> APIResponseResult<T> where T: XMLMappable
}

/// Used to convert data Received from server in XML format to `Generic Response type` provided in request.
/// Provided Response DataType must confirm XMLMapper.
public class XMLTranslator: XMLTranslatable {
    
    public init() {}
    
    /// Convert the Data reterives from server in xml format to XMLMapper Confirmed Response DataType
    ///
    /// - Parameter response: The response Data received from network call.
    /// - Returns: APIResponseResult contains:
    ///   Success If Decoder successfully converts xml data to Response DataType.
    ///   Failture with decoding error, If conversion failed or received error from Network request.
    public func convertDataResponseModel<T>(with response: APIResponseResult<Data>) -> APIResponseResult<T> where T: XMLMappable {
        
        switch response {
        case .success(let data):
            
            let decoder = XMLMapper<T>()
            
            if let xmlString = String(data: data, encoding: String.Encoding.utf8), let dto = decoder.map(XMLString: xmlString)  {
                return .success(dto)
            } else {
                return .failure(.unknown)
            }
        case .failure(let error):
            return .failure(APIResponseNetworkError.server(error))
        }
    }
}
