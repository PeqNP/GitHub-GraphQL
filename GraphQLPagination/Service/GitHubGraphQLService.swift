//
//  GitHubGraphQLService.swift
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import Alamofire
import BrightFutures
import Foundation

private enum Constant {
    // Put your GitHub bearer token here
    static let githubToken = "0e947078d77c5c672051ac38203f5bacf7ab0e3f"
}

class GitHubGraphQLService {
    
    let requestHandler: RequestHandler = JSONRequestHandler()
    
    // Structure we get back from the GitHub GraphQL service
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
    
    func repositories(from: Int, limit: Int) -> Future<[Repository], RepositoryListServiceError> {
        let promise = Promise<[Repository], RepositoryListServiceError>()

        guard let url = URL(string: "https://api.github.com/graphql") else {
            promise.failure(.unknown)
            return promise.future
        }
        let headers: [String: String] = [
            "Authorization": "Bearer \(Constant.githubToken)"
        ]
        // `cursor` is in some of the graph calls. This call needs a "cursor" and specified using `after`. I couldn't determine where the "cursor" ID was located within the given amount of time.
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

        guard var urlRequest = try? URLRequest(url: url, method: .post, headers: headers) else {
            promise.failure(.unknown)
            return promise.future
        }
        urlRequest.httpBody = body.asData
        
        requestHandler.request(urlRequest: urlRequest, GitHubGraphQLService.RepositoryResponse.self).onSuccess { (response) in
            guard let edges = response.data?.search?.edges else {
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
