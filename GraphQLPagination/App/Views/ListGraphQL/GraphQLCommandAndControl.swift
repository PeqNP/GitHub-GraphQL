//
//  GraphQLCommandAndControl.swift
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import Foundation

class GraphQLCommandAndControl: GraphQLController {
    
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
        _delegate?.didLoadGraphQL(graphs: [
            GraphQL(
                avatarImageURL: URL(string: "https://www.slrlounge.com/wp-content/uploads/2016/10/pounce-cat-seth-casteel-kitten-holly6.jpg")!,
                repositoryName: "A name",
                authorName: "Author name",
                rating: 4.5
            )
        ])
    }
}
