//
//  XMLProvider.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// XmlProvider for xml request, Used when Provider associatedType confirms XMLMapper.
public protocol XmlProvider : Provider where Response: XMLMappable {
    
}
