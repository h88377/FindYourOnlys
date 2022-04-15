//
//  FriendListViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import UIKit

class ChatRoomFriendListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    let viewModel = ChatRoomFriendListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchChatRoom { error in
            
            if error != nil {
                
                print(error)
            }
        }
        
        viewModel.chatRoomViewModels.bind { [weak self] _ in
            
            self?.tableView.reloadData()
        }
        
        viewModel.friendViewModels.bind { [weak self] _ in
            
            self?.tableView.reloadData()
        }
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: ChatRoomFriendListCell.identifier)
        
    }
}

// MARK: - UITableViewDataSource and Delegate
extension ChatRoomFriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.friendViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomFriendListCell.identifier, for: indexPath) as? ChatRoomFriendListCell
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.friendViewModels.value[indexPath.row]
        
        cell.configureCell(with: cellViewModel)
        
        return cell
    }
}
