//
//  Provider.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Protocol For request Provider used to define to Type of response object.
public protocol Provider {
    
    /// AssociatedType for Response object
    associatedtype Response
    /// Used to define URL Request endpoint for Network manager.
    var endpoint: APIRequestConvertible { get }
}
