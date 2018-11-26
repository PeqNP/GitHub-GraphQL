//
//  GraphQLCommandAndControl.swift
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import BrightFutures
import Foundation

enum GraphQLServiceError: Error {
    case failedToQueryGraphs
}

protocol GraphQLService {
    func graphs(from: Int, limit: Int) -> Future<[GraphQL], GraphQLServiceError>
}

import Alamofire
import ApolloAlamofire

class DummyGraphQLService: GraphQLService {
    
    func graphs(from: Int, limit: Int) -> Future<[GraphQL], GraphQLServiceError> {
        
        let graphs: [GraphQL] = [
            GraphQL(
                avatarImageURL: URL(string: "https://www.slrlounge.com/wp-content/uploads/2016/10/pounce-cat-seth-casteel-kitten-holly6.jpg")!,
                repositoryName: "A name",
                authorName: "Author name",
                rating: 4.5
            )
        ]

        return Future(value: graphs)
    }
}

class GraphQLCommandAndControl: GraphQLController {
    
    private let service: GraphQLService = DummyGraphQLService()
    
    private weak var _delegate: GraphQLControllerDelegate?
    
    var delegate: GraphQLControllerDelegate? {
        set {
            _delegate = newValue
        }
        get {
            return _delegate
        }
    }
    
    func loadGraphQL() {
        service.graphs(from: 0, limit: 10).onSuccess { [weak _delegate] (graphs: [GraphQL]) in
            _delegate?.didLoadGraphQL(graphs: graphs)
        }
    }
}
