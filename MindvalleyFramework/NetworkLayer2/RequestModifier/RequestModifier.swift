//
//  RequestModifier.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

public protocol RequestModifier {
    func modify(endpoint: APIRequestConvertible, headers: RequestHeader) throws -> APIRequestConvertible
}
