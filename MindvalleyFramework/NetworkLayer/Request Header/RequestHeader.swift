//
//  RequestHeader.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Protocol for Netowrk Request header values for generic Request Modifier.
public protocol RequestHeader {
    var accept: String { get }
    var contentType: String { get }
}
