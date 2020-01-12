//
//  GenericRequestModifier.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

final class GenericRequestModifier: RequestModifier {
    
    /// Used to create generic Public Request Modifier.
    ///
    /// - Parameters:
    ///   - endpoint: Used to add headers to endpoint
    ///   - headers: Add headers against Public request modifiers.
    /// - Returns: APIRequestConvertible with added headers value.
    func modify(endpoint: APIRequestConvertible, headers: RequestHeader) -> APIRequestConvertible {
        if var requestConverter = endpoint as? APIRequestConverter {
            ["accept": headers.accept,
             "content-type": headers.contentType].forEach { requestConverter.api.additionalHeaders[$0.key] = $0.value }
            return requestConverter
        }
        return endpoint
    }
}
