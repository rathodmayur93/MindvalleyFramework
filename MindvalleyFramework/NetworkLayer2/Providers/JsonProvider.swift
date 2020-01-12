//
//  JsonProvider.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// JsonProvider for Json request, Used when Provider associatedType confirms Codable.
public protocol JsonProvider : Provider where Response: Codable {
    
}
