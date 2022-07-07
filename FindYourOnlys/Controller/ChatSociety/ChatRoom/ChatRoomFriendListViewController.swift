//
//  FriendListViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import UIKit

class ChatRoomFriendListViewController: BaseViewController {
    
    // MARK: - Properties

    private let viewModel = ChatRoomFriendListViewModel()
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet private weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.chatRoomViewModels.bind { [weak self] chatRoomViewModels in
            
            guard
                let self = self else { return }
            
            self.tableView.isHidden = chatRoomViewModels.isEmpty
            
            self.tableView.reloadData()
        }
        
        viewModel.friendViewModels.bind { [weak self] friendViewModels in
            
            guard
                let self = self else { return }
            
            self.tableView.isHidden = friendViewModels.isEmpty
            
            self.tableView.reloadData()
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                AlertWindowManager.shared.showAlertWindow(at: self, of: error)
            }
        }
        
        addCurrentUserObserver()

        viewModel.fetchChatRoom()
    }
    
    // MARK: - Methods
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: ChatRoomFriendListCell.identifier)   
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "聊天室"
        
        let requestItem = UIBarButtonItem(
            image: UIImage.system(.notification),
            style: .plain,
            target: self,
            action: #selector(checkFriendRequest)
        )
        
        let searchItem = UIBarButtonItem(
            image: UIImage.system(.addFriend),
            style: .plain,
            target: self,
            action: #selector(searchFriend)
        )
        
        navigationItem.rightBarButtonItems = [searchItem, requestItem]
    }
    
    @objc func checkFriendRequest(sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard.chatSociety
        
        let friendRequestVC = storyboard.instantiateViewController(
            withIdentifier: FriendRequestViewController.identifier)
        
        navigationController?.pushViewController(friendRequestVC, animated: true)
    }
    
    @objc func searchFriend(sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard.chatSociety
        
        let searchFriendVC = storyboard.instantiateViewController(
            withIdentifier: SearchFriendViewController.identifier)
        
        navigationController?.pushViewController(searchFriendVC, animated: true)
    }
    
    private func addCurrentUserObserver() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentUserDidSet),
            name: .didSetCurrentUser, object: nil
        )
    }
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        viewModel.fetchChatRoom()
    }
}

// MARK: - UITableViewDataSource and Delegate

extension ChatRoomFriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.friendViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatRoomFriendListCell.identifier,
                for: indexPath)
                as? ChatRoomFriendListCell
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.friendViewModels.value[indexPath.row]
        
        cell.configureCell(with: cellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.chatSociety
        
        guard
            let chatRoomMessageVC = storyboard.instantiateViewController(
                withIdentifier: ChatRoomMessageViewController.identifier)
                as? ChatRoomMessageViewController
                
        else { return }
        
        let selectedChatRoom = viewModel.chatRoomViewModels.value[indexPath.row].chatRoom
        
        let selectedFriend = viewModel.friendViewModels.value[indexPath.row].user
        
        chatRoomMessageVC.viewModel.changedSelectedChatRoom(with: selectedChatRoom)
        
        chatRoomMessageVC.viewModel.changedSelectedFriend(with: selectedFriend)
        
        navigationController?.pushViewController(chatRoomMessageVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
