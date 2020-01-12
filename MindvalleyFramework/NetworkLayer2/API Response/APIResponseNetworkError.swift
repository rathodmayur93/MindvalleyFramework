//
//  APIResponseNetworkError.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/3/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Network Error Enum, Which is returned as Failture in Result enum if Network call fails.
///
/// - internetOffline: Return if internet is offline.
/// - requestCreation: If there is some issue with URL, or network request object.
/// - decoding: Issue while decoding data reterived from server.
/// - server: Call failed due to server error.
/// - error: Call successfully ended but received error.
/// - unknown: Unknown error - No description received from network call.
public enum APIResponseNetworkError: Error {
    case internetOffline
    case requestCreation
    case decoding(Data, Error)
    case server(Error)
    case unknown
    
    /// Error message.
    var message: String {
        switch self {
        case .internetOffline:
            return "The Internet connection appears to be offline."
        case .requestCreation:
            return "Request could not be created."
        case .decoding(_, let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .server(let error):
            return error.localizedDescription
        case .unknown:
            return "Unknown, known error."
        }
    }
    
    /// Error code based on error
    var errorCode: Int {
        switch self {
        case .internetOffline:
            return -1009
        default:
            return 500
        }
    }
}
