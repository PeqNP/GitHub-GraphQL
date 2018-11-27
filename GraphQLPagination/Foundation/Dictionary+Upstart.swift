//
//  Dictionary+Upstart.swift
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    var asData: Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return data
        } catch _ {
            return nil
        }
    }
}
