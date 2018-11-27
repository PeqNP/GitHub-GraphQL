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
    func repositories(from: Int, limit: Int) -> Future<[Repository], GraphQLServiceError>
}

class GraphQLCommandAndControl: GraphQLController {
    
    private let service: GraphQLService = GitHubGraphQLService()
    
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
        service.repositories(from: 0, limit: 10).onSuccess { [weak _delegate] (repositories: [Repository]) in
            _delegate?.didLoadRepositories(repositories: repositories)
        }
    }
}

// MARK:
import Alamofire

private enum Constant {
    static let githubToken = ""
}

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

class GitHubGraphQLService: GraphQLService {
    
    func repositories(from: Int, limit: Int) -> Future<[Repository], GraphQLServiceError> {
        
        let url = URL(string: "https://api.github.com/graphql")!
        let headers: [String: String] = [
            "Authorization": "Bearer \(Constant.githubToken)"
        ]
        var urlRequest = try! URLRequest(url: url, method: .post, headers: headers)
        
        let query = """
        query {
            search(query: "graphql", type: REPOSITORY, first: 10) {
                edges {
                    node { ... on Repository {
                        name
                        stargazers { totalCount }
                        owner {
                            login
                            avatarUrl
                        }
                    } }
                }
            }
        }
        """
        let body: [String: String] = [
            "query": query
        ]
        urlRequest.httpBody = body.asData
        
        let promise = Promise<[Repository], GraphQLServiceError>()
        
        Alamofire.request(urlRequest).responseJSON { (response) in
            guard let data = response.data else {
                print(response.error?.localizedDescription ?? "Error")
                return
            }
            print(String(bytes: data, encoding: .utf8) ?? "")
            let decoder = JSONDecoder()
            let response = try? decoder.decode(RepositoryResponse.self, from: data)
            guard let edges = response?.data?.search?.edges else {
                return promise.success([Repository]())
            }
            let repositories: [Repository] = edges.map { (node: GitHubGraphQLService.RepositoryResponse.SearchNode) -> Repository in
                return Repository(
                    name: node.node?.name ?? "",
                    ownerAvatarURL: URL(string: node.node?.owner?.avatarUrl ?? ""),
                    ownerLogin: node.node?.owner?.login ?? "",
                    totalStars: node.node?.stargazers?.totalCount ?? 0
                )
            }
            
            return promise.success(repositories)
        }
        
        return promise.future
    }
}

extension GitHubGraphQLService {
    struct RepositoryResponse: Decodable {
        struct DataResponse: Decodable {
            let search: SearchResponse?
        }
        struct SearchResponse: Decodable {
            let edges: [SearchNode]?
        }
        struct SearchNode: Decodable {
            let node: SearchedNode?
        }
        struct SearchedNode: Decodable {
            let name: String?
            let stargazers: Stargazers?
            let owner: Owner?
        }
        struct Owner: Decodable {
            let login: String?
            let avatarUrl: String?
        }
        struct Stargazers: Decodable {
            let totalCount: Int?
        }
        
        let data: DataResponse?
    }
}
