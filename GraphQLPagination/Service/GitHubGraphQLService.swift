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
    static let githubToken = ""
}

class GitHubGraphQLService {
    
    let requestHandler: RequestHandler = JSONRequestHandler()
    
    // Structure provided by GitHub GraphQL service
    private struct RepositoryResponse: Decodable {
        struct DataResponse: Decodable {
            let search: Search?
        }
        struct Search: Decodable {
            let pageInfo: PageInfo?
            let edges: [Edge]?
        }
        struct PageInfo: Decodable {
            let endCursor: String?
        }
        struct Edge: Decodable {
            let node: Repository?
        }
        struct Repository: Decodable {
            let id: String?
            let name: String?
            let stargazers: Stargazers?
            let owner: Owner?
            let isFork: Bool
            let isMirror: Bool
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
    
    func repositories(from: Any?, limit: Int) -> Future<RepositoryQuery, RepositoryListServiceError> {
        let promise = Promise<RepositoryQuery, RepositoryListServiceError>()

        guard let urlRequest = urlRequestFor(cursor: from, limit: limit) else {
            promise.failure(.unknown)
            return promise.future
        }
        
        requestHandler.request(urlRequest: urlRequest, GitHubGraphQLService.RepositoryResponse.self)
            .onSuccess { (response) in
                let cursor = response.data?.search?.pageInfo?.endCursor
                guard let edges = response.data?.search?.edges else {
                    return promise.success(RepositoryQuery(cursor: cursor, repositories: [Repository]()))
                }
                
                let repositories: [Repository] = edges.map { (edge: GitHubGraphQLService.RepositoryResponse.Edge) -> Repository in
                    return Repository(
                        id: edge.node?.id ?? "",
                        name: edge.node?.name ?? "",
                        ownerAvatarURL: URL(string: edge.node?.owner?.avatarUrl ?? ""),
                        ownerLogin: edge.node?.owner?.login ?? "",
                        totalStars: edge.node?.stargazers?.totalCount ?? 0,
                        isFork: edge.node?.isFork ?? false,
                        isMirror: edge.node?.isMirror ?? false
                    )
                }
                
                let query = RepositoryQuery(cursor: cursor, repositories: repositories)
                return promise.success(query)
            }
            .onFailure { (error) in
                promise.failure(RepositoryListServiceError.failedToQueryRepositories)
            }
        
        return promise.future
    }
    
    private func urlRequestFor(cursor: Any?, limit: Int) -> URLRequest? {
        guard let url = URL(string: "https://api.github.com/graphql") else {
            return nil
        }
        let headers: [String: String] = [
            "Authorization": "Bearer \(Constant.githubToken)"
        ]
        let body: [String: String] = [
            "query": queryFor(cursor: cursor as? String, limit: limit)
        ]
        guard var urlRequest = try? URLRequest(url: url, method: .post, headers: headers) else {
            return nil
        }
        urlRequest.httpBody = body.asData
        return urlRequest
    }
    
    private func queryFor(cursor: String?, limit: Int) -> String {
        var after = ""
        if let cursor = cursor {
            after = ", after: \"\(cursor)\""
        }
        let query = """
        query {
        search(query: "graphql", type: REPOSITORY, first: \(limit)\(after)) {
                pageInfo { endCursor }
                edges {
                    node { ... on Repository {
                        id
                        name
                        isFork
                        isMirror
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
        return query
    }
}
