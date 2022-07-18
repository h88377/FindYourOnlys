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
        
        viewModel.chatRooms.bind { [weak self] chatRooms in
            
            guard let self = self else { return }
            
            self.tableView.isHidden = chatRooms.isEmpty
            
            self.tableView.reloadData()
        }
        
        viewModel.friends.bind { [weak self] friends in
            
            guard let self = self else { return }
            
            self.tableView.isHidden = friends.isEmpty
            
            self.tableView.reloadData()
        }
        
        viewModel.error.bind { [weak self] error in
            
            guard
                let self = self,
                let error = error
            else { return }
            
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
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
            action: #selector(checkFriendRequest))
        
        let searchItem = UIBarButtonItem(
            image: UIImage.system(.addFriend),
            style: .plain,
            target: self,
            action: #selector(searchFriend))
        
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
            name: .didSetCurrentUser, object: nil)
    }
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        viewModel.fetchChatRoom()
    }
}

// MARK: - UITableViewDataSource and Delegate

extension ChatRoomFriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.friends.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatRoomFriendListCell.identifier,
                for: indexPath
            )as? ChatRoomFriendListCell
        else { return UITableViewCell() }
        
        let friend = viewModel.friends.value[indexPath.row]
        
        cell.configureCell(with: friend)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.chatSociety
        
        guard
            let chatRoomMessageVC = storyboard.instantiateViewController(
                withIdentifier: ChatRoomMessageViewController.identifier
            )as? ChatRoomMessageViewController
        else { return }
        
        let selectedChatRoom = viewModel.chatRooms.value[indexPath.row]
        
        let selectedFriend = viewModel.friends.value[indexPath.row]
        
        chatRoomMessageVC.viewModel.changedSelectedChatRoom(with: selectedChatRoom)
        
        chatRoomMessageVC.viewModel.changedSelectedFriend(with: selectedFriend)
        
        navigationController?.pushViewController(chatRoomMessageVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
