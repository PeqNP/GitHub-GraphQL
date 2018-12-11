//
//  GraphQLPagination
//
//  Created by Eric Chamberlain on 11/26/18.
//  Copyright © 2018 Eric Chamberlain. All rights reserved.
//

import UIKit
import Kingfisher

struct Repository {
    let name: String
    let ownerAvatarURL: URL?
    let ownerLogin: String
    let totalStars: Int
}

protocol RepositoryListControllerDelegate: class {
    func didLoadRepositories(repositories: [Repository])
    func displayError(error: Error)
}

protocol RepositoryListController {
    var delegate: RepositoryListControllerDelegate? { get set }
    func loadRepositories()
    func loadNextRepositories()
}

class RepositoryListViewController: UITableViewController {

    // MARK: Injected
    private var controller: RepositoryListController?
    
    // MARK: Private
    private var repositories: [Repository] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller = RepositoryListCommandAndControl()
        controller?.delegate = self
        controller?.loadRepositories()
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
        
        if indexPath.row >= repositories.count - 1 {
            controller?.loadNextRepositories()
        }
        
        cell.configureWith(repository: repositories[indexPath.row])
        return cell
    }
}

extension RepositoryListViewController: RepositoryListControllerDelegate {
    func didLoadRepositories(repositories: [Repository]) {
        self.repositories = self.repositories + repositories
        tableView.reloadData()
    }
    
    func displayError(error: Error) {
        // TODO: Use dependency to display the error.
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
