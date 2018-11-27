//
//  RequestHandler.swift
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import BrightFutures
import Foundation

enum NetworkError: Error {
    case failedToDecode
}

protocol RequestHandler {
    
    /**
     Make a request to a service and return the respective type.
     
     - parameter: `urlRequest` The URL request to execute
     - parameter: `type` The type to decode/map the payload into
     - returns: a `Future`
     */
    func request<T: Decodable>(urlRequest: URLRequest, _ type: T.Type) -> Future<T, NetworkError>
}
