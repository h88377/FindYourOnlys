//
//  FriendRequestViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit

class ProfileFriendRequestViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    let viewModel = ProfileFriendRequestViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchFriendRequest()
        
        viewModel.friendRequestListViewModels.bind { [weak self] _ in
            
            DispatchQueue.main.async {
                
                self?.tableView.reloadData()
            }
        }
        
        viewModel.errorViewModel?.bind(listener: { errorViewModel in
            
            print(errorViewModel.error)
        })
        
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: FriendRequestCell.identifier)
    }
    
}

// MARK: - UITableViewDelegate and DataSource
extension ProfileFriendRequestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        viewModel.friendRequestListViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.friendRequestListViewModels.value[section].friendRequestList.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestCell.identifier, for: indexPath) as? FriendRequestCell
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.friendRequestListViewModels.value[indexPath.section]
        
        cell.configureCell(with: cellViewModel.friendRequestList.type, user: cellViewModel.friendRequestList.users[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return viewModel.friendRequestListViewModels.value[section].friendRequestList.type.rawValue
    }
}
