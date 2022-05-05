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
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
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
        
        viewModel.chatRoomViewModels.bind { [weak self] chatRoomViewModels in
            
            self?.tableView.isHidden = chatRoomViewModels.count == 0
            
            self?.tableView.reloadData()
        }
        
        viewModel.friendViewModels.bind { [weak self] friendViewModels in
            
            self?.tableView.isHidden = friendViewModels.count == 0
            
            self?.tableView.reloadData()
        }
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: ChatRoomFriendListCell.identifier)   
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "聊天室"
        
//        let requestItem = UIBarButtonItem(
//            title: "邀請",
//            style: .plain,
//            target: self,
//            action: #selector(checkFriendRequest)
//        )
        let requestItem = UIBarButtonItem(
            image: UIImage.system(.addFriend),
            style: .plain,
            target: self,
            action: #selector(checkFriendRequest)
        )
        
        let searchItem = UIBarButtonItem(
            image: UIImage.system(.search),
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
