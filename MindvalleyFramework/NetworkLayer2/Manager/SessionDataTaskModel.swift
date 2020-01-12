//
//  SessionDataTaskModel.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

public struct SessionDataTaskModel {
    var dataTask: URLSessionDataTask
    var currentRequestCount: Int
    var completionHandlers: [String: completionHandler]
}
