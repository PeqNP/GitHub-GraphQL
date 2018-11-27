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
    static let githubToken = "023af7876285cbd7d00204e6d2abc4e876c3f7e7"
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
        Alamofire.request(urlRequest).responseJSON { (response) in
            guard let data = response.data else {
                print(response.error?.localizedDescription ?? "Error")
                return
            }
            print(String(bytes: data, encoding: .utf8) ?? "")
            let decoder = JSONDecoder()
            let repository = try? decoder.decode(RepositoryResponse.self, from: data)
            
        }
        
        let repositories: [Repository] = [
            Repository(
                name: "A name",
                ownerAvatarURL: URL(string: "https://www.slrlounge.com/wp-content/uploads/2016/10/pounce-cat-seth-casteel-kitten-holly6.jpg")!,
                ownerLogin: "Author name",
                totalStars: 1000
            )
        ]
        
        return Future(value: repositories)
    }
}

extension GitHubGraphQLService {
    struct RepositoryResponse: Decodable {
        struct DataResponse: Decodable {
            let search: SearchResponse?
        }
        struct SearchResponse: Decodable {
            let edges: [SearchedNode]?
        }
        struct SearchNode: Decodable {
            let node: SearchedNode?
        }
        struct SearchedNode: Decodable {
            let name: String?
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
