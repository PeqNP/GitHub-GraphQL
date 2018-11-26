//
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import UIKit
import Kingfisher

protocol GraphQLController {
    var delegate: GraphQLControllerDelegate? { get set }
    func loadGraphQL()
}

struct GraphQL {
    let avatarImageURL: URL
    let repositoryName: String
    let authorName: String
    let rating: Double
}

protocol GraphQLControllerDelegate: class {
    func didLoadGraphQL(graphs: [GraphQL])
}

class GraphQLTableViewController: UITableViewController {

    // MARK: Injected Class(es)
    private var controller: GraphQLController?
    
    // MARK: Private
    private var graphs: [GraphQL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller = GraphQLCommandAndControl()
        controller?.delegate = self
        controller?.loadGraphQL()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graphs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? GraphQLTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configureWith(graphQL: graphs[indexPath.row])
        return cell
    }
}

extension GraphQLTableViewController: GraphQLControllerDelegate {
    func didLoadGraphQL(graphs: [GraphQL]) {
        self.graphs = graphs
        tableView.reloadData()
    }
}

class GraphQLTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    func configureWith(graphQL: GraphQL) {
        avatarImageView.kf.setImage(with: graphQL.avatarImageURL)
        authorNameLabel.text = graphQL.authorName
        repositoryNameLabel.text = graphQL.repositoryName
        ratingLabel.text = String(graphQL.rating)
    }
}
