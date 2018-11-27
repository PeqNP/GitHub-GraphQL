//
//  GraphQLCommandAndControl.swift
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import BrightFutures
import Foundation

enum RepositoryListServiceError: Error {
    case failedToQueryRepositories
    case unknown
}

protocol RepositoryService {
    func repositories(from: Int, limit: Int) -> Future<[Repository], RepositoryListServiceError>
}

// The `GitHubGraphQLService` can be extended in the App or Service layer to ensure that it conforms to what the CommandAndControl class requires.
extension GitHubGraphQLService: RepositoryService { }

class RepositoryListCommandAndControl: RepositoryListController {
    
    private let service: RepositoryService = GitHubGraphQLService()
    
    private weak var _delegate: RepositoryListControllerDelegate?
    
    var delegate: RepositoryListControllerDelegate? {
        set {
            _delegate = newValue
        }
        get {
            return _delegate
        }
    }
    
    func loadGraphQL() {
        service.repositories(from: 0, limit: 10).onSuccess { [weak _delegate] (repositories: [Repository]) in
            _delegate?.didLoadRepositories(repositories: repositories)
        }
    }
}
