//
//  JsonHeader.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Provide JSON Network Request header values for generic Request Modifier.
final class JSONNetworkRepository: RequestHeader {
    let accept: String = "application/json"
    let contentType: String = "application/json"
}
