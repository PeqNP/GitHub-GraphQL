//
//  JSONRequestHandler.swift
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import Alamofire
import BrightFutures
import Foundation

class JSONRequestHandler: RequestHandler {
    
    func request<T: Decodable>(urlRequest: URLRequest, _ type: T.Type) -> Future<T, NetworkError> {
        let promise = Promise<T, NetworkError>()
        Alamofire.request(urlRequest).responseJSON { (response) in
            guard let data = response.data else {
                print(response.error?.localizedDescription ?? "Error")
                return
            }
            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(T.self, from: data) else {
                promise.failure(.failedToDecode)
                return
            }
            
            promise.success(response)
        }
        
        return promise.future
    }
}
