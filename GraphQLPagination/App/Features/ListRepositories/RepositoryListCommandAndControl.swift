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

struct RepositoryQuery {
    let cursor: String?
    let repositories: [Repository]
}

protocol RepositoryService {
    
    /**
     Query a list of repositories from a data source.
     
     Note: The reason the `from`, or "cursor", is `Any?` is because:
     1. The service may use a `String` (as in the case of `search after`) or an `Int` in the case where `offset` is used. I've seen both cursor types used in the GitHub API. This ensures that this implementation detail is opaque to the consumer (this C&C class) and it Just Works.
     2. `nil` indicates that there is no cursor
     
     - parameter: `from` identifier marking the offset of a query
     - parameter: `limit` Marks the number of records to return
     - returns: A query object
     */
    func repositories(from: Any?, limit: Int) -> Future<RepositoryQuery, RepositoryListServiceError>
}

/**
 This shows an example of what might occur after integration between a C&C class and a service.
 
 The consumer, this C&C class, defines a protocol, the `RepositoryService`, which identifies what is required by the service. The service could work from this implementation. This extension can then be used to create fakes in test (without needing the service) or enforce that the contract is upheld by the service.
 This protocol does not need to be leaked to the service layer.
 This allows both the C&C class and the service to be worked on in tandem. Only the protocol needs to be defined before work can be done.
 */
extension GitHubGraphQLService: RepositoryService { }

class RepositoryListCommandAndControl: RepositoryListController {
    
    private let service: RepositoryService = GitHubGraphQLService()
    
    private weak var _delegate: RepositoryListControllerDelegate?
    private var limit: Int = 10
    private var cursor: String? = nil
    
    var delegate: RepositoryListControllerDelegate? {
        set {
            _delegate = newValue
        }
        get {
            return _delegate
        }
    }
    
    func loadRepositories() {
        queryRepositories()
    }
    
    func loadNextRepositories() {
        queryRepositories(cursor: cursor)
    }
    
    // MARK: Private
    
    private func queryRepositories(cursor: Any? = nil) {
        service.repositories(from: cursor, limit: limit)
            .onSuccess { [weak self] (query: RepositoryQuery) in
                self?.cursor = query.cursor
                self?._delegate?.didLoadRepositories(repositories: query.repositories)
            }
            .onFailure { [weak self] (error) in
                self?.delegate?.displayError(error: error)
            }
    }
}
