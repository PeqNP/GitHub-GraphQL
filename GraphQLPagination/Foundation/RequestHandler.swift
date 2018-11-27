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
    func request<T: Decodable>(urlRequest: URLRequest, _ type: T.Type) -> Future<T, NetworkError>
}
