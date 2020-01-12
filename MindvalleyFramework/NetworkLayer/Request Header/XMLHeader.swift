//
//  XMLHeader.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Provide XML Network Request header values for generic Request Modifier.
final class XMLHeader: RequestHeader {
    let accept: String = "application/xml"
    let contentType: String = "application/xml"
}
