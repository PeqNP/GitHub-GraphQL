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

struct Repository {
    let name: String
    let ownerAvatarURL: URL?
    let ownerLogin: String
    let totalStars: Int
}

protocol GraphQLControllerDelegate: class {
    func didLoadRepositories(repositories: [Repository])
}

class GraphQLTableViewController: UITableViewController {

    // MARK: Injected Class(es)
    private var controller: GraphQLController?
    
    // MARK: Private
    private var repositories: [Repository] = []
    
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
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? GraphQLTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configureWith(repository: repositories[indexPath.row])
        return cell
    }
}

extension GraphQLTableViewController: GraphQLControllerDelegate {
    func didLoadRepositories(repositories: [Repository]) {
        self.repositories = repositories
        tableView.reloadData()
    }
}

class GraphQLTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    func configureWith(repository: Repository) {
        avatarImageView.kf.setImage(with: repository.ownerAvatarURL)
        authorNameLabel.text = repository.ownerLogin
        repositoryNameLabel.text = repository.name
        ratingLabel.text = String(repository.totalStars)
    }
}
